
# react-native-video-helper

## Getting started

`$ npm install react-native-video-helper --save`

### Mostly automatic installation

`$ react-native link react-native-video-helper`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-video-helper` and add `RNVideoHelper.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNVideoHelper.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.reactlibrary.RNVideoHelperPackage;` to the imports at the top of the file
  - Add `new RNVideoHelperPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-video-helper'
  	project(':react-native-video-helper').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-video-helper/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-video-helper')
  	```

#### Windows
[Read it! :D](https://github.com/ReactWindows/react-native)

1. In Visual Studio add the `RNVideoHelper.sln` in `node_modules/react-native-video-helper/windows/RNVideoHelper.sln` folder to their solution, reference from their app.
2. Open up your `MainPage.cs` app
  - Add `using Video.Helper.RNVideoHelper;` to the usings at the top of the file
  - Add `new RNVideoHelperPackage()` to the `List<IReactPackage>` returned by the `Packages` method


## Usage
```javascript
import RNVideoHelper from 'react-native-video-helper';

// TODO: What to do with the module?
RNVideoHelper;
```
  