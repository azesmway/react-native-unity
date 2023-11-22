package com.azesmwayreactnativeunity;

import android.view.View;

import androidx.annotation.Nullable;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.SimpleViewManager;

public abstract class ReactNativeUnityViewManagerSpec<T extends View> extends SimpleViewManager<T> {
  public abstract void postMessage(T view, String gameObject, String methodName, String message);
  public abstract void setAndroidKeepPlayerMounted(T view, boolean value);
  public abstract void setFullScreen(T view, boolean value);
  public abstract void unloadUnity(T view);
  public abstract void pauseUnity(T view, boolean pause);
  public abstract void resumeUnity(T view);
  public abstract void windowFocusChanged(T view, boolean hasFocus);
}
