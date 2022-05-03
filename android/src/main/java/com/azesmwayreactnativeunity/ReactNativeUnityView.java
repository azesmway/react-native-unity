package com.azesmwayreactnativeunity;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.res.Configuration;
import android.os.Build;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import androidx.annotation.NonNull;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.facebook.react.views.view.ReactViewGroup;
import com.unity3d.player.UnityPlayer;
import static android.view.ViewGroup.LayoutParams.MATCH_PARENT;
import java.util.Objects;

@SuppressLint("ViewConstructor")
public class ReactNativeUnityView extends FrameLayout {
    private UnityPlayer view;
    public boolean keepPlayerMounted = false;

    public ReactNativeUnityView(Context context) {
        super(context);
    }

    public void setUnityPlayer(UnityPlayer player) {
        this.view = player;
        ReactNativeUnity.addUnityViewToGroup(this);
    }

    @Override
    public void onWindowFocusChanged(boolean hasWindowFocus) {
        super.onWindowFocusChanged(hasWindowFocus);
        if (view == null) {
            return;
        }
        view.windowFocusChanged(hasWindowFocus);

        if (!keepPlayerMounted || !ReactNativeUnity._isUnityReady) {
            return;
        }

        // pause Unity on blur, resume on focus
        if (hasWindowFocus && ReactNativeUnity._isUnityPaused) {
            view.requestFocus();
            view.resume();
        } else if (!hasWindowFocus && !ReactNativeUnity._isUnityPaused) {
            view.pause();
        }
    }

    @Override
    protected void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        if (view != null) {
            view.configurationChanged(newConfig);
        }
    }

    @Override
    protected void onDetachedFromWindow() {
        if (!this.keepPlayerMounted) {
            ReactNativeUnity.addUnityViewToBackground();
        }
        super.onDetachedFromWindow();
    }
}
