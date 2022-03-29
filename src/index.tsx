import {
  requireNativeComponent,
  UIManager,
  Platform,
  ViewStyle,
} from 'react-native';

const LINKING_ERROR =
  `The package '@azesmway/react-native-unity' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo managed workflow\n';

type ReactNativeUnityProps = {
  color: string;
  style: ViewStyle;
};

const ComponentName = 'ReactNativeUnityView';

export const ReactNativeUnityView =
  UIManager.getViewManagerConfig(ComponentName) != null
    ? requireNativeComponent<ReactNativeUnityProps>(ComponentName)
    : () => {
        throw new Error(LINKING_ERROR);
      };
