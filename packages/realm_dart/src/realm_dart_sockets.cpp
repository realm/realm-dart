////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2024 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

#include "realm_dart_sockets.h"
#include "dart_api.h"
#include "realm_dart.hpp"
#include <realm/object-store/c_api/util.hpp>
#include <realm/sync/network/websocket.hpp>

using namespace realm::sync;
using namespace realm::c_api;

struct DartWebSocket : WebSocketInterface
{
public:
  DartWebSocket(std::shared_ptr<realm::util::Scheduler> scheduler, std::unique_ptr<WebSocketObserver> observer, WebSocketEndpoint &&endpoint, realm_dart_sync_socket_connect_func_t connect)
    : m_observer(std::move(observer))
  {
    scheduler->invoke([this, connect, endpoint = std::move(endpoint)]() mutable {
        realm_websocket_endpoint_t capi_endpoint;
        capi_endpoint.address = endpoint.address.c_str();
        capi_endpoint.port = endpoint.port;
        capi_endpoint.path = endpoint.path.c_str();

        std::vector<const char *> protocols;
        for (size_t i = 0; i < endpoint.protocols.size(); ++i) {
        auto &protocol = endpoint.protocols[i];
        protocols.push_back(protocol.c_str());
        }
        capi_endpoint.protocols = protocols.data();
        capi_endpoint.num_protocols = protocols.size();
        capi_endpoint.is_ssl = endpoint.is_ssl;

        m_managed_socket = connect(capi_endpoint, m_observer.get());
    });
  }

  /// Destroys the web socket instance.
  ~DartWebSocket() { throw "not implemented"; }

  void async_write_binary(realm::util::Span<const char> data,
                          SyncSocketProvider::FunctionHandler &&handler) final
  {
    throw "not implemented";
  }

private:
  Dart_Handle m_managed_socket;
  std::unique_ptr<WebSocketObserver> m_observer;
};

class DartSocketProvider final : public SyncSocketProvider {
public:
  std::shared_ptr<realm::util::Scheduler> m_scheduler;
  realm_dart_sync_socket_connect_func_t m_websocket_connect;

  DartSocketProvider(Dart_Handle managed_provider, std::shared_ptr<realm::util::Scheduler> scheduler, realm_dart_sync_socket_connect_func_t connect)
      : m_managed_provider(managed_provider), m_scheduler(scheduler),
        m_websocket_connect(connect)
  {
    REALM_ASSERT(m_websocket_connect);
  }

  ~DartSocketProvider() { Dart_DeletePersistentHandle_DL(m_managed_provider); }

  std::unique_ptr<WebSocketInterface> connect(std::unique_ptr<WebSocketObserver> observer, WebSocketEndpoint &&endpoint) final
  {
    return std::make_unique<DartWebSocket>(m_scheduler, std::move(observer), std::move(endpoint), m_websocket_connect);
  }

  void post(FunctionHandler &&handler) final { throw "not implemented"; }

  SyncTimer create_timer(std::chrono::milliseconds delay, FunctionHandler &&handler) final
  {
    // TODO
    throw "not implemented";
  }

private:
  Dart_Handle m_managed_provider;
};

RLM_API realm_sync_socket_t * realm_dart_sync_socket_new(Dart_Handle managed_provider, realm_scheduler_t *scheduler, realm_dart_sync_socket_connect_func_t connect)
{
  return wrap_err([&]() {
    auto capi_socket_provider = std::make_shared<DartSocketProvider>(
        managed_provider, *scheduler, connect);
    return new realm_sync_socket_t(std::move(capi_socket_provider));
  });
}