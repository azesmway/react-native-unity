const {
  AndroidConfig,
  withProjectBuildGradle,
  withDangerousMod,
  withGradleProperties,
  withSettingsGradle,
  withStringsXml,
} = require('@expo/config-plugins');
const fs = require('fs');
const path = require('path');

const withUnity = (config, { name = 'react-native-unity' } = {}) => {
  config.name = name;
  config = withProjectBuildGradleMod(config);
  config = withSettingsGradleMod(config);
  config = withGradlePropertiesMod(config);
  config = withStringsXMLMod(config);
  config = withPodfileDangerousMod(config);
  return config;
};

const REPOSITORIES_END_LINE = `maven { url 'https://www.jitpack.io' }`;

const withProjectBuildGradleMod = (config) =>
  withProjectBuildGradle(config, (modConfig) => {
    if (modConfig.modResults.contents.includes(REPOSITORIES_END_LINE)) {
      // use the last known line in expo's build.gradle file to append the newline after
      modConfig.modResults.contents = modConfig.modResults.contents.replace(
        REPOSITORIES_END_LINE,
        REPOSITORIES_END_LINE +
          '\nflatDir { dirs "${project(\':unityLibrary\').projectDir}/libs" }\n'
      );
    } else {
      throw new Error(
        'Failed to find the end of repositories in the android/build.gradle file`'
      );
    }
    return modConfig;
  });

const withSettingsGradleMod = (config) =>
  withSettingsGradle(config, (modConfig) => {
    modConfig.modResults.contents += `
    include ':unityLibrary'
    project(':unityLibrary').projectDir=new File('../unity/builds/android/unityLibrary')
        `;
    return modConfig;
  });

const withGradlePropertiesMod = (config) =>
  withGradleProperties(config, (modConfig) => {
    modConfig.modResults.push({
      type: 'property',
      key: 'unityStreamingAssets',
      value: '.unity3d',
    });
    return modConfig;
  });

// add string
const withStringsXMLMod = (config) =>
  withStringsXml(config, (modConfig) => {
    modConfig.modResults = AndroidConfig.Strings.setStringItem(
      [
        {
          _: 'Game View',
          $: {
            name: 'game_view_content_description',
          },
        },
      ],
      modConfig.modResults
    );
    return modConfig;
  });

/*
        Adjust the Podfile to exclude arm64 architecture for simulator builds
        for all the pods in the project
        This is also necessary in order to get the Unity project to build for simulator
        */
const withPodfileDangerousMod = (config) =>
  withDangerousMod(config, [
    'ios',
    (modConfig) => {
      /*
            We need to do a 'dangerous' mod to the Podfile
            and add lines to the post install hook to exclude arm64 architecture for simulator builds
            */
      const file = path.join(
        modConfig.modRequest.platformProjectRoot,
        'Podfile'
      );
      const contents = fs.readFileSync(file).toString();

      // look for the closing bracket of the `react_native_post_install` block, insert stuff on the following lines
      const regex = /react_native_post_install\([^)]+\)\s*/;
      const newLine = `
      installer.pods_project.build_configurations.each do |config|
        config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
      end\n\n`;

      const newContents = contents.replace(regex, '$&\n' + newLine);
      fs.writeFileSync(file, newContents);
      return modConfig;
    },
  ]);

module.exports = withUnity;
