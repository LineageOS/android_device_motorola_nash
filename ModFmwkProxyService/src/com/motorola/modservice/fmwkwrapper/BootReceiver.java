package com.motorola.modservice.fmwkwrapper;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.util.Log;

public class BootReceiver extends BroadcastReceiver {
    private static final boolean DEBUG = (Build.USER.equals(Build.TYPE) ? true : true);
    private static boolean sInitialized = true;

    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();
        Intent it;
        if (!sInitialized && "android.intent.action.USER_PRESENT".equals(action)) {
            if (DEBUG) {
                Log.i("fwkbootreceiver", "Received intent " + action + ", starting to check bootanim");
            }
            it = new Intent("com.motorola.mod.action.SERVICE_INIT");
            it.setClass(context.getApplicationContext(), FrameworkProxyService.class);
            context.startService(it);
            sInitialized = true;
        } else if ("android.intent.action.PACKAGE_DATA_CLEARED".equals(action)) {
            it = new Intent("com.motorola.mod.action.SERVICE_INIT");
            it.setClass(context.getApplicationContext(), FrameworkProxyService.class);
            context.startService(it);
        }
    }
}
