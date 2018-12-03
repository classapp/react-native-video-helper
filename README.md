
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

## Usage
```javascript
import RNVideoHelper from 'react-native-video-helper';

const sourceUri = 'assets-library://asset/asset.mov?id=0F3F0000-9518-4F32-B389-7117F4C2B069&ext=mov';

RNVideoHelper.compress(sourceUri, {
	startTime: 10, // optional, in seconds, defaults to 0
	endTime: 100, //  optional, in seconds, defaults to video duration
	bitrate: 1200000, // optional
	removeAudio: true, // default false
	width: 100, // defaults to original video width
	height: 50, // defaults to original video height
}).progress(value => {
	console.warn('progress', value); // Int with progress value from 0 to 1
}).then(compressedUri => {
	console.warn('compressedUri', compressedUri); // String with path to temporary compressed video
});
```
  