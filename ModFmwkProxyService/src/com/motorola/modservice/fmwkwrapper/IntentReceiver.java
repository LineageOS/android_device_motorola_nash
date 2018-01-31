package com.motorola.modservice.fmwkwrapper;

import android.app.ActivityManagerNative;
import android.app.IActivityManager;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Build;
import android.os.IBinder;
import android.os.ParcelUuid;
import android.os.PowerManager;
import android.os.PowerManager.WakeLock;
import android.os.RemoteException;
import android.os.SystemClock;
import android.os.SystemProperties;
import android.os.UserHandle;
import android.util.Base64;
import android.util.Log;
import java.nio.ByteBuffer;
import java.util.UUID;

public class IntentReceiver extends BroadcastReceiver {
    private static final boolean DEBUG;
    static final ComponentName MOD_SERVICE_NAME = new ComponentName("com.motorola.modservice", "com.motorola.modservice.ModManagerService");
    private static PowerManager mPowerManager;
    private static WakeLock mScreenOffWakeLock;
    private static boolean mWasDisplayOffByFpsEnabled;
    private ServiceConnection mServiceConnection;

    class C00134 implements Runnable {
        C00134() {
        }

        public void run() {
            IntentReceiver.releaseWakeLockThread();
        }
    }

    private class MyServiceConnection implements ServiceConnection {
        private IBinder mBinder;
        private Context mContext;

        public MyServiceConnection(Context context) {
            this.mContext = context;
        }

        public void onServiceConnected(ComponentName name, IBinder service) {
            this.mBinder = service;
        }

        public void onServiceDisconnected(ComponentName name) {
            synchronized (IntentReceiver.this) {
                IntentReceiver.this.mServiceConnection = null;
            }
        }
    }

    static {
        boolean z;
        if (Build.USER.equals(Build.TYPE)) {
            z = true;
        } else {
            z = true;
        }
        DEBUG = z;
    }

    public void onReceive(final Context context, Intent intent) {
        String action = intent.getAction();
        if (DEBUG) {
            Log.i("fwkintentreceiver", "Received intent: " + intent.toUri(0));
        }
        if ("com.motorola.modservice.BATTERY_MODE".equals(action)) {
            final String mode = Integer.toString(intent.getIntExtra("mode", 0));
            new Thread(new Runnable() {
                public void run() {
                    SystemProperties.set("sys.mod.batterymode", mode);
                }
            }).start();
        } else if ("com.motorola.modservice.UPDATE_DISPLAY_NAME".equals(action)) {
            final String name = intent.getStringExtra("display_name");
            new Thread(new Runnable() {
                public void run() {
                    SystemProperties.set("sys.mod.displayname", name);
                }
            }).start();
        } else if (UserHandle.myUserId() != 0) {
            if (DEBUG) {
                Log.w("fwkintentreceiver", "Non-primary user, ignoring " + action);
            }
        } else {
            if ("com.motorola.mod.action.SERVICE_STARTED".equals(action)) {
                boolean bind = false;
                Context ctx = context.getApplicationContext();
                synchronized (this) {
                    if (this.mServiceConnection == null) {
                        this.mServiceConnection = new MyServiceConnection(ctx);
                        bind = true;
                    }
                }
                if (bind) {
                    Intent it = new Intent("com.motorola.mod.action.BIND_MANAGER");
                    it.setComponent(MOD_SERVICE_NAME);
                    ctx.bindServiceAsUser(it, this.mServiceConnection, 73, UserHandle.CURRENT);
                }
            } else if ("com.motorola.mod.action.display.ON_INTERNAL".equals(action)) {
                if (intent.getIntExtra("powerMode", -1) == 1) {
                    Context c = context;
                    new Thread(new Runnable() {
                        public void run() {
                            IntentReceiver.acquireWakeLockThread(context, 1);
                        }
                    }).start();
                }
            } else if ("com.motorola.mod.action.display.OFF_INTERNAL".equals(action)) {
                new Thread(new C00134()).start();
            } else if ("com.motorola.mod.action.TOGGLE_FPS_NAV".equals(action)) {
                toggleFpsNav(context, intent.getBooleanExtra("mode", true));
            }
        }
    }

    private void toggleFpsNav(Context context, boolean enabled) {
        if (!enabled) {
            boolean now = getDisplayOffByFpsEnabled(context);
            if (now != enabled) {
                mWasDisplayOffByFpsEnabled = now;
            } else {
                return;
            }
        }
        if (mWasDisplayOffByFpsEnabled) {
            setDisplayOffByFpsEnabled(context, enabled);
        }
    }

    static void setDisplayOffByFpsEnabled(Context context, boolean enabled) {
    }

    private boolean getDisplayOffByFpsEnabled(Context context) {
        return false;
    }

    private static void acquireWakeLockThread(Context context, int wakeLockType) {
        mPowerManager = (PowerManager) context.getSystemService("power");
        mPowerManager.wakeUp(SystemClock.uptimeMillis());
        mScreenOffWakeLock = mPowerManager.newWakeLock(wakeLockType, "fwkintentreceiver");
        mScreenOffWakeLock.setReferenceCounted(false);
        if (!mScreenOffWakeLock.isHeld()) {
            mScreenOffWakeLock.acquire();
        }
    }

    private static void releaseWakeLockThread() {
        if (mScreenOffWakeLock != null && mScreenOffWakeLock.isHeld()) {
            mScreenOffWakeLock.release(0);
        }
    }

    static void onAttach(Intent intent) {
        int i = 0;
        SystemProperties.set("sys.mod.current", encodeIDs(intent.getIntExtra("vid", 0), intent.getIntExtra("pid", 0), (ParcelUuid) intent.getParcelableExtra("uid")));
        int[] pi = intent.getIntArrayExtra("protocols");
        int length = pi.length;
        while (i < length) {
            if (pi[i] == 237) {
                invalidateMediaProfile();
                return;
            }
            i++;
        }
    }

    static void onDetach(Context context, Intent intent) {
        SystemProperties.set("sys.mod.current", "");
        for (int p : intent.getIntArrayExtra("protocols")) {
            if (p == 237) {
                invalidateMediaProfile();
                break;
            }
        }
        setDisplayOffByFpsEnabled(context, true);
    }

    private static void invalidateMediaProfile() {
/* kill for now
        IActivityManager am = ActivityManagerNative.getDefault();
        try {
            Log.i("fwkintentreceiver", "Camera Mod detached, killing apps with stale camera profile data");
            am.killMediaProfile();
        } catch (RemoteException e) {
        }
*/
    }

    private static String encodeIDs(int vid, int pid, ParcelUuid puid) {
        long j = 0;
        ByteBuffer buf = ByteBuffer.allocate(24);
        UUID uuid = puid == null ? null : puid.getUuid();
        buf.putInt(vid);
        buf.putInt(pid);
        buf.putLong(uuid == null ? 0 : uuid.getLeastSignificantBits());
        if (uuid != null) {
            j = uuid.getMostSignificantBits();
        }
        buf.putLong(j);
        return Base64.encodeToString(buf.array(), 3);
    }
}
