import { NativeEventEmitter, NativeModules } from 'react-native';
const { RNVideoHelper } = NativeModules;

const videoManagerEmitter = new NativeEventEmitter(RNVideoHelper);

RNVideoHelper.emitter = videoManagerEmitter;
RNVideoHelper.on = videoManagerEmitter.addListener;

export default RNVideoHelper;

// ...
// // Don't forget to unsubscribe, typically in componentWillUnmount
// subscription.remove();