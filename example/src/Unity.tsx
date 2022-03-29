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
    setTimeout(() => {
      if (unityRef && unityRef.current) {
        unityRef.current.postMessage(
          message.gameObject,
          message.methodName,
          message.message
        );
      }
    }, 6000);
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
