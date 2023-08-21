package io.flutter.plugins;
import android.annotation.SuppressLint;
import android.content.Context;
import android.hardware.SensorManager;
import android.util.Log;
import android.view.OrientationEventListener;
import android.view.Surface;

import java.lang.reflect.Constructor;
import java.lang.reflect.Field;

public class ScreenOrientationListener extends OrientationEventListener {
    private static final String TAG = ScreenOrientationListener.class.getSimpleName();
    private int mOrientation;
    private OnOrientationChangedListener mOnOrientationChangedListener;
    private Context mContext;
    private Field mFieldRotation;
    private Object mOLegacy;

    public ScreenOrientationListener(Context context) {
        super(context);
        mContext = context;
    }

    public void setOnOrientationChangedListener(OnOrientationChangedListener listener) {
        this.mOnOrientationChangedListener = listener;
    }

    public int getOrientation() {
        int rotation = -1;
        try {
            if (null == mFieldRotation) {
                SensorManager sensorManager = (SensorManager) mContext.getSystemService(Context.SENSOR_SERVICE);
                Class clazzLegacy = Class.forName("android.hardware.LegacySensorManager");
                Constructor constructor = clazzLegacy.getConstructor(SensorManager.class);
                constructor.setAccessible(true);
                mOLegacy = constructor.newInstance(sensorManager);
                mFieldRotation = clazzLegacy.getDeclaredField("sRotation");
                mFieldRotation.setAccessible(true);
            }
            rotation = mFieldRotation.getInt(mOLegacy);
        } catch (Exception e) {
            Log.e(TAG, "getRotation e=" + e.getMessage());
            e.printStackTrace();
        }
//        Log.d(TAG, "getRotation rotation=" + rotation);

        int orientation = -1;
        switch (rotation) {
            case Surface.ROTATION_0:
                orientation = 0;
                break;
            case Surface.ROTATION_90:
                orientation = 90;
                break;
            case Surface.ROTATION_180:
                orientation = 180;
                break;
            case Surface.ROTATION_270:
                orientation = 270;
                break;
            default:
                break;
        }
//        Log.d(TAG, "getRotation orientation=" + orientation);
        return orientation;
    }

    @Override
    public void onOrientationChanged(int orientation) {
        if (orientation == OrientationEventListener.ORIENTATION_UNKNOWN) {
            return; // 手机平放时，检测不到有效的角度
        }
        orientation = getOrientation();
        if (mOrientation != orientation) {
            mOrientation = orientation;
            if (null != mOnOrientationChangedListener) {
                mOnOrientationChangedListener.onOrientationChanged(mOrientation);
                Log.d(TAG, "ScreenOrientationListener onOrientationChanged orientation=" + mOrientation);
            }
        }
    }

    public interface OnOrientationChangedListener {
        void onOrientationChanged(int orientation);
    }
}
