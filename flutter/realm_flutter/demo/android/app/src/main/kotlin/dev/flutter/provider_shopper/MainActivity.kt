package dev.flutter.provider_shopper

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant


import android.os.Bundle


class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
    }


     override fun onCreate(savedInstanceState: Bundle?) {
        System.loadLibrary("realm_flutter");
        io.realm.realm_flutter.RealmFlutter.initRealm(applicationContext);

        super.onCreate(savedInstanceState)
    }
}
