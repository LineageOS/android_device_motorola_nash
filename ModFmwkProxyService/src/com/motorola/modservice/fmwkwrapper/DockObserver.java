package com.motorola.modservice.fmwkwrapper;

import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.media.Ringtone;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.PowerManager;
import android.os.SystemClock;
import android.os.UserHandle;
import android.provider.Settings.Global;
import android.provider.Settings;
import android.util.Log;
import android.media.AudioManager;

class DockObserver {
    private final boolean mAllowTheaterModeWakeFromDock;
    private Context mContext;
    private final PowerManager mPowerManager;
    private int mPreviousDockState = 0;
    private int mReportedDockState = 0;

    DockObserver(Context context) {
        this.mContext = context;
        this.mPowerManager = (PowerManager) context.getSystemService(Context.POWER_SERVICE);
        this.mAllowTheaterModeWakeFromDock = context.getResources().getBoolean(com.android.internal.R.bool.config_allowTheaterModeWakeFromDock);
    }

    void setDockState(int newState) {
        if (newState != this.mReportedDockState) {
            this.mReportedDockState = newState;
            if (this.mAllowTheaterModeWakeFromDock
                || Settings.Global.getInt(this.mContext.getContentResolver(),
                                          Settings.Global.THEATER_MODE_ON, 0) == 0) {
                this.mPowerManager.wakeUp(SystemClock.uptimeMillis(),
                                          "android.server:DOCK");
            }
            handleDockStateChange();
        }
    }

    private void handleDockStateChange() {
        Log.i("ModDockObserver", "Dock state changed from " + this.mPreviousDockState + " to " + this.mReportedDockState);
        int previousDockState = this.mPreviousDockState;
        this.mPreviousDockState = this.mReportedDockState;
        ContentResolver cr = this.mContext.getContentResolver();
        if (Global.getInt(cr, Settings.Global.DEVICE_PROVISIONED, 0) == 0) {
            Log.i("ModDockObserver", "Device not provisioned, skipping dock broadcast");
            return;
        }
        Intent intent = new Intent(Intent.ACTION_DOCK_EVENT);
        intent.addFlags(Intent.FLAG_RECEIVER_REPLACE_PENDING);
        intent.putExtra(Intent.EXTRA_DOCK_STATE, this.mReportedDockState);
        if (Global.getInt(cr, Settings.Global.DOCK_SOUNDS_ENABLED, 1) == 1) {
            String whichSound = null;
            if (this.mReportedDockState == Intent.EXTRA_DOCK_STATE_UNDOCKED) {
                if ((previousDockState == Intent.EXTRA_DOCK_STATE_DESK) ||
                    (previousDockState == Intent.EXTRA_DOCK_STATE_LE_DESK) ||
                    (previousDockState == Intent.EXTRA_DOCK_STATE_HE_DESK)) {
                    whichSound = Settings.Global.DESK_UNDOCK_SOUND;
                } else if (previousDockState == 2) {
                    whichSound = Settings.Global.CAR_UNDOCK_SOUND;
                }
            } else if ((mReportedDockState == Intent.EXTRA_DOCK_STATE_DESK) ||
                       (mReportedDockState == Intent.EXTRA_DOCK_STATE_LE_DESK) ||
                       (mReportedDockState == Intent.EXTRA_DOCK_STATE_HE_DESK)) {
                whichSound = Settings.Global.DESK_DOCK_SOUND;
            } else if (mReportedDockState == Intent.EXTRA_DOCK_STATE_CAR) {
                whichSound = Settings.Global.CAR_DOCK_SOUND;
            }
            if (whichSound != null) {
                String soundPath = Global.getString(cr, whichSound);
                if (soundPath != null) {
                    Uri soundUri = Uri.parse("file://" + soundPath);
                    if (soundUri != null) {
                        Ringtone sfx = RingtoneManager.getRingtone(this.mContext, soundUri);
                        if (sfx != null) {
                            sfx.setStreamType(AudioManager.STREAM_SYSTEM);
                            sfx.play();
                        }
                    }
                }
            }
        }
        this.mContext.sendStickyBroadcastAsUser(intent, UserHandle.ALL);
    }
}
