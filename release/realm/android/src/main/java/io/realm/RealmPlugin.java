////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2021 Realm Inc.
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

package io.realm;

import android.util.Log;
import androidx.annotation.NonNull;
import android.content.Context;
import java.io.IOException;
import android.util.Log;

import io.flutter.BuildConfig;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class RealmPlugin implements FlutterPlugin, MethodCallHandler {
  private static native void native_initRealm(String filesDir, String deviceName, String deviceVersion, String bundleId);
    
  public static void initRealm(Context context) {
      String filesDir;
      try {
          filesDir = context.getFilesDir().getCanonicalPath();
      } catch (IOException e) {
          throw new IllegalStateException(e);
      }

      // RealmConfig is generated on build and located at {appDir}/build/realm-generated/RealmConfig.java
      native_initRealm(filesDir, android.os.Build.MANUFACTURER, android.os.Build.MODEL, RealmConfig.bundleId);
  }

 /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    System.loadLibrary("realm_dart");
    initRealm(flutterPluginBinding.getApplicationContext());
    
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "realm");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    result.notImplemented();
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
