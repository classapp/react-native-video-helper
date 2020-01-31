
# react-native-video-helper

## Getting started

`$ npm install react-native-video-helper --save`

## Supported versions

| React-Native Version  | Video-Helper Supported Version  |
|---|---|
| RN >= 0.60 | >= 1.4.3  |

## If you are using react-native before 0.60 version, you can link using:

### Automatic installation

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

## Usage
```javascript
import RNVideoHelper from 'react-native-video-helper';

const sourceUri = 'assets-library://asset/asset.mov?id=0F3F0000-9518-4F32-B389-7117F4C2B069&ext=mov';

RNVideoHelper.compress(sourceUri, {
	startTime: 10, // optional, in seconds, defaults to 0
	endTime: 100, //  optional, in seconds, defaults to video duration
	quality: 'low', // default low, can be medium or high
	bitRate:1.3*1000*1000 //default low:1.3M,medium:1.9M,high:2.6M
	defaultOrientation: 0 // By default is 0, some devices not save this property in metadata. Can be between 0 - 360
}).progress(value => {
	console.warn('progress', value); // Int with progress value from 0 to 1
}).then(data => {
        //data.path the file path
        //data.size the file size at bit
        //data.width the video width
        //data.height the video height
        //data.duration the video duration
        //data.mime the file mime type
	console.warn('compressedUri', data); // String with path to temporary compressed video
});
```
  