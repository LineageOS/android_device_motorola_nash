package com.motorola.modservice.fmwkwrapper;

import android.app.Service;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.os.RemoteException;
import android.os.ServiceManager;
import android.os.SystemService;
import android.os.UserHandle;
import com.motorola.fmwkwrapper.IFrameworkProxyService.Stub;

public class FrameworkProxyService extends Service {
    private DockObserver mDockObserver;
    Stub mFrameworkProxyBinder = new C00081();
    private Handler mH = new C0009H();
    private PackageManager mPm;

    class C00081 extends Stub {
        C00081() {
        }

        public void revokeRuntimePermission(String packageName, String permissionName, UserHandle user) throws RemoteException {
            FrameworkProxyService.this.enforceCallingOrSelfPermission("com.motorola.mod.permission.MOD_INTERNAL", "revokeRuntimePermission requires com.motorola.mod.permission.MOD_INTERNAL");
            if (FrameworkProxyService.this.mPm == null) {
                FrameworkProxyService.this.mPm = FrameworkProxyService.this.getPackageManager();
            }
            FrameworkProxyService.this.mPm.revokeRuntimePermission(packageName, permissionName, user);
        }

        public void grantRuntimePermission(String packageName, String permissionName, UserHandle user) throws RemoteException {
            FrameworkProxyService.this.enforceCallingOrSelfPermission("com.motorola.mod.permission.MOD_INTERNAL", "grantRuntimePermission requires com.motorola.mod.permission.MOD_INTERNAL");
            if (FrameworkProxyService.this.mPm == null) {
                FrameworkProxyService.this.mPm = FrameworkProxyService.this.getPackageManager();
            }
            FrameworkProxyService.this.mPm.grantRuntimePermission(packageName, permissionName, user);
        }

        public void onModAttachDetach(Intent intent) {
            FrameworkProxyService.this.enforceCallingOrSelfPermission("com.motorola.mod.permission.MOD_INTERNAL", "onModAttachDetach requires com.motorola.mod.permission.MOD_INTERNAL");
            String action = intent.getAction();
            if ("com.motorola.mod.action.SERVICE_MOD_ATTACH".equals(action)) {
                IntentReceiver.onAttach(intent);
            } else if ("com.motorola.mod.action.SERVICE_MOD_DETACH".equals(action)) {
                IntentReceiver.onDetach(FrameworkProxyService.this, intent);
            }
        }

        public void setDockState(int newState) {
            FrameworkProxyService.this.enforceCallingOrSelfPermission("com.motorola.mod.permission.MOD_INTERNAL", "setDockState requires com.motorola.mod.permission.MOD_INTERNAL");
            FrameworkProxyService.this.mDockObserver.setDockState(newState);
        }

        public void addService(String name, IBinder svc) {
            if ("ModService".equals(name)) {
                FrameworkProxyService.this.enforceCallingOrSelfPermission("com.motorola.mod.permission.MOD_SERVICE", "addService requires com.motorola.mod.permission.MOD_SERVICE");
                ServiceManager.addService(name, svc);
                return;
            }
            throw new SecurityException("Can't add service other name ModService");
        }
    }

    private class C0009H extends Handler {
        private C0009H() {
        }

        public void handleMessage(Message msg) {
            switch (msg.what) {
                case 0:
                    if (FrameworkProxyService.this.checkBootAnimationComplete()) {
                        FrameworkProxyService.this.startModService();
                        return;
                    }
                    return;
                default:
                    return;
            }
        }
    }

    private boolean checkBootAnimationComplete() {
        if (!SystemService.isRunning("bootanim")) {
            return true;
        }
        this.mH.removeMessages(0);
        this.mH.sendEmptyMessageDelayed(0, 1000);
        return false;
    }

    private void startModService() {
        Intent it = new Intent("com.motorola.modservice.ACTION_BOOT");
        it.setComponent(IntentReceiver.MOD_SERVICE_NAME);
        startServiceAsUser(it, UserHandle.CURRENT);
    }

    public void onCreate() {
        this.mDockObserver = new DockObserver(this);
    }

    public int onStartCommand(Intent intent, int flags, int startId) {
        if ("com.motorola.mod.action.SERVICE_INIT".equals(intent.getAction())) {
            this.mH.sendEmptyMessage(0);
        }
        return 2;
    }

    public IBinder onBind(Intent intent) {
        return this.mFrameworkProxyBinder;
    }
}
