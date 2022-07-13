package com.azesmwayreactnativeunity;

import android.app.Activity;
import android.graphics.PixelFormat;
import android.os.Build;
import android.view.ViewGroup;
import android.view.WindowManager;

import com.unity3d.player.UnityPlayer;
import com.unity3d.player.IUnityPlayerLifecycleEvents;
import static android.view.ViewGroup.LayoutParams.MATCH_PARENT;

public class ReactNativeUnity {
    private static UnityPlayer unityPlayer;
    public static boolean _isUnityReady;
    public static boolean _isUnityPaused;
    public static boolean _fullScreen;

    public static UnityPlayer getPlayer() {
        if (!_isUnityReady) {
            return null;
        }
        return unityPlayer;
    }

    public static boolean isUnityReady() {
        return _isUnityReady;
    }

    public static boolean isUnityPaused() {
        return _isUnityPaused;
    }

    public static void createPlayer(final Activity activity, final UnityPlayerCallback callback) {
        if (unityPlayer != null) {
            callback.onReady();
            return;
        }
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                activity.getWindow().setFormat(PixelFormat.RGBA_8888);
                int flag = activity.getWindow().getAttributes().flags;
                boolean fullScreen = false;
                if ((flag & WindowManager.LayoutParams.FLAG_FULLSCREEN) == WindowManager.LayoutParams.FLAG_FULLSCREEN) {
                    fullScreen = true;
                }

                unityPlayer = new UnityPlayer(activity, new IUnityPlayerLifecycleEvents() {
                  @Override
                  public void onUnityPlayerUnloaded() {
                    callback.onUnload();
                  }

                  @Override
                  public void onUnityPlayerQuitted() {
                    callback.onQuit();
                  }
                });

                try {
                    // wait a moment. fix unity cannot start when startup.
                    Thread.sleep(1000);
                } catch (Exception e) {
                }

                // start unity
                addUnityViewToBackground();
                unityPlayer.windowFocusChanged(true);
                unityPlayer.requestFocus();
                unityPlayer.resume();

                // restore window layout
                if (!fullScreen) {
                    activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_FORCE_NOT_FULLSCREEN);
                    activity.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
                }
                _isUnityReady = true;
                callback.onReady();
            }
        });
    }

    public static void pause() {
        if (unityPlayer != null) {
            unityPlayer.pause();
            _isUnityPaused = true;
        }
    }

    public static void resume() {
        if (unityPlayer != null) {
            unityPlayer.resume();
            _isUnityPaused = false;
        }
    }

    public static void unload() {
        if (unityPlayer != null) {
            unityPlayer.unload();
            _isUnityPaused = false;
        }
    }

    public static void addUnityViewToBackground() {
        if (unityPlayer == null) {
            return;
        }
        if (unityPlayer.getParent() != null) {
            ((ViewGroup) unityPlayer.getParent()).removeView(unityPlayer);
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            unityPlayer.setZ(-1f);
        }
        final Activity activity = ((Activity) unityPlayer.getContext());
        ViewGroup.LayoutParams layoutParams = new ViewGroup.LayoutParams(1, 1);
        activity.addContentView(unityPlayer, layoutParams);
    }

    public static void addUnityViewToGroup(ViewGroup group) {
        if (unityPlayer == null) {
            return;
        }
        if (unityPlayer.getParent() != null) {
            ((ViewGroup) unityPlayer.getParent()).removeView(unityPlayer);
        }
        ViewGroup.LayoutParams layoutParams = new ViewGroup.LayoutParams(MATCH_PARENT, MATCH_PARENT);
        group.addView(unityPlayer, 0, layoutParams);
        unityPlayer.windowFocusChanged(true);
        unityPlayer.requestFocus();
        unityPlayer.resume();
    }

    public interface UnityPlayerCallback {
        void onReady();
        void onUnload();
        void onQuit();
    }
}
