## @azesmway/react-native-unity

The plugin that allows you to embed a UNITY project into the react native as a full-fledged component

### Installation

```sh
npm install @azesmway/react-native-unity

or

yarn add @azesmway/react-native-unity
```

### Usage

```js
import React, { useRef, useEffect } from 'react';
import UnityView from '@azesmway/react-native-unity';

interface IMessage {
  gameObject: string;
  methodName: string;
  message: string;
}

const Unity = () => {
  const unityRef = useRef();

  const message: IMessage = {
    gameObject: 'gameObject',
    methodName: 'methodName',
    message: 'message',
  };

  useEffect(() => {
    if (unityRef && unityRef.current) {
      unityRef.current.postMessage(message.gameObject, message.methodName, message.message);
    }
  }, []);

  return (
    <UnityView
      ref={unityRef}
      style={{ flex: 1 }}
      onUnityMessage={(result) =>
        console.log('onUnityMessage', result.nativeEvent.message)
      }
    />
  );
};

export default Unity;

```

### UNITY

1. Copy from folder "unity" to "Unity_Project_Name" folder and rebuild unity project.

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
    [DllImport("__Internal")]
    public static extern void sendMessageToMobileApp(string message);
}

public class ButtonBehavior : MonoBehaviour
{
    public void ButtonPressed()
    {
        NativeAPI.sendMessageToMobileApp("The button has been tapped!");
    }
}
```

### iOS

1. Build Unity app to `[project_root]/unity/builds/ios`
2. Add `Unity-iPhone.xcodeproj` to your workspace: `Menu` -> `File` -> `Add Files to [workspace_name]...` -> `[project_root]/unity/builds/ios/Unity-iPhone.xcodeproj`
3. Add `UnityFramework.framework` to `Frameworks, Libraries, and Embedded Content`:
4. Select Data folder and set a checkbox in the "Target Membership" section to "UnityFramework"
5. You need to select the NativeCallProxy.h inside the Libraries/Plugins/iOS folder of the Unity-iPhone project and change UnityFramework’s target membership from Project to Public. Don’t forget this step!
   https://miro.medium.com/max/1400/1*6v9KfxzR6olQNioUp_dFQQ.png

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
