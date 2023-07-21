//@ts-ignore we want to ignore everything
// else in global except what we need to access.
// Maybe there is a better way to do this.
import { NativeModules } from 'react-native';

const { RNGizwitsRnSdk, RNGizwitsRnDevice } = NativeModules;

// Installing JSI Bindings as done by
// https://github.com/mrousavy/react-native-mmkv

//@ts-ignore
const RNGizwitsRnSdkJSI: {
  setSubscribe(did: string, mac: string, productKey: string, ps: string, subscribed: bool): void;
  getVersion(): string;
  //@ts-ignore
} = global;

export function isLoaded() {
  return typeof RNGizwitsRnSdkJSI.getVersion === 'function';
}

export function isDeviceLoaded() {
  return typeof RNGizwitsRnSdkJSI.setSubscribe === 'function';
}

if (!isLoaded()) {
  const result = RNGizwitsRnSdk?.install();
  if (!result && !isLoaded())
    throw new Error('JSI bindings were not installed for: RNGizwitsRnSdk Module');

  if (!isLoaded()) {
    throw new Error('JSI bindings were not installed for: RNGizwitsRnSdk Module');
  }
}
if (!isDeviceLoaded()) {
  const result = RNGizwitsRnDevice?.install();
  if (!result && !isDeviceLoaded())
    throw new Error('JSI bindings were not installed for: RNGizwitsRnDevice Module');

  if (!isDeviceLoaded()) {
    throw new Error('JSI bindings were not installed for: RNGizwitsRnDevice Module');
  }
}

function debounce(func, delay) {
  let timeoutId;

  return function (...args) {
    clearTimeout(timeoutId);

    timeoutId = setTimeout(() => {
      func.apply(this, args);
    }, delay);
  };
}
const callbacks = {
    "GizDeviceListNotifications": () => {},
    "GizDeviceNetStatusNotifications": () => {},
    "GizDeviceStatusNotifications": () => {},
    "GizBleDeviceListNotifications": () => {},

}
RNGizwitsRnSdkJSI.addListener = (name, callback) => {
    callbacks[name] = callback
}

global.GizDeviceListNotifications = debounce((data) => {
   callbacks["GizDeviceListNotifications"] && callbacks["GizDeviceListNotifications"](JSON.parse(data))
}, 600)

global.GizBleDeviceListNotifications = debounce((data) => {
   callbacks["GizBleDeviceListNotifications"] && callbacks["GizBleDeviceListNotifications"](JSON.parse(data))
}, 600)

global.GizDeviceStatusNotifications = (data) => {
   callbacks["GizDeviceStatusNotifications"] && callbacks["GizDeviceStatusNotifications"](JSON.parse(data))
}

global.GizDeviceNetStatusNotifications = (...args) => {
   callbacks["GizDeviceNetStatusNotifications"] && callbacks["GizDeviceNetStatusNotifications"](...args)
}



export default RNGizwitsRnSdk;
export {RNGizwitsRnSdk, RNGizwitsRnDevice, RNGizwitsRnSdkJSI};
