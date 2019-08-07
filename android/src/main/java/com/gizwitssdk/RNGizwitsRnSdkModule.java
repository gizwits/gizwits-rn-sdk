
package com.gizwitssdk;

import android.os.Environment;
import android.text.TextUtils;
import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableMapKeySetIterator;
import com.facebook.react.bridge.ReadableType;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.gizwits.gizwifisdk.api.GizLiteGWSubDevice;
import com.gizwits.gizwifisdk.api.GizWifiDevice;
import com.gizwits.gizwifisdk.api.GizWifiSDK;
import com.gizwits.gizwifisdk.enumration.GizAdapterType;
import com.gizwits.gizwifisdk.enumration.GizEventType;
import com.gizwits.gizwifisdk.enumration.GizMeshVendor;
import com.gizwits.gizwifisdk.enumration.GizPushType;
import com.gizwits.gizwifisdk.enumration.GizWifiConfigureMode;
import com.gizwits.gizwifisdk.enumration.GizWifiDeviceNetStatus;
import com.gizwits.gizwifisdk.enumration.GizWifiDeviceType;
import com.gizwits.gizwifisdk.enumration.GizWifiErrorCode;
import com.gizwits.gizwifisdk.enumration.GizWifiGAgentType;
import com.gizwits.gizwifisdk.listener.GizWifiSDKListener;
import com.gizwits.gizwifisdk.log.SDKLog;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.FileInputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;
import java.util.Map;



public class RNGizwitsRnSdkModule extends ReactContextBaseJavaModule {
    final String moduleVersion = "1.3.1";

    private Callback startWithAppIdCallback;
    private Callback getCurrentCloudService;
    private Callback getBoundDevicesCallback;
    private Callback deviceSafetyUnbindCallback;
    private Callback deviceSafeRegistCallback;
    private Callback addGroupCallback;
    private Callback changeMeshNameCallback;
    private Callback discoverMeshDevicesCallback;
    private Callback unbindDeviceCallback;
    private Callback cbChannelIDBindCallback;
    private List<Callback> setOnboardingCallback=new ArrayList<>();
    private List<Callback> bindRemoteDeviceCallback = new ArrayList<>();

    private final ReactApplicationContext reactContext;

