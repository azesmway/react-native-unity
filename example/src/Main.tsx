import { StackActions, useNavigation } from '@react-navigation/native'
import * as React from 'react'
import { Button, Text, View } from 'react-native'

const Main = () => {
  const navigation = useNavigation()

  return (
    <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
      <Text>Unity Screen</Text>
      <Button
        title="Go to Unity"
        onPress={() => {
          const pushAction = StackActions.push('Unity', {})

          navigation.dispatch(pushAction)
        }}
      />
    </View>
  )
}

export default Main
