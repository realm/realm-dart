// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:http/http.dart';

import '../../logging.dart';
import '../../realm_dart.dart';
import 'convert_native.dart';
import 'ffi.dart';
import 'handle_base.dart';
import 'realm_bindings.dart';
import 'realm_library.dart';
import 'scheduler_handle.dart';

class HttpTransportHandle extends HandleBase<realm_http_transport> {
  HttpTransportHandle(Pointer<realm_http_transport> pointer) : super(pointer, 24);

  factory HttpTransportHandle.from(Client httpClient) {
    final requestCallback = Pointer.fromFunction<Void Function(Handle, realm_http_request, Pointer<Void>)>(_requestCallback);
    final requestCallbackUserdata = realmLib.realm_dart_userdata_async_new(httpClient, requestCallback.cast(), schedulerHandle.pointer);
    return HttpTransportHandle(realmLib.realm_http_transport_new(
      realmLib.addresses.realm_dart_http_request_callback,
      requestCallbackUserdata.cast(),
      realmLib.addresses.realm_dart_userdata_async_free,
    ));
  }
}

void _requestCallback(Object userData, realm_http_request request, Pointer<Void> requestContext) {
  //
  // The request struct only survives until end-of-call, even though
  // we explicitly call realm_http_transport_complete_request to
  // mark request as completed later.
  //
  // Therefore we need to copy everything out of request before returning.
  // We cannot clone request on the native side with realm_clone,
  // since realm_http_request does not inherit from WrapC.

  final client = userData as Client;

  final timeLimit = Duration(milliseconds: request.timeout_ms);

  final url = Uri.parse(request.url.cast<Utf8>().toRealmDartString()!);

  final body = request.body.cast<Utf8>().toRealmDartString(length: request.body_size);

  final headers = <String, String>{};
  for (int i = 0; i < request.num_headers; ++i) {
    final header = request.headers[i];
    final name = header.name.cast<Utf8>().toRealmDartString()!;
    final value = header.value.cast<Utf8>().toRealmDartString()!;
    headers[name] = value;
  }

  _requestCallbackAsync(client, request.method, url, body, headers, timeLimit, requestContext);
  // The request struct dies here!
}

Future<void> _requestCallbackAsync(
  Client client,
  int requestMethod,
  Uri url,
  String? body,
  Map<String, String> headers,
  Duration timeLimit,
  Pointer<Void> requestContext,
) async {
  await using((arena) async {
    final responsePointer = arena<realm_http_response>();
    final responseRef = responsePointer.ref;
    final method = HttpMethod.values[requestMethod];

    try {
      // Build request
      final request = Request(method.name, url);
      for (final header in headers.entries) {
        request.headers[header.key] = header.value;
      }

      if (body != null) {
        request.bodyBytes = utf8.encode(body);
      }

      Realm.logger.log(LogLevel.debug, "HTTP Transport: Executing ${method.name} $url");

      final stopwatch = Stopwatch()..start();

      // Do the call..
      final response = await client.send(request).timeout(timeLimit);

      stopwatch.stop();
      Realm.logger.log(LogLevel.debug, "HTTP Transport: Executed ${method.name} $url: ${response.statusCode} in ${stopwatch.elapsedMilliseconds} ms");

      final responseBody = await response.stream.fold<List<int>>([], (acc, l) => acc..addAll(l)); // gather response

      // Report back to core
      responseRef.status_code = response.statusCode;
      responseRef.body = responseBody.toCharPtr(arena);
      responseRef.body_size = responseBody.length;

      int headerCnt = response.headers.length;
      responseRef.headers = arena<realm_http_header>(headerCnt);
      responseRef.num_headers = headerCnt;

      int index = 0;
      response.headers.forEach((name, value) {
        final headerRef = (responseRef.headers + index).ref;
        headerRef.name = name.toCharPtr(arena);
        headerRef.value = value.toCharPtr(arena);
        index++;
      });

      responseRef.custom_status_code = CustomErrorCode.noError.code;
    } on TimeoutException catch (timeoutEx) {
      Realm.logger.log(LogLevel.warn, "HTTP Transport: TimeoutException executing ${method.name} $url: $timeoutEx");
      responseRef.custom_status_code = CustomErrorCode.timeout.code;
    } on SocketException catch (socketEx) {
      Realm.logger.log(LogLevel.warn, "HTTP Transport: SocketException executing ${method.name} $url: $socketEx");
      responseRef.custom_status_code = CustomErrorCode.socketException.code;
    } on HttpException catch (httpEx) {
      Realm.logger.log(LogLevel.warn, "HTTP Transport: HttpException executing ${method.name} $url: $httpEx");
      responseRef.custom_status_code = CustomErrorCode.unknownHttp.code;
    } catch (ex) {
      Realm.logger.log(LogLevel.error, "HTTP Transport: Exception executing ${method.name} $url: $ex");
      responseRef.custom_status_code = CustomErrorCode.unknown.code;
    } finally {
      realmLib.realm_http_transport_complete_request(requestContext, responsePointer);
    }
  });
}
