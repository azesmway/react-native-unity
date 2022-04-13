import React, {useRef, useEffect} from 'react';
import {View} from 'react-native';
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
    setTimeout(() => {
      if (unityRef && unityRef.current) {
        unityRef.current.postMessage(
          message.gameObject,
          message.methodName,
          message.message,
        );
      }
    }, 6000);
  }, []);

  return (
    // If you wrap your UnityView inside a parent, please take care to set dimensions to it (with `flex:1` for example).
    // See the `Know issues` part in the README.
    <View style={{flex: 1}}> 
      <UnityView
        ref={unityRef}
        style={{flex: 1}}
        onUnityMessage={result =>
          console.log('onUnityMessage', result.nativeEvent.message)
        }
      />
    </View>
  );
};

export default Unity;