    GizWifiSDKListener gizWifiSDKListener = new GizWifiSDKListener() {
        @Override
        public void didNotifyEvent(GizEventType eventType, Object eventSource, GizWifiErrorCode eventID, String eventMessage) {
//            WritableMap result = Arguments.createMap();
//            result.putInt("errorCode", eventID.getResult());
//            result.putString("msg", eventID.name());
//            SDKLog.d("eventType: " + eventType + ", result: " + result);
//            WritableMap eventNotify = Arguments.createMap();
//            eventNotify.putMap(eventType.name(), result);
//            callbackNofitication(eventNotify);
//            if (startWithAppIdCallback != null) {
//                if (eventID.getResult() == GizWifiErrorCode.GIZ_SDK_START_SUCCESS.getResult()) {
//                    callback(startWithAppIdCallback, result, null);
//                } else {
//                    callback(startWithAppIdCallback, result, null);
//                }
//            }
            try {
                JSONObject result = new JSONObject();
                result.put("errorCode", eventID.getResult());
                result.put("msg", eventID.name());

                SDKLog.d("eventType: " + eventType + ", result: " + result);


                JSONObject eventNotify = new JSONObject();
                eventNotify.put(eventType.name(), result);
                callbackNofitication(eventNotify);


//
                if (startWithAppIdCallback != null) {
                    if (eventID.getResult() == GizWifiErrorCode.GIZ_SDK_START_SUCCESS.getResult()) {
                        sendResultEvent(startWithAppIdCallback, result, null);
                    } else {
                        sendResultEvent(startWithAppIdCallback, null, result);
                    }
                }

            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void didGetCurrentCloudService(GizWifiErrorCode result, ConcurrentHashMap<String, String> cloudServiceInfo) {
            try {
                JSONObject result_obj = new JSONObject();
                if (result == GizWifiErrorCode.GIZ_SDK_SUCCESS && cloudServiceInfo != null) {
                    result_obj.put("openAPIDomain", cloudServiceInfo.get("openAPIDomain"));
                    result_obj.put("openAPIPort", cloudServiceInfo.get("openAPIPort"));
                    result_obj.put("siteDomain", cloudServiceInfo.get("siteDomain"));
                    result_obj.put("sitePort", cloudServiceInfo.get("sitePort"));

                    sendResultEvent(getCurrentCloudService, result_obj, null);
                } else {
                    result_obj.put("errorCode", result.getResult());
                    result_obj.put("msg", result.name());
                    sendResultEvent(getCurrentCloudService, null, result_obj);
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

//        @Override
//        public void didReceiveDeviceLog(GizWifiErrorCode result, String mac, int timestamp, int logSN, String log) {
//            super.didReceiveDeviceLog(result, mac, timestamp, logSN, log);
//            try {
//                JSONObject result_obj = new JSONObject();
//
//                if (result == GizWifiErrorCode.GIZ_SDK_SUCCESS) {
//                    result_obj.put("mac", mac);
//                    result_obj.put("timestamp", timestamp);
//                    result_obj.put("logSN", logSN);
//                    result_obj.put("log", log);
//                } else {
//                    result_obj.put("errorCode", result.getResult());
//                    result_obj.put("msg", result.name());
//                }
//                callbackDeviceLogNofitication(result_obj);
//            } catch (JSONException e) {
//                e.printStackTrace();
//            }
//        }

        @Override
        public void didDiscovered(GizWifiErrorCode result, List<GizWifiDevice> deviceList) {
            /*
             * if (getBoundDevicesModuleContext == null) {
             * SDKLog.d("module context is null"); return; }
             *
             * SDKLog.d("moduleContext hashCode = " +
             * getBoundDevicesModuleContext.hashCode() + ", sdkListener = " +
             * this + ", result = " + result);
             */
            JSONObject jsonResult = new JSONObject();
            try {
                // 设置设备监听

                // 返回设备对象数组
                JSONArray devicesjson = new JSONArray();
                for (GizWifiDevice device : deviceList) {

                    JSONObject deviceobj = new JSONObject();
                    deviceobj.put("mac", device.getMacAddress());
                    deviceobj.put("did", device.getDid());
                    deviceobj.put("productKey", device.getProductKey());
                    deviceobj.put("productName", device.getProductName());
                    deviceobj.put("ip", device.getIPAddress());
                    deviceobj.put("passcode", device.getPasscode());
                    deviceobj.put("isConnected", device.isConnected());
                    deviceobj.put("isOnline", device.isOnline());
                    deviceobj.put("isLAN", device.isLAN());
                    deviceobj.put("isDisabled", device.isDisabled());
                    deviceobj.put("remark", device.getRemark());
                    deviceobj.put("alias", device.getAlias());
                    deviceobj.put("isBind", device.isBind());
                    deviceobj.put("netType", device.getNetType());
                    if(device instanceof GizLiteGWSubDevice) {
                        deviceobj.put("meshID",((GizLiteGWSubDevice)device).getMeshId());
                    }
                    deviceobj.put("rootDeviceId", device.getRootDevice() == null ? "" : device.getRootDevice().getDid());
                    deviceobj.put("isProductDefined", device.isProductDefined());
                    deviceobj.put("isSubscribed", device.isSubscribed());
                    deviceobj.put("productAdapterUi", device.getProductUI());
                    deviceobj.put("productKeyAdapter", device.getProductKeyAdapter());
                    int type = 0;
                    if (device.getProductType() == GizWifiDeviceType.GizDeviceCenterControl) {
                        type = 1;
                    }
                    deviceobj.put("type", type);

                    int netStatus = 0;
                    if (device.getNetStatus() == GizWifiDeviceNetStatus.GizDeviceOnline) {
                        netStatus = 1;
                    } else if (device.getNetStatus() == GizWifiDeviceNetStatus.GizDeviceControlled) {
                        netStatus = 2;
                    }
                    deviceobj.put("netStatus", netStatus);
                    devicesjson.put(deviceobj);
                }
                jsonResult.put("devices", devicesjson);

                // 只做成功的回调，但错误码不一定为0

                if (result == GizWifiErrorCode.GIZ_SDK_SUCCESS) {

                    sendResultEvent(getBoundDevicesCallback, jsonResult, null);
                } else {
                    JSONObject error = new JSONObject();
                    error.put("errorCode", result.getResult());
                    error.put("msg", result.name());
                    sendResultEvent(getBoundDevicesCallback, jsonResult, null);
                }


                if (result == GizWifiErrorCode.GIZ_SDK_SUCCESS) {
                    callbackNofitication(jsonResult);
                } else {
                    SDKLog.d("notifyModuleContext is null");
                }

            } catch (JSONException e) {
                e.printStackTrace();
            }

        }

        @Override
        public void didUnbindDevice(GizWifiErrorCode result, String did) {
            super.didUnbindDevice(result, did);
            try {
                JSONObject jsonResult = new JSONObject();
                if (result == GizWifiErrorCode.GIZ_SDK_SUCCESS && !TextUtils.isEmpty(did)) {
                    jsonResult.put("did", did);
                    sendResultEvent(unbindDeviceCallback, jsonResult, null);
                } else {
                    jsonResult.put("errorCode", result.getResult());
                    jsonResult.put("msg", result.name());
                    sendResultEvent(unbindDeviceCallback, null, jsonResult);
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }

        }

        @Override
        public void didChannelIDBind(GizWifiErrorCode result) {
            super.didChannelIDBind(result);
            try {
                JSONObject jsonResult = new JSONObject();
                jsonResult.put("errorCode", result.getResult());
                jsonResult.put("msg", result.name());

                if (result == GizWifiErrorCode.GIZ_SDK_SUCCESS) {
                    sendResultEvent(cbChannelIDBindCallback, jsonResult, null);
                } else {
                    sendResultEvent(cbChannelIDBindCallback, null,jsonResult);
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void didChannelIDUnBind(GizWifiErrorCode result) {
            super.didChannelIDUnBind(result);
            try {
                JSONObject jsonResult = new JSONObject();
                jsonResult.put("errorCode", result.getResult());
                jsonResult.put("msg", result.name());

                if (result == GizWifiErrorCode.GIZ_SDK_SUCCESS) {
                    sendResultEvent(cbChannelIDBindCallback, jsonResult, null);
                } else {
                    sendResultEvent(cbChannelIDBindCallback, null,jsonResult);
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void didSetDeviceOnboarding(GizWifiErrorCode result, GizWifiDevice device) {
            try {
                JSONObject jsonResult = new JSONObject();
                if (result == GizWifiErrorCode.GIZ_SDK_SUCCESS) {
                    JSONObject deviceobj = new JSONObject();
                    deviceobj.put("mac", device.getMacAddress());
                    deviceobj.put("did", device.getDid());
                    deviceobj.put("productKey", device.getProductKey());
                    deviceobj.put("productName", device.getProductName());
                    deviceobj.put("ip", device.getIPAddress());
                    deviceobj.put("passcode", device.getPasscode());
                    deviceobj.put("isConnected", device.isConnected());
                    deviceobj.put("isOnline", device.isOnline());
                    deviceobj.put("isLAN", device.isLAN());
                    deviceobj.put("isDisabled", device.isDisabled());
                    deviceobj.put("remark", device.getRemark());
                    deviceobj.put("alias", device.getAlias());
                    deviceobj.put("isBind", device.isBind());
                    if(device instanceof GizLiteGWSubDevice) {
                        deviceobj.put("meshID",((GizLiteGWSubDevice)device).getMeshId());
                    }
                    deviceobj.put("rootDeviceId", device.getRootDevice() == null ? "" : device.getRootDevice().getDid());
                    deviceobj.put("isProductDefined", device.isProductDefined());
                    deviceobj.put("isSubscribed", device.isSubscribed());
                    int type = 0;
                    if (device.getProductType() == GizWifiDeviceType.GizDeviceCenterControl) {
                        type = 1;
                    }
                    deviceobj.put("type", type);

                    int netStatus = 0;
                    if (device.getNetStatus() == GizWifiDeviceNetStatus.GizDeviceOnline) {
                        netStatus = 1;
                    } else if (device.getNetStatus() == GizWifiDeviceNetStatus.GizDeviceControlled) {
                        netStatus = 2;
                    }
                    deviceobj.put("netStatus", netStatus);
                    jsonResult.put("device", deviceobj);
                    sendResultEvent(setOnboardingCallback.get(0), jsonResult, null);
                } else {
                    jsonResult.put("errorCode", result.getResult());
                    jsonResult.put("msg", result.name());
                    sendResultEvent(setOnboardingCallback.get(0), null, jsonResult);
                }
                setOnboardingCallback.remove(0);
            } catch (Exception e) {
                e.printStackTrace();
            }

        }

        @Override
        public void didDeviceSafetyUnbind(List<ConcurrentHashMap<String, Object>> failedDevices) {
            super.didDeviceSafetyUnbind(failedDevices);
            try {
                JSONObject result_obj = new JSONObject();
                JSONArray failArray = new JSONArray();
                if (failedDevices != null) {
                    for (int i = 0; i < failedDevices.size(); i++) {
                        GizWifiDevice gizWifiDevice = (GizWifiDevice) failedDevices.get(i).get("device");
                        JSONObject failObj = new JSONObject();
                        if (gizWifiDevice != null) {
                            failObj.put("mac", gizWifiDevice.getMacAddress());
                            failObj.put("did", gizWifiDevice.getDid());
                        }
                        failObj.put("errorCode", failedDevices.get(i).get("errorCode"));
                        failArray.put(failObj);
                    }
                }
                result_obj.put("fail", failArray);
                sendResultEvent(deviceSafetyUnbindCallback, result_obj, null);
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void didDeviceSafetyRegister(List<ConcurrentHashMap<String, String>> successDevices, List<ConcurrentHashMap<String, Object>> failedDevices) {
            super.didDeviceSafetyRegister(successDevices, failedDevices);
            try {
                JSONObject result_obj = new JSONObject();
                JSONArray successArray = new JSONArray();
                JSONArray failArray = new JSONArray();
                if (successDevices != null) {
                    for (int i = 0; i < successDevices.size(); i++) {
                        JSONObject successObj = new JSONObject(successDevices.get(i));
                        successArray.put(successObj);
                    }
                }
                if (failedDevices != null) {
                    for (int i = 0; i < failedDevices.size(); i++) {
                        JSONObject failObj = new JSONObject(failedDevices.get(i));
                        failArray.put(failObj);
                    }
                }
                result_obj.put("fail", failArray);
                result_obj.put("success", successArray);
                sendResultEvent(deviceSafeRegistCallback, result_obj, null);
            } catch (JSONException e) {
                e.printStackTrace();
            }

        }

//        @Override
//        public void didAddDevicesToGroup(GizWifiErrorCode result, List<ConcurrentHashMap<String, String>> mesDevice) {
//            super.didAddDevicesToGroup(result, mesDevice);
//            JSONObject jsonResult = new JSONObject();
//            try {
//                if (result == GizWifiErrorCode.GIZ_SDK_SUCCESS) {
//                    JSONArray jsonArray = new JSONArray();
//                    for (int i = 0; i < mesDevice.size(); i++) {
//                        JSONObject jsonObject = new JSONObject();
//                        jsonObject.put("mac", mesDevice.get(i).get("mac"));
//                        jsonObject.put("meshID", mesDevice.get(i).get("meshID"));
//                        jsonArray.put(jsonObject);
//                    }
//                    jsonResult.put("meshDevices", jsonArray);
//                    Log.e("meshAddCallBack",jsonArray.toString());
//                    sendResultEvent(addGroupCallback, jsonResult, null);
//                } else {
//                    JSONObject error = new JSONObject();
//                    error.put("errorCode", result.getResult());
//                    error.put("msg", result.name());
//                    sendResultEvent(addGroupCallback, null, error);
//                }
//
//            } catch (JSONException e) {
//
//            }
//        }

//        @Override
//        public void didChangeDeviceMesh(GizWifiErrorCode result, ConcurrentHashMap<String, String> mesDevice) {
//            super.didChangeDeviceMesh(result, mesDevice);
//            JSONObject jsonResult = new JSONObject();
//            try {
//                if (result == GizWifiErrorCode.GIZ_SDK_SUCCESS) {
//                    JSONObject jsonObject = new JSONObject();
//                    jsonObject.put("mac", mesDevice.get("mac"));
//                    jsonObject.put("meshID", mesDevice.get("meshID"));
//                    jsonResult.put("meshDevice", jsonObject);
//                    sendResultEvent(changeMeshNameCallback, jsonResult, null);
//                } else {
//                    JSONObject error = new JSONObject();
//                    error.put("errorCode", result.getResult());
//                    error.put("msg", result.name());
//                    sendResultEvent(changeMeshNameCallback, null, error);
//                }
//
//            } catch (JSONException e) {
//
//            }
//        }

//        @Override
//        public void didDiscoveredMeshDevices(GizWifiErrorCode result, List<ConcurrentHashMap<String, String>> mesDeviceList) {
//            super.didDiscoveredMeshDevices(result, mesDeviceList);
//            JSONObject jsonResult = new JSONObject();
//            try {
//                if (result == GizWifiErrorCode.GIZ_SDK_SUCCESS) {
//                    JSONArray jsonArray = new JSONArray();
//
//                    for (int i = 0; i < mesDeviceList.size(); i++) {
//                        JSONObject jsonObject = new JSONObject();
//                        jsonObject.put("mac", mesDeviceList.get(i).get("mac"));
//                        jsonObject.put("meshID", mesDeviceList.get(i).get("meshID"));
//                        String avData = mesDeviceList.get(i).get("advData");
//                        String byteData = "";
//                        for(int j=0;j<avData.length()/2;j++)
//                        {
//                            if((j>=21&&j<=26)||(j>=31&&j<=57))
//                                byteData = byteData+avData.substring(j*2,(j+1)*2);
//                        }
//                        jsonObject.put("advData",byteData.toLowerCase());
//                        jsonArray.put(jsonObject);
//                        Log.e("meshDevices",byteData+"///"+mesDeviceList.get(i).get("advData"));
//                    }
//                    jsonResult.put("meshDevices", jsonArray);
//                    callbackMeshDeviceNofitication(jsonResult);
////                    sendResultEvent(cbDicoverMesh, jsonResult, null, false);
//                } else {
//                    JSONObject error = new JSONObject();
//                    error.put("errorCode", result.getResult());
//                    error.put("msg", result.name());
//                    sendResultEvent(discoverMeshDevicesCallback,null,error);
//                }
//            } catch (JSONException e) {
//
//            }
//
//        }

        @Override
        public void didBindDevice(GizWifiErrorCode result, String did) {
            super.didBindDevice(result, did);
            try {
                JSONObject jsonResult = new JSONObject();
                if (result == GizWifiErrorCode.GIZ_SDK_SUCCESS && did != null && !did.equals("")) {
                    jsonResult.put("did", did);

                    sendResultEvent(bindRemoteDeviceCallback.get(0), jsonResult, null);
                } else {
                    jsonResult.put("errorCode", result.getResult());
                    jsonResult.put("msg", result.name());
                    sendResultEvent(bindRemoteDeviceCallback.get(0), null, jsonResult);
                }
                bindRemoteDeviceCallback.remove(0);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    };

    public RNGizwitsRnSdkModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
//        setOnboardingCallback = new ArrayList<Callback>();
//        bindRemoteDeviceCallback = new ArrayList<Callback>();

    }

    @Override
    public String getName() {
        return "RNGizwitsRnSdk";
    }

    @ReactMethod
    public void startWithAppID(ReadableMap readableMap, Callback callback) {
        GizWifiSDK.sharedInstance().setListener(gizWifiSDKListener);
        JSONObject args = readable2JsonObject(readableMap);
        WritableMap writableMap = jsonObject2WriteableMap(args);
        try {
            SDKLog.d("CallBackVersion :" + moduleVersion);
            String appID = args.optString("appID");
            JSONObject cloudServiceInfo = null;
            JSONArray specialProductKeys = null;
            JSONArray specialProductKeySecrets = null;
            JSONArray specialUsingAdapter = null;

            boolean autoSetDeviceDomain = false;
            startWithAppIdCallback = callback;
            if (!args.isNull("cloudServiceInfo")) {
                cloudServiceInfo = args.optJSONObject("cloudServiceInfo");
            }
            if (!args.isNull("specialProductKeys")) {
                specialProductKeys = args.optJSONArray("specialProductKeys");
            }

            if (!args.isNull("autoSetDeviceDomain")) {
                autoSetDeviceDomain = args.optBoolean("autoSetDeviceDomain");
            }

            if (!args.isNull("specialProductKeySecrets")) {
                specialProductKeySecrets = args.optJSONArray("specialProductKeySecrets");
            }
            if (!args.isNull("specialUsingAdapter")) {
                specialUsingAdapter = args.optJSONArray("specialUsingAdapter");
            }

            ConcurrentHashMap<String, String> cloudServiceInfos = null;
            if (cloudServiceInfo != null) {
                cloudServiceInfos = new ConcurrentHashMap<String, String>();
                if (cloudServiceInfo.has("openAPIInfo")) {

                    cloudServiceInfos.put("openAPIInfo", cloudServiceInfo.optString("openAPIInfo"));
                }
                if (cloudServiceInfo.has("siteInfo")) {
                    cloudServiceInfos.put("siteInfo", cloudServiceInfo.optString("siteInfo"));
                }
                if (cloudServiceInfo.has("pushInfo")) {
                    cloudServiceInfos.put("pushInfo", cloudServiceInfo.optString("pushInfo"));
                }
            }


            List<String> specialKey = new ArrayList<String>();
            if (specialProductKeys != null) {

                for (int i = 0; i < specialProductKeys.length(); i++) {

                    if (specialProductKeys.get(i) instanceof String) {
                        String pk = (String) specialProductKeys.get(i);
                        specialKey.add(pk);
                    }

                }

            }

            List<ConcurrentHashMap<String, String>> productInfo = new ArrayList<ConcurrentHashMap<String, String>>();

            if (specialProductKeySecrets != null) {

                for (int i = 0; i < specialProductKeySecrets.length(); i++) {

                    if (specialProductKeySecrets.get(i) instanceof String) {
                        ConcurrentHashMap<String, String> product = new ConcurrentHashMap<String, String>();
                        product.put("productKey", specialProductKeys.optString(i));
                        product.put("productSecret", specialProductKeySecrets.optString(i));
                        if (specialUsingAdapter != null) {
                            GizAdapterType type = GizAdapterType.GizAdapterNon;
                            String typeStr = specialUsingAdapter.getString(i);
                            if ("GizAdapterNon".equals(typeStr)) {
                                type = GizAdapterType.GizAdapterNon;
                            } else if ("GizAdapterDataPointMap".equals(typeStr)) {
                                type = GizAdapterType.GizAdapterDataPointMap;
                            } else if ("GizAdapterDataPointFunc".equals(typeStr)) {
                                type = GizAdapterType.GizAdapterDataPointFunc;
                            }
                            product.put("usingAdapter", type.ordinal() + "");
                        }
                        productInfo.add(product);
                    }

                }

            }


            if (!args.isNull("autoSetDeviceDomain")) {
// GizWifiSDK.sharedInstance().startWithAppID(getContext(),
// appID, specialKey, info, autoSetDeviceDomain);

                if (args.isNull("appSecret")) {
                    GizWifiSDK.sharedInstance().startWithAppID(reactContext, appID, specialKey, cloudServiceInfos,
                            autoSetDeviceDomain);
                } else {
                    String appSecret = args.optString("appSecret");
                    if (specialProductKeySecrets != null) {
                        ConcurrentHashMap<String, String> appInfo = new ConcurrentHashMap<String, String>();
                        appInfo.put("appId", appID);
                        appInfo.put("appSecret", appSecret);
                        GizWifiSDK.sharedInstance().startWithAppInfo(reactContext, appInfo, productInfo, cloudServiceInfos, autoSetDeviceDomain);

                    } else {
                        GizWifiSDK.sharedInstance().startWithAppID(reactContext, appID, appSecret, specialKey, cloudServiceInfos,
                                autoSetDeviceDomain);
                    }
                }

            } else {
                GizWifiSDK.sharedInstance().startWithAppID(reactContext, appID, specialKey, cloudServiceInfos);
                GizWifiSDK.sharedInstance().startWithAppID(reactContext, appID, specialKey, cloudServiceInfos);

            }

        } catch (JSONException e) {
            e.printStackTrace();
        }

    }

    @ReactMethod
    public void getCurrentCloudService(Callback callback) {
        if (callback == null) {
            SDKLog.d("CallBackContext is null");
            return;
        }

        getCurrentCloudService = callback;
        GizWifiSDK.sharedInstance().getCurrentCloudService();
    }

    @ReactMethod
    public void getVersion(Callback callback) {
        if (callback == null) {
            SDKLog.d("CallBackContext is null");
            return;
        }

        String version = GizWifiSDK.sharedInstance().getVersion();
        version += "-" + moduleVersion;
        SDKLog.d("version = " + version);

        JSONObject json = new JSONObject();
        try {
            json.put("version", version);
            sendResultEvent(callback, json, null);
        } catch (JSONException e) {
            e.printStackTrace();
        }

    }

    @ReactMethod
    public void getGizLog(ReadableMap readableMap, Callback callback) {
        JSONObject json = new JSONObject();
        JSONObject args = readable2JsonObject(readableMap);
        try {
            int type = args.optInt("type");
            String filePath = "";
            if (type == 0) {
                filePath = Environment.getExternalStorageDirectory() + "/GizWifiSDK/" + reactContext.getPackageName() + "/GizSDKLog/Client/GizSDKClientLogFile.sys";
            } else {
                filePath = Environment.getExternalStorageDirectory() + "/GizWifiSDK/" + reactContext.getPackageName() + "/GizSDKLog/Deamon/GizSDKLogFile.sys";
            }
            String str = "";
            try {
                FileInputStream fin = new FileInputStream(filePath);
                int length = fin.available();
                byte[] buffer = new byte[length];
                fin.read(buffer);
                str = new String(buffer);
                fin.close();
                json.put("gizLog", str);
                sendResultEvent(callback, json, null);
            } catch (Exception e) {
                json.put("error", e.getMessage());
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    @ReactMethod
    public void getBoundDevices(ReadableMap readableMap, Callback callback) {

        if (callback == null) {
            SDKLog.d("CallBackContext is null");
            return;
        }
        JSONObject args = readable2JsonObject(readableMap);
        String uid = args.optString("uid");
        String token = args.optString("token");
        JSONArray jsonarray = args.optJSONArray("specialProductKeys");
        List<String> specialProductKeys = new ArrayList<String>();
        getBoundDevicesCallback = callback;
        try {
            if (jsonarray != null && jsonarray.length() > 0) {
                for (int i = 0; i < jsonarray.length(); i++) {
                    Object obj = jsonarray.get(i);
                    if (obj != null && obj.getClass() == String.class) {
                        String pk = (String) obj;
                        specialProductKeys.add(pk);
                    }
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }

        GizWifiSDK.sharedInstance().getBoundDevices(uid, token, specialProductKeys);
    }

    @ReactMethod
    public void setDeviceOnboardingDeploy(ReadableMap readableMap, Callback callback) {
        if (callback == null) {
            SDKLog.d("callbackContext is null");
            return;
        }
        JSONObject args = readable2JsonObject(readableMap);
        final String ssid = args.optString("ssid");
        final String key = args.optString("key");

        final int mode = args.optInt("mode");
        final int timeout = args.optInt("timeout");
        final String softAPSSIDPrefix = args.optString("softAPSSIDPrefix");
        JSONArray jsonarray = args.optJSONArray("gagentTypes");
        final boolean isBind = args.optBoolean("bind");
        setOnboardingCallback.add(0, callback);
        final List<GizWifiGAgentType> types = new ArrayList<GizWifiGAgentType>();
        try {
            if (jsonarray != null) {
                for (int i = 0; i < jsonarray.length(); i++) {
                    int type = jsonarray.getInt(i);
                    switch (type) {
                        case 0:
                            types.add(GizWifiGAgentType.GizGAgentMXCHIP);
                            break;
                        case 1:
                            types.add(GizWifiGAgentType.GizGAgentHF);
                            break;
                        case 2:
                            types.add(GizWifiGAgentType.GizGAgentRTK);
                            break;
                        case 3:
                            types.add(GizWifiGAgentType.GizGAgentWM);
                            break;
                        case 4:
                            types.add(GizWifiGAgentType.GizGAgentESP);
                            break;
                        case 5:
                            types.add(GizWifiGAgentType.GizGAgentQCA);
                            break;
                        case 6:
                            types.add(GizWifiGAgentType.GizGAgentTI);
                            break;

                        case 7:
                            types.add(GizWifiGAgentType.GizGAgentFSK);
                            break;

                        case 8:
                            types.add(GizWifiGAgentType.GizGAgentMXCHIP3);
                            break;

                        case 9:
                            types.add(GizWifiGAgentType.GizGAgentBL);
                            break;

                        case 10:
                            types.add(GizWifiGAgentType.GizGAgentAtmelEE);
                            break;

                        case 11:
                            types.add(GizWifiGAgentType.GizGAgentOther);
                            break;
                        case 12:
                            types.add(GizWifiGAgentType.GizGAgentFlyLink);
                            break;
                        default:
                            types.add(GizWifiGAgentType.GizGAgentESP);
                            break;
                    }
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }


        switch (mode) {
            case 0:
                GizWifiSDK.sharedInstance().setDeviceOnboardingDeploy(ssid, key, GizWifiConfigureMode.GizWifiSoftAP, softAPSSIDPrefix, timeout, types, isBind);
                break;
            case 1:
                GizWifiSDK.sharedInstance().setDeviceOnboardingDeploy(ssid, key, GizWifiConfigureMode.GizWifiAirLink, null, timeout, types, isBind);
                break;
            case 2:
                GizWifiSDK.sharedInstance().setDeviceOnboardingDeploy(ssid, key, GizWifiConfigureMode.GizWifiAirLinkMulti, null, timeout, types, isBind);
                break;
        }
    }

    @ReactMethod
    public void bindRemoteDevice(ReadableMap readableMap, Callback callbackContext) {
        JSONObject args = readable2JsonObject(readableMap);
        if (callbackContext == null) {
            SDKLog.d("callbackContext is null");
            return;
        }

        String uid = args.optString("uid");
        String token = args.optString("token");
        String mac = args.optString("mac");
        String productKey = args.optString("productKey");
        String productSecret = args.optString("productSecret");
        boolean isOwner = args.optBoolean("beOwner");
        bindRemoteDeviceCallback.add(0, callbackContext);
        GizWifiSDK.sharedInstance().bindRemoteDevice(uid, token, mac, productKey, productSecret,isOwner);
    }

    @ReactMethod
    public void unbindDevice(ReadableMap readableMap, Callback callbackContext) {
        JSONObject args = readable2JsonObject(readableMap);
        if (callbackContext == null) {
            SDKLog.d("callbackContext is null");
            return;
        }

        String uid = args.optString("uid");
        String token = args.optString("token");
        String did = args.optString("did");
        unbindDeviceCallback = callbackContext;
        GizWifiSDK.sharedInstance().unbindDevice(uid, token, did);
    }

    @ReactMethod
    public void stopDeviceOnboarding() {
        GizWifiSDK.sharedInstance().stopDeviceOnboarding();
    }

    @ReactMethod
    public void userFeedback(ReadableMap args) {
        // if (callback == null) {
        //     SDKLog.d("callbackContext is null");
        //     return;
        // }
        String contactInfo = args.getString("contactInfo");
        String feedbackInfo = args.getString("feedbackInfo");
        boolean sendLog = args.getBoolean("sendLog");
        GizWifiSDK.sharedInstance().userFeedback(contactInfo, feedbackInfo, sendLog);
    }

    @ReactMethod
    public void deviceSafetyUnbind(ReadableMap readableMap, Callback callback) {
        JSONObject args = readable2JsonObject(readableMap);
        deviceSafetyUnbindCallback = callback;
        JSONArray jsonArray = args.optJSONArray("devicesInfo");
        List<ConcurrentHashMap<String, Object>> deviceInfos = new ArrayList<ConcurrentHashMap<String, Object>>();
        for (int i = 0; i < jsonArray.length(); i++) {
            ConcurrentHashMap<String, Object> deviceInfo = new ConcurrentHashMap<String, Object>();
            JSONObject jsonObject = jsonArray.optJSONObject(i);
            GizWifiDevice gizWifiDevice = RNGizwitsDeviceCache.getInstance().findDeviceByMac(jsonObject.optString("mac"), jsonObject.optString("did"));
            deviceInfo.put("device", gizWifiDevice);
            if (jsonObject.optString("authCode") != null) {
                deviceInfo.put("authCode", jsonObject.optString("authCode"));
            }
            deviceInfos.add(deviceInfo);
        }
        GizWifiSDK.sharedInstance().deviceSafetyUnbind(deviceInfos);
    }

    @ReactMethod
    public void addGroup(ReadableMap readableMap, Callback callback) {
//        JSONObject args = readable2JsonObject(readableMap);
//        int groupID = args.optInt("groupID");
//        addGroupCallback = callback;
//        JSONArray jsonArray = args.optJSONArray("meshDevices");
//        List<GizWifiDevice> deviceInfos = new ArrayList<GizWifiDevice>();
//        for (int i = 0; i < jsonArray.length(); i++) {
//            JSONObject jsonObject = jsonArray.optJSONObject(i);
//            GizWifiDevice gizWifiDevice = RNGizwitsDeviceCache.getInstance().findDeviceByMac(jsonObject.optString("mac"));
//            if (gizWifiDevice != null)
//                deviceInfos.add(gizWifiDevice);
//        }
//        GizWifiSDK.sharedInstance().addGroup(groupID, deviceInfos);
    }

    @ReactMethod
    public void deviceSafetyRegister(ReadableMap readableMap, Callback callback) {
        JSONObject args = readable2JsonObject(readableMap);
        deviceSafeRegistCallback = callback;
        String gateWaymac = args.optString("gatewayMac");
        String gateWayDid = args.optString("gatewayDid");
        String pk = args.optString("productKey");
        JSONArray jsonArray = args.optJSONArray("devicesInfo");
        List<ConcurrentHashMap<String, String>> deviceInfos = new ArrayList<ConcurrentHashMap<String, String>>();
        for (int i = 0; i < jsonArray.length(); i++) {
            ConcurrentHashMap<String, String> deviceInfo = new ConcurrentHashMap<String, String>();
            JSONObject jsonObject = jsonArray.optJSONObject(i);
            Iterator<String> it = jsonObject.keys();
            while (it.hasNext()) {
                String key = (String) it.next();
                deviceInfo.put(key, jsonObject.optString(key));
            }
            deviceInfos.add(deviceInfo);
        }
        GizWifiDevice gateWay = RNGizwitsDeviceCache.getInstance().findDeviceByMac(gateWaymac, gateWayDid);
        GizWifiSDK.sharedInstance().deviceSafetyRegister(gateWay, pk, deviceInfos);
    }

    @ReactMethod
    public void changeDeviceMesh(ReadableMap readableMap, Callback callback) {
//        JSONObject jsonObject = readable2JsonObject(readableMap);
//        JSONObject meshDeviceInfo = jsonObject.optJSONObject("meshDeviceInfo");
//        Iterator<String> it = meshDeviceInfo.keys();
//        ConcurrentHashMap<String, String> deviceInfo = new ConcurrentHashMap<String, String>();
//        while (it.hasNext()) {
//            String key = (String) it.next();
//            deviceInfo.put(key, meshDeviceInfo.optString(key));
//        }
//        JSONObject currentMeshInfo = jsonObject.optJSONObject("currentMesh");
//        Iterator<String> it1 = currentMeshInfo.keys();
//        ConcurrentHashMap<String, String> currentMesh = new ConcurrentHashMap<String, String>();
//        while (it1.hasNext()) {
//            String key = (String) it1.next();
//            currentMesh.put(key, currentMeshInfo.optString(key));
//        }
//        int newMeshID = jsonObject.optInt("newMeshID");
//        changeMeshNameCallback = callback;
//        GizWifiSDK.sharedInstance().changeDeviceMesh(deviceInfo, currentMesh, newMeshID);
    }

    @ReactMethod
    public void setUserMeseName(ReadableMap readableMap, Callback callback) {
//        JSONObject jsonObject = readable2JsonObject(readableMap);
//        Log.e("setUserMeshName",jsonObject.toString());
//        String meshName = jsonObject.optString("meshName");
//        String password = jsonObject.optString("password");
//        JSONObject uuidInfo = jsonObject.optJSONObject("uuidInfo");
//        String meshLTKstr = jsonObject.optString("meshLTK");
//        if (meshName == null || password == null || uuidInfo == null || meshLTKstr == null) {
//            try {
//                JSONObject result = new JSONObject();
//                result.put("errorCode",
//                        GizWifiErrorCode.GIZ_SDK_PARAM_INVALID.getResult());
//                result.put("msg", GizWifiErrorCode.GIZ_SDK_PARAM_INVALID.name());
//                sendResultEvent(callback,null,result);
//            } catch (JSONException e) {
//                e.printStackTrace();
//            }
//            return;
//        }
//        Iterator<String> it = uuidInfo.keys();
//        ConcurrentHashMap<String, String> uuid = new ConcurrentHashMap<String, String>();
//        while (it.hasNext()) {
//            String key = (String) it.next();
//            uuid.put(key, uuidInfo.optString(key));
//        }
//        if (meshLTKstr == null || meshLTKstr.length() % 2 != 0)
//            return;
//        byte[] meshLTK = new byte[meshLTKstr.length() / 2];
//        for (int i = 0; i < meshLTK.length; i++) {
//            meshLTK[i] = (byte) Integer.parseInt(meshLTKstr.substring(i * 2, (i + 1) * 2), 16);
//        }
//        int meshVerdor = jsonObject.optInt("meshVerdor");
//        GizWifiSDK.sharedInstance().setUserMeshName(meshName, password, uuid, meshLTK, meshVerdor == 1 ? GizMeshVendor.GizMeshTelink : GizMeshVendor.GizMeshMayi);
//        callback.invoke(null, null);
    }

    @ReactMethod
    public void searchMeshDevice(ReadableMap readableMap, Callback callback) {
//        JSONObject jsonObject = readable2JsonObject(readableMap);
//        String meshName = jsonObject.optString("meshName");
//        discoverMeshDevicesCallback = callback;
//        GizWifiSDK.sharedInstance().searchMeshDevice(meshName);
    }

    @ReactMethod
    public void getDeviceLog(ReadableMap readableMap) {
//        JSONObject jsonObject = readable2JsonObject(readableMap);
//        String softApSSID = jsonObject.optString("softAPSSIDPrefix");
//        GizWifiSDK.sharedInstance().getDeviceLog(softApSSID);
    }

    @ReactMethod
    public void disableLan(ReadableMap args) {
        boolean isDisabled = args.getBoolean("isDisableLan");
        GizWifiSDK.sharedInstance().disableLAN(isDisabled);
    }

    public void channelIDBind(ReadableMap readableMap, Callback callback)
    {
        JSONObject args = readable2JsonObject(readableMap);
        String token = args.optString("token");
        String channelID = args.optString("channelId");
        boolean isBind = args.optBoolean("isBind");
        if(isBind) {
            int pushType = args.optInt("pushType");
            String alias = args.optString("alias");
            GizPushType gizPushType = GizPushType.GizPushJiGuang;
            switch (pushType) {
                case 0:
                    gizPushType = GizPushType.GizPushBaiDu;
                    break;
                case 1:
                    gizPushType = GizPushType.GizPushJiGuang;
                    break;
                case 2:
                    gizPushType = GizPushType.GizPushAWS;
                    break;
                case 3:
                    gizPushType = GizPushType.GizPushXinGe;
                    break;
            }
            cbChannelIDBindCallback = callback;
            GizWifiSDK.sharedInstance().channelIDBind(token, channelID, alias, gizPushType);
        }else{
            GizWifiSDK.sharedInstance().channelIDUnBind(token,channelID);
        }
    }


    public void callbackNofitication(JSONObject params) {
        WritableMap writableMap = jsonObject2WriteableMap(params);
        reactContext
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit("GizDeviceListNotifications", writableMap);
    }

    public void callbackMeshDeviceNofitication(JSONObject params) {
        Log.e("meshDevice",params.toString());
        WritableMap writableMap = jsonObject2WriteableMap(params);
        reactContext
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit("GizMeshDeviceListNotifications", writableMap);
    }
    public void callbackDeviceLogNofitication(JSONObject params) {
        Log.e("meshDevice", params.toString());
        WritableMap writableMap = jsonObject2WriteableMap(params);
        reactContext
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit("GizDeviceLogNotifications", writableMap);
    }

    public JSONObject readable2JsonObject(ReadableMap readableMap) {
        try {
            JSONObject jsonObject = new JSONObject();
            ReadableMapKeySetIterator readableMapKeySetIterator = readableMap.keySetIterator();
            while (readableMapKeySetIterator.hasNextKey()) {
                String key = readableMapKeySetIterator.nextKey();
                if (readableMap.getType(key) == ReadableType.Number) {
//                    try {
//                        jsonObject.put(key, readableMap.getInt(key));
//                    } catch (Exception e) {
                    jsonObject.put(key, readableMap.getDouble(key));
//                    }
                } else if (readableMap.getType(key) == ReadableType.Map) {
                    jsonObject.put(key, readable2JsonObject(readableMap.getMap(key)));
                } else if (readableMap.getType(key) == ReadableType.String) {
                    jsonObject.put(key, readableMap.getString(key));
                } else if (readableMap.getType(key) == ReadableType.Boolean) {
                    jsonObject.put(key, readableMap.getBoolean(key));
                } else if (readableMap.getType(key) == ReadableType.Array) {
                    jsonObject.put(key, readable2jsonArray(readableMap.getArray(key)));
                } else {
                    jsonObject.put(key, null);
                }
            }
            return jsonObject;
        } catch (JSONException e1) {
            e1.printStackTrace();
            return null;
        }
    }

    public JSONArray readable2jsonArray(ReadableArray readableArray) {
        try {
            JSONArray jsonArray = new JSONArray();
            for (int i = 0; i < readableArray.size(); i++) {
                if (readableArray.getType(i) == ReadableType.Number) {
//                    try {
//                        jsonArray.put(i, readableArray.getInt(i));
//                    } catch (Exception e) {
                    jsonArray.put(i, readableArray.getDouble(i));
//                    }
                } else if (readableArray.getType(i) == ReadableType.Map) {
                    jsonArray.put(i, readable2JsonObject(readableArray.getMap(i)));
                } else if (readableArray.getType(i) == ReadableType.String) {
                    jsonArray.put(i, readableArray.getString(i));
                } else if (readableArray.getType(i) == ReadableType.Boolean) {
                    jsonArray.put(i, readableArray.getBoolean(i));
                } else if (readableArray.getType(i) == ReadableType.Array) {
                    jsonArray.put(i, readable2jsonArray(readableArray.getArray(i)));
                } else {
                    jsonArray.put(i, null);
                }
            }

            return jsonArray;
        } catch (JSONException e1) {
            e1.printStackTrace();
            return null;
        }
    }

    private void sendResultEvent(Callback callbackContext, JSONObject dataDict, JSONObject errDict) {
        if (callbackContext == null) {
            return;
        }
        try {
            if (dataDict != null) {
                WritableMap successMap = jsonObject2WriteableMap(dataDict);
                callbackContext.invoke(null, successMap);
            } else {
                WritableMap errorMap = jsonObject2WriteableMap(errDict);
                callbackContext.invoke(errorMap, null);
            }
        } catch (Exception e) {

        }

    }


    public WritableMap jsonObject2WriteableMap(JSONObject jsonObject) {
        try {
            WritableMap writableMap = Arguments.createMap();
            Iterator iterator = jsonObject.keys();
            while (iterator.hasNext()) {
                String key = (String) iterator.next();
                Object object = jsonObject.get(key);
                if (object instanceof String) {
                    writableMap.putString(key, jsonObject.getString(key));
                } else if (object instanceof Boolean) {
                    writableMap.putBoolean(key, jsonObject.getBoolean(key));
                } else if (object instanceof Integer) {
                    writableMap.putInt(key, jsonObject.getInt(key));
                } else if (object instanceof Double) {
                    writableMap.putDouble(key, jsonObject.getDouble(key));
                } else if (object instanceof JSONObject) {
                    writableMap.putMap(key, jsonObject2WriteableMap(jsonObject.getJSONObject(key)));
                } else if (object instanceof JSONArray) {
                    writableMap.putArray(key, jsonArray2WriteableArray(jsonObject.getJSONArray(key)));
                } else {
                    writableMap.putNull(key);
                }
            }
            return writableMap;
        } catch (JSONException e) {
            e.printStackTrace();
            return null;
        }

    }

    public WritableArray jsonArray2WriteableArray(JSONArray jsonArray) {
        try {
            WritableArray writableArray = Arguments.createArray();
            for (int i = 0; i < jsonArray.length(); i++) {
                Object object = jsonArray.get(i);
                if (object instanceof String) {
                    writableArray.pushString(jsonArray.getString(i));
                } else if (object instanceof Boolean) {
                    writableArray.pushBoolean(jsonArray.getBoolean(i));
                } else if (object instanceof Integer) {
                    writableArray.pushInt(jsonArray.getInt(i));
                } else if (object instanceof Double) {
                    writableArray.pushDouble(jsonArray.getDouble(i));
                } else if (object instanceof JSONObject) {
                    writableArray.pushMap(jsonObject2WriteableMap(jsonArray.getJSONObject(i)));
                } else if (object instanceof JSONArray) {
                    writableArray.pushArray(jsonArray2WriteableArray(jsonArray.getJSONArray(i)));
                } else {
                    writableArray.pushNull();
                }
            }

            return writableArray;
        } catch (JSONException e) {
            e.printStackTrace();
            return null;
        }
    }
}