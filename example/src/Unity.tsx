import UnityView from '@azesmway/react-native-unity'
import React, { useEffect, useRef } from 'react'
import { View } from 'react-native'

interface IMessage {
  gameObject: string
  methodName: string
  message: string
}

const Unity = () => {
  const unityRef = useRef()
  const message: IMessage = {
    gameObject: '[Scripts]',
    methodName: 'InitModule',
    message: '{"scene": "GeoPoints"}'
  }

  useEffect(() => {
    setTimeout(() => {
      if (unityRef && unityRef.current) {
        // @ts-ignore
        unityRef.current.postMessage(message.gameObject, message.methodName, message.message)
      }
    }, 6000)

    return () => console.log('unmount')
  }, [])

  return (
    // If you wrap your UnityView inside a parent, please take care to set dimensions to it (with `flex:1` for example).
    // See the `Know issues` part in the README.
    <View style={{ flex: 1 }}>
      <UnityView
        // @ts-ignore
        ref={unityRef}
        style={{ flex: 1 }}
        onUnityMessage={(result: any) => console.log('onUnityMessage ===> ', result.nativeEvent.message)}
      />
    </View>
  )
}

export default Unity
