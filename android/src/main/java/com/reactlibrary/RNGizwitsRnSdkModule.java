
package com.reactlibrary;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;

public class RNGizwitsRnSdkModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;

  public RNGizwitsRnSdkModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  @Override
  public String getName() {
    return "RNGizwitsRnSdk";
  }
  @ReactMethod
  public void startWithAppID(String appid, Callback callback) {
      callback.invoke(null, appid);
  }
}