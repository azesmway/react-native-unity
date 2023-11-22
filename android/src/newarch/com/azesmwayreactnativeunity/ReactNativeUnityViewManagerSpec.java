package com.azesmwayreactnativeunity;

import android.view.View;

import androidx.annotation.Nullable;

import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ViewManagerDelegate;
import com.facebook.react.viewmanagers.RNUnityViewManagerDelegate;
import com.facebook.react.viewmanagers.RNUnityViewManagerInterface;

public abstract class ReactNativeUnityViewManagerSpec<T extends View> extends SimpleViewManager<T> implements RNUnityViewManagerInterface<T> {
  private final ViewManagerDelegate<T> mDelegate;

  public ReactNativeUnityViewManagerSpec() {
    mDelegate = new RNUnityViewManagerDelegate<>(this);
  }

  @Nullable
  @Override
  protected ViewManagerDelegate<T> getDelegate() {
    return mDelegate;
  }
}
