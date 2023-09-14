// ////////////////////////////////////////////////////////////////////////////////
// //
// // Copyright 2023 Realm Inc.
// //
// // Licensed under the Apache License, Version 2.0 (the "License");
// // you may not use this file except in compliance with the License.
// // You may obtain a copy of the License at
// //
// // http://www.apache.org/licenses/LICENSE-2.0
// //
// // Unless required by applicable law or agreed to in writing, software
// // distributed under the License is distributed on an "AS IS" BASIS,
// // WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// // See the License for the specific language governing permissions and
// // limitations under the License.
// //
// ////////////////////////////////////////////////////////////////////////////////
// import 'dart:async';
// import 'package:cancellation_token/cancellation_token.dart';
// import 'package:test/test.dart' hide test, throws;
// import '../lib/realm.dart';
// import 'test.dart';

// part 'destructive_schema_test.g.dart';

// @RealmModel()
// @MapTo("Card")
// class _CardV1 {
//   @PrimaryKey()
//   @MapTo('_id')
//   late ObjectId id;
//   late String test;
// }

// @RealmModel()
// @MapTo("Card")
// class _CardV2 {
//   @PrimaryKey()
//   @MapTo('_id')
//   late ObjectId id;
// }

// // Destructive schema change causes the server to force the translator to restart.
// // This means that the Flexible sync will be terminated and re-enabled.
// // During this operation no other tests working with flexible sync could be executed.
// // For this reason this test is relocated to a separate file,
// // which will be executed at the end after all the other tests.
// Future<void> main([List<String>? args]) async {
//   await setupTests(args);

//   baasTest('Realm can be deleted after destructive schema change (flexibleSync)', (configuration) async {
//     final app = App(configuration);
//     final CancellationToken cancellationToken = CancellationToken();
//     final user = await app.logIn(Credentials.anonymous(reuseCredentials: false));
//     final resetCompleter = Completer<void>();
//     final configV1 = Configuration.flexibleSync(user, [CardV1.schema], clientResetHandler: ManualRecoveryHandler((syncError) {
//       if (!resetCompleter.isCompleted) {
//         cancellationToken.cancel();
//         resetCompleter.completeError(syncError);
//       }
//     }));
//     final realmV1 = getRealm(configV1);
//     realmV1.subscriptions.update((mutableSubscriptions) {
//       mutableSubscriptions.add(realmV1.all<CardV1>());
//     });
//     try {
//       await realmV1.syncSession.waitForUpload(cancellationToken);
//     } catch (e) {
//       await resetCompleter.future;
//     }
//     realmV1.close();

//     final user1 = await app.logIn(Credentials.anonymous(reuseCredentials: false));
//     final configV2 = Configuration.flexibleSync(user1, [CardV2.schema], clientResetHandler: ManualRecoveryHandler((syncError) {
//       if (!resetCompleter.isCompleted) {
//         cancellationToken.cancel();
//         resetCompleter.completeError(syncError);
//       }
//     }));

//     final realmV2 = Realm(configV2);
//     realmV2.subscriptions.update((mutableSubscriptions) {
//       mutableSubscriptions.add(realmV2.all<CardV2>());
//     });
//     try {
//       await realmV2.syncSession.waitForUpload(cancellationToken);
//     } catch (e) {
//       //await resetCompleter.future;
//     }
//     realmV2.close();
//   });
// }
