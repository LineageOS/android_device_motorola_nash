package com.motorola.fmwkwrapper;

import android.content.Intent;
import android.os.Binder;
import android.os.IBinder;
import android.os.IInterface;
import android.os.Parcel;
import android.os.RemoteException;
import android.os.UserHandle;

public interface IFrameworkProxyService extends IInterface {

    public static abstract class Stub extends Binder implements IFrameworkProxyService {
        public Stub() {
            attachInterface(this, "com.motorola.fmwkwrapper.IFrameworkProxyService");
        }

        public IBinder asBinder() {
            return this;
        }

        public boolean onTransact(int code, Parcel data, Parcel reply, int flags) throws RemoteException {
            String _arg0;
            String _arg1;
            UserHandle userHandle;
            switch (code) {
                case 1:
                    data.enforceInterface("com.motorola.fmwkwrapper.IFrameworkProxyService");
                    _arg0 = data.readString();
                    _arg1 = data.readString();
                    if (data.readInt() != 0) {
                        userHandle = (UserHandle) UserHandle.CREATOR.createFromParcel(data);
                    } else {
                        userHandle = null;
                    }
                    revokeRuntimePermission(_arg0, _arg1, userHandle);
                    reply.writeNoException();
                    return true;
                case 2:
                    data.enforceInterface("com.motorola.fmwkwrapper.IFrameworkProxyService");
                    _arg0 = data.readString();
                    _arg1 = data.readString();
                    if (data.readInt() != 0) {
                        userHandle = (UserHandle) UserHandle.CREATOR.createFromParcel(data);
                    } else {
                        userHandle = null;
                    }
                    grantRuntimePermission(_arg0, _arg1, userHandle);
                    reply.writeNoException();
                    return true;
                case 3:
                    Intent intent;
                    data.enforceInterface("com.motorola.fmwkwrapper.IFrameworkProxyService");
                    if (data.readInt() != 0) {
                        intent = (Intent) Intent.CREATOR.createFromParcel(data);
                    } else {
                        intent = null;
                    }
                    onModAttachDetach(intent);
                    reply.writeNoException();
                    return true;
                case 4:
                    data.enforceInterface("com.motorola.fmwkwrapper.IFrameworkProxyService");
                    addService(data.readString(), data.readStrongBinder());
                    reply.writeNoException();
                    return true;
                case 5:
                    data.enforceInterface("com.motorola.fmwkwrapper.IFrameworkProxyService");
                    setDockState(data.readInt());
                    reply.writeNoException();
                    return true;
                case 1598968902:
                    reply.writeString("com.motorola.fmwkwrapper.IFrameworkProxyService");
                    return true;
                default:
                    return super.onTransact(code, data, reply, flags);
            }
        }
    }

    void addService(String str, IBinder iBinder) throws RemoteException;

    void grantRuntimePermission(String str, String str2, UserHandle userHandle) throws RemoteException;

    void onModAttachDetach(Intent intent) throws RemoteException;

    void revokeRuntimePermission(String str, String str2, UserHandle userHandle) throws RemoteException;

    void setDockState(int i) throws RemoteException;
}
