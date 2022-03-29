import * as React from 'react';
import { Button, View, Text } from 'react-native';

const Main = ({ navigation }) => {
  return (
    <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
      <Text>Unity Screen</Text>
      <Button
        title="Go to Unity"
        onPress={() => navigation.navigate('Unity')}
      />
    </View>
  );
};

export default Main;
