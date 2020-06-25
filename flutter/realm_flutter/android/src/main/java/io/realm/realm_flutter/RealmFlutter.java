package io.realm.realm_flutter;

import android.content.Context;

import java.io.IOException;

public class RealmFlutter {
    public static native void native_initRealm(String filesDir);
    
    public static void initRealm(Context context) {
        String filesDir;
        try {
            filesDir = context.getFilesDir().getCanonicalPath();
        } catch (IOException e) {
            throw new IllegalStateException(e);
        }

        native_initRealm(filesDir);
    }
}
