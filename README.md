# @azesmway/react-native-unity

The plugin that allows you to embed a UNITY project into the react native as a full-fledged component

# Installation

## RN

```sh
npm install @azesmway/react-native-unity

or

yarn add @azesmway/react-native-unity
```

## Unity

1. Copy from folder "unity" to <Unity_Project_Name> folder and rebuild unity project.

#### OnEvent in Unity

Add this code:

```js

using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine.UI;
using UnityEngine;

public class NativeAPI {
#if UNITY_IOS && !UNITY_EDITOR
  [DllImport("__Internal")]
  public static extern void sendMessageToMobileApp(string message);
#endif
}

public class ButtonBehavior : MonoBehaviour
{
  public void ButtonPressed()
  {
    if (Application.platform == RuntimePlatform.Android)
    {
      using (AndroidJavaClass jc = new AndroidJavaClass("com.azesmwayreactnativeunity.ReactNativeUnityViewManager"))
      {
        jc.CallStatic("sendMessageToMobileApp", "The button has been tapped!");
      }
    }
    else if (Application.platform == RuntimePlatform.IPhonePlayer)
    {
#if UNITY_IOS && !UNITY_EDITOR
      NativeAPI.sendMessageToMobileApp("The button has been tapped!");
#endif
    }
  }
}

```

## iOS

1. Build Unity app to `[project_root]/unity/builds/ios`
2. Add `Unity-iPhone.xcodeproj` to your XCode: press the right mouse button in the Left Navigator XCode -> `Add Files to [project_name]...` -> `[project_root]/unity/builds/ios/Unity-iPhone.xcodeproj`
3. Add `UnityFramework.framework` to `General` / section `Frameworks, Libraries, and Embedded Content`
4. Select Data folder and set a checkbox in the "Target Membership" section to "UnityFramework"
5. You need to select the NativeCallProxy.h inside the `Unity-iPhone/Libraries/Plugins/iOS` folder of the Unity-iPhone project and change UnityFramework’s target membership from Project to Public. Don’t forget this step! https://miro.medium.com/max/1400/1*6v9KfxzR6olQNioUp_dFQQ.png
6. In `Build Phases` remove UnityFramework.framework from `Linked Binary With Libraries`
7. In Build Phases move Embedded Frameworks before Compile Sources ( drag and drop )

### Android

1. Export Unity app to `[project_root]/unity/builds/android`
2. Add the following lines to `android/settings.gradle`:
   ```gradle
   include ':unityLibrary'
   project(':unityLibrary').projectDir=new File('..\\unity\\builds\\android\\unityLibrary')
   ```
3. Add into `android/build.gradle`
    ```gradle
    allprojects {
      repositories {
        // this
        flatDir {
            dirs "${project(':unityLibrary').projectDir}/libs"
        }
    // ...
    ```
4. Add into `android/gradle.properties`
    ```gradle
    unityStreamingAssets=.unity3d
    ```
5. Add strings to ``android/app/src/main/res/values/strings.xml``

    ```javascript
    <string name="game_view_content_description">Game view</string>
    ```
6. Remove `<intent-filter>...</intent-filter>` from ``<project_name>/unity/builds/android/unityLibrary/src/main/AndroidManifest.xml`` at unityLibrary to leave only integrated version.

# Known issues

- Works only on real iOS devices.  Android emulators are capable of showing the UnityView.
- On IOS the Unity view is waiting for a parent with dimensions greater than 0 (from RN side). Please take care of this because if it is not the case, your app will crash with the native message `MTLTextureDescriptor has width of zero`.

# Usage

## Sample code

```js
import React, { useRef, useEffect } from 'react';

import UnityView from '@azesmway/react-native-unity';
import { View } from 'react-native';

interface IMessage {
  gameObject: string;
  methodName: string;
  message: string;
}

const Unity = () => {
  const unityRef = useRef<UnityView>(null);

  useEffect(() => {
    if (unityRef?.current) {
      const message: IMessage = {
        gameObject: 'gameObject',
        methodName: 'methodName',
        message: 'message',
      };
      unityRef.current.postMessage(message.gameObject, message.methodName, message.message);
    }
  }, []);

  return (
    <View style={{ flex: 1 }}>
      <UnityView
        ref={unityRef}
        style={{ flex: 1 }}
        onUnityMessage={(result) => {
          console.log('onUnityMessage', result.nativeEvent.message)
        }}
      />
    </View>
  );
};

export default Unity;

```

## Props
- `androidKeepPlayerMounted?: boolean` - if set to true, keep the player mounted even when the view that contains it has lost focus.  The player will be paused on blur and resumed on focus.  **FOR ANDROID:** has no effect on iOS.
- `fullScreen?: boolean` - defaults to true.  If set to false, will not request full screen access.  **ANDROID ONLY**
- `onUnityMessage?: (event: NativeSyntheticEvent)` - receives a message from a Unity
- `style: ViewStyle` - styles the UnityView.  (Won't show on Android without dimensions.  Recommended to give it `flex: 1` as in the example)

## Methods
- `postMessage(gameObject, methodName, message)` - sends a message to the Unity. **FOR IOS:** The native method of unity is used to send a message
`sendMessageToGOWithName:(const char*)goName functionName:(const char*)name message:(const char*)msg;`, more details can be found in the [documentation](https://docs.unity3d.com/2021.1/Documentation/Manual/UnityasaLibrary-iOS.html)

- `unloadUnity()` - the Unity is unloaded automatically when the react-native component is unmounted, but if you want to unload the Unity, you can call this method
- `pauseUnity?: (pause: boolean)` - pause the Unity

# Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

# License

MIT
