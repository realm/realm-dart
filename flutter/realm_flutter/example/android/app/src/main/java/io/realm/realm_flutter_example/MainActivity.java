package io.realm.realm_flutter_example;

import android.os.Bundle;
import android.util.Log;

import androidx.annotation.Nullable;
import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        Log.d("Realm_Flutter_Example", "loading realm_flutter");
        System.loadLibrary("realm_flutter");
        Log.d("Realm_Flutter_Example", "realm_flutter.so loaded");


        Log.d("Realm_Flutter_Example", "calling initRealm");
        io.realm.realm_flutter.RealmFlutter.initRealm(getApplicationContext());
        Log.d("Realm_Flutter_Example", "Realm Flutter initialized");

        super.onCreate(savedInstanceState);
    }
}
