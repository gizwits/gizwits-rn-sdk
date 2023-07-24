package com.gizwitssdk;

import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import java.util.List;
import java.util.ArrayList;
import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableMapKeySetIterator;
import com.facebook.react.bridge.ReadableType;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.gizwits.gizwifisdk.api.GizWifiBinary;
import com.gizwits.gizwifisdk.protocol.OTASendDataReplyParse;
import com.gizwits.gizwifisdk.protocol.OTAPreCheckParse;


import com.gizwits.gizwifisdk.api.GizWifiDevice;
import com.gizwits.gizwifisdk.api.GizWifiBleDevice;
import com.gizwits.gizwifisdk.enumration.GizWifiDeviceNetStatus;
import com.gizwits.gizwifisdk.enumration.GizOTAEventType;
import com.gizwits.gizwifisdk.enumration.GizWifiDeviceType;
import com.gizwits.gizwifisdk.enumration.GizWifiErrorCode;
import com.gizwits.gizwifisdk.enumration.GizOTAFirmwareType;

import com.gizwits.gizwifisdk.listener.GizWifiDeviceListener;
import com.gizwits.gizwifisdk.listener.GizBleDeviceMeshListener;

import com.gizwits.gizwifisdk.listener.GizDeviceBleOTAListener;

import com.gizwits.gizwifisdk.log.SDKLog;
import com.xtremeprog.xpgconnect.XPGWifiBinary;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Created by linyingqi on 2018/12/19.
 */
@ReactModule(name = RNGizwitsRnSdkModule.NAME)
public class RNGizwitsRnDeviceModule extends ReactContextBaseJavaModule {
    public static final String NAME = "RNGizwitsRnDeviceModule";

    private Map<String,Callback> getDeviceStatusCallback= new HashMap<String, Callback>();
    private  Map<String,Callback> writeCallback= new HashMap<String, Callback>();
    private  Callback connectBleCallback;
    private  Callback checkUpdateCallback;
    // 保留临时OTA数据
    private OTAPreCheckParse preCheckData;
    private int firmwareSize;
    private native void nativeInstallDevice(long jsiPtr, String docDir);
    private native void emitJSI(long jsiPtr, String name, String data);


    Map<String, Callback> subscribeCallbacks = new HashMap<String, Callback>();

    private final ReactApplicationContext reactContext;

    @ReactMethod(isBlockingSynchronousMethod = true)
    public boolean install() {
        try {
            System.loadLibrary("gizwitsjsi");

            ReactApplicationContext context = getReactApplicationContext();
            nativeInstallDevice(
                    context.getJavaScriptContextHolder().get(),
                    context.getFilesDir().getAbsolutePath()
            );
            return true;
        } catch (Exception exception) {
            return false;
        }
    }

    GizDeviceBleOTAListener bleOtaListener = new GizDeviceBleOTAListener() {
        public void didCheckUpdate(GizWifiErrorCode code, GizWifiBleDevice device, String lastVersion, String currentVersion) {
            if (checkUpdateCallback == null) {
                SDKLog.d("check update moduleContext is null");
                return;
            }
            try {
                JSONObject jsonResult = new JSONObject();
                JSONObject deviceobj = new JSONObject();

                if (device != null) {
                    deviceobj.put("mac", device.getMacAddress());
                    deviceobj.put("did", device.getDid());
                    jsonResult.put("device", deviceobj);
                }

                jsonResult.put("lastVersion", lastVersion);
                jsonResult.put("currentVersion", currentVersion);

                if (code == GizWifiErrorCode.GIZ_SDK_SUCCESS) {
                    sendResultEvent(checkUpdateCallback, jsonResult, null);
                } else {
                    jsonResult.put("errorCode", code.getResult());
                    jsonResult.put("msg", code.name());
                    sendResultEvent(checkUpdateCallback, null, jsonResult);
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        public void didStartUpgrade(final GizWifiErrorCode code, GizWifiBleDevice device, final GizOTAEventType type) {
            try {
                JSONObject jsonResult = new JSONObject();
                JSONObject deviceobj = new JSONObject();
                if (device != null) {
                    deviceobj.put("mac", device.getMacAddress());
                    deviceobj.put("did", device.getDid());
                    jsonResult.put("device", deviceobj);
                }
                // sdk错误码
                jsonResult.put("errorCode", code.getResult());
                // 0 预处理 1下载固件包完成事件 2传输固件包完成事件 3 设备重启事件 4 OTA结束事件
                if (type != null) {
                    jsonResult.put("type", type.toString());
                }
                jsonResult.put("device", deviceobj);
                callbackBleOTAStatus(jsonResult);
            } catch (Exception e) {
                //TODO: handle exception
                e.printStackTrace();
            }
        }

        public void didPreOtaListener(GizWifiErrorCode code, OTAPreCheckParse otaData, int len) {
            if (code == GizWifiErrorCode.GIZ_SDK_SUCCESS) {
                preCheckData = otaData;
                firmwareSize = len;
            }
        }

        public void didOTADataReply(GizWifiErrorCode code, OTASendDataReplyParse replyData) {
            if (preCheckData != null) {
                // 计算当前的数据
                try {
                    JSONObject jsonResult = new JSONObject();
                    jsonResult.put("packageMaxLen", preCheckData.packageMaxLen);
                    jsonResult.put("firmwareSize", firmwareSize);
                    jsonResult.put("currentNumber", replyData.getPackageNum());

                    callbackBleOTAProgress(jsonResult);
                }catch (JSONException e) {
                    e.printStackTrace();
                }

            }
        }


    };

    GizWifiDeviceListener deviceListener = new GizWifiDeviceListener() {
        @Override
        public void didReceiveAttrStatus(GizWifiErrorCode result, GizWifiDevice device, ConcurrentHashMap<String, Object> attrStatus, ConcurrentHashMap<String, Object> adapterAttrStatus, int sn) {
            super.didReceiveAttrStatus(result, device, attrStatus, adapterAttrStatus, sn);
            receiveData(result, device, attrStatus, adapterAttrStatus, sn, false);
        }

        @Override
        public void didReceiveAppToDevAttrStatus(GizWifiErrorCode result, GizWifiDevice device, ConcurrentHashMap<String, Object> attrStatus, ConcurrentHashMap<String, Object> adapterAttrStatus, int sn) {
            super.didReceiveAppToDevAttrStatus(result, device, attrStatus, adapterAttrStatus, sn);
            receiveData(result, device, attrStatus, adapterAttrStatus, sn, true);
        }

        @Override
        public void didUpdateNetStatus(GizWifiDevice device, GizWifiDeviceNetStatus netStatus) {
            super.didUpdateNetStatus(device, netStatus);
            JSONObject jsonResult = new JSONObject();
            try {
                JSONObject deviceobj = new JSONObject();
                if (device != null) {
                    deviceobj.put("mac", device.getMacAddress());
                    deviceobj.put("productKey", device.getProductKey());
                    deviceobj.put("did", device.getDid());

                    // 检查是否是蓝牙设备。如果是蓝牙设备的话
                    if(device instanceof GizWifiBleDevice){
                        jsonResult.put("isBlueLocal", ((GizWifiBleDevice)device).isBlueLocal());
                    }

                    jsonResult.put("device", deviceobj);
                }

                int _netStatus = 0;
                if (netStatus == GizWifiDeviceNetStatus.GizDeviceOffline) {
                    _netStatus = 0;
                } else if (netStatus == GizWifiDeviceNetStatus.GizDeviceOnline) {
                    _netStatus = 1;
                } else if (netStatus == GizWifiDeviceNetStatus.GizDeviceControlled) {
                    _netStatus = 2;
                }

                // 利用状态上报做回调
                jsonResult.put("netStatus", _netStatus);
                ReactApplicationContext context = getReactApplicationContext();
                emitJSI(context.getJavaScriptContextHolder().get(), "GizDeviceNetStatusNotifications", jsonResult.toString());
//                callbackDeviceStatus(jsonResult);
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void didSetSubscribe(GizWifiErrorCode result, GizWifiDevice device, boolean isSubscribed) {
            if (subscribeCallbacks.get(device.getMacAddress()) == null) {
                SDKLog.d("moduleContext is null");
                return;
            }
            try {
                JSONObject jsonResult = new JSONObject();
                JSONObject deviceobj = new JSONObject();
                if (device != null) {
                    deviceobj.put("mac", device.getMacAddress());
                    deviceobj.put("did", device.getDid());
                    jsonResult.put("device", deviceobj);
                }
                if (result == GizWifiErrorCode.GIZ_SDK_SUCCESS) {
                    jsonResult.put("isSubscribed", isSubscribed);
                    sendResultEvent(subscribeCallbacks.get(device.getMacAddress()), jsonResult, null);
                } else {
                    jsonResult.put("errorCode", result.getResult());
                    jsonResult.put("msg", result.name());
                    sendResultEvent(subscribeCallbacks.get(device.getMacAddress()), null, jsonResult);
                }
                subscribeCallbacks.remove(device.getMacAddress());
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void didConnectBle(GizWifiErrorCode result, GizWifiBleDevice device) {
            if (connectBleCallback == null) {
                SDKLog.d("moduleContext is null");
                return;
            }
            try {
                JSONObject jsonResult = new JSONObject();
                JSONObject deviceobj = new JSONObject();

                if (result == GizWifiErrorCode.GIZ_SDK_SUCCESS) {
                    if (device != null) {
                        deviceobj.put("mac",device.getMacAddress());
                        deviceobj.put("productKey",device.getProductKey());
                        int netStatus = 0;
                        if (device.getNetStatus() == GizWifiDeviceNetStatus.GizDeviceOnline) {
                            netStatus = 1;
                        } else if (device.getNetStatus() == GizWifiDeviceNetStatus.GizDeviceControlled) {
                            netStatus = 2;
                        }
                        deviceobj.put("netStatus", netStatus);
                        deviceobj.put("isBlueLocal",device.isBlueLocal());
                        jsonResult.put("device", deviceobj);
                    }
                    sendResultEvent(connectBleCallback, jsonResult, null);
                } else {
                    jsonResult.put("errorCode", result.getResult());
                    jsonResult.put("msg", result.name());
                    sendResultEvent(connectBleCallback, null, jsonResult);
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    };

    public RNGizwitsRnDeviceModule(ReactApplicationContext reactContext) {
        super(reactContext);
        RNGizwitsDeviceCache.getInstance().setDeviceListener(deviceListener);
        this.reactContext = reactContext;

    }

    @Override
    public String getName() {
        return "RNGizwitsRnDevice";
    }

    @ReactMethod
    public void getDeviceStatus(ReadableMap readableMap, Callback callback) {
        JSONObject args = readable2JsonObject(readableMap);

        JSONObject result = new JSONObject();
        JSONObject deviceobj = args.optJSONObject("device");
        try {

            String mac = deviceobj.optString("mac");
            String did = deviceobj.optString("did");


            List<String> attrs = null;

            JSONArray attrsArr = args.optJSONArray("attrs");

            if (attrsArr != null) {
                attrs = new ArrayList();
                for (int i = 0; i < attrsArr.length(); i++) {
                    attrs.add(attrsArr.getString(i));
                }
            }

            result.put("device", deviceobj);

            GizWifiDevice device = null;
            device = RNGizwitsDeviceCache.getInstance()
                    .findDeviceByMac(mac, did);

            GizWifiBleDevice bleDevice = RNGizwitsDeviceCache.getInstance()
                    .findBleDeviceByMac(mac);
            Integer sn = Utils.getSn();
            if(bleDevice!=null&&bleDevice.getNetStatus()==GizWifiDeviceNetStatus.GizDeviceControlled)
            {
                device = bleDevice;
            }
            getDeviceStatusCallback.put(sn + "",callback);
            if (device == null) {
                result.put("errorCode",
                        GizWifiErrorCode.GIZ_SDK_PARAM_INVALID.getResult());
                result.put("msg", GizWifiErrorCode.GIZ_SDK_PARAM_INVALID.name());
                sendResultEvent(callback, null, result);
            } else {
                device.setListener(deviceListener);
                device.getDeviceStatus(attrs, sn);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }

    }

    @ReactMethod
    public void checkUpdate(ReadableMap readableMap, Callback callback) {
        JSONObject args = readable2JsonObject(readableMap);
        JSONObject result = new JSONObject();
        Integer typeInt = args.optInt("type");
        JSONObject deviceobj = args.optJSONObject("device");
        GizOTAFirmwareType type = GizOTAFirmwareType.GizOTAFirmareModule;

        switch (typeInt) {
            case 0:
                type = GizOTAFirmwareType.GizOTAFirmareModule;
                break;
            case 1:
                type = GizOTAFirmwareType.GizOTAFirmareMcu;
                break;
            default:
                type = GizOTAFirmwareType.GizOTAFirmareModule;
                break;
        }
        try {
            String mac = deviceobj.optString("mac");
            GizWifiBleDevice device = RNGizwitsDeviceCache.getInstance()
                    .findBleDeviceByMac(mac);
            if (device == null) {
                result.put("errorCode",
                        GizWifiErrorCode.GIZ_SDK_DEVICE_DID_INVALID.getResult());
                result.put("msg", GizWifiErrorCode.GIZ_SDK_DEVICE_DID_INVALID.name());
                SDKLog.d("result = " + result);
                sendResultEvent(callback, null, result);
            } else {
                checkUpdateCallback = callback;
                device.checkUpdate(type, bleOtaListener);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void handleSetMeshDeviceToGroup(int type, ReadableMap readableMap, Callback callback){
        try {
            JSONObject args = readable2JsonObject(readableMap);
            JSONObject deviceobj = args.optJSONObject("device");
            JSONArray macs = args.optJSONArray("macs");
            Integer groupID = args.optInt("groupID");

            JSONObject callBackResult = new JSONObject();


            WritableArray macsArr = jsonArray2WriteableArray(macs);
            String mac = deviceobj.optString("mac");

            GizWifiBleDevice device = RNGizwitsDeviceCache.getInstance()
                    .findBleDeviceByMac(mac);

            if (device != null) {
                if (device.getNetStatus() != GizWifiDeviceNetStatus.GizDeviceControlled) {
                    // 回调设备未就绪
                    SDKLog.d("addMeshDeviceToGroup 设备未就绪");
                    callBackResult.put("errorCode",
                            GizWifiErrorCode.GIZ_SDK_DEVICE_NOT_READY.getResult());
                    sendResultEvent(callback, null, callBackResult);
                    return;
                }

                List<String> macsList = new ArrayList();
                for (int i = 0; i < macs.length(); i++) {
                    macsList.add(macs.getString(i));
                }

                GizBleDeviceMeshListener listener = new GizBleDeviceMeshListener() {
                    @Override
                    public void didRespont(GizWifiBleDevice device, GizWifiErrorCode result) {
                        // 回调结果
                        JSONObject respCallBackResult = new JSONObject();
                        try {
                            respCallBackResult.put("errorCode", result.getResult());
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }


                        if (GizWifiErrorCode.GIZ_SDK_SUCCESS == result) {
                            sendResultEvent(callback, respCallBackResult, null);
                        } else {
                            sendResultEvent(callback, null, respCallBackResult);
                        }
                        SDKLog.d("addMeshDeviceToGroup respont" + result);
                    }
                };

                SDKLog.d("addMeshDeviceToGroup groupID:" + groupID + ", mac:" + String.join("", macsList));

                if (type == 1) {
                    device.addMeshDeviceToGroup(macsList, groupID, listener);
                } else {
                    device.deleteMeshDeviceFromGroup(macsList, groupID, listener);

                }

            } else {
                // 回调设备不存在
                SDKLog.d("addMeshDeviceToGroup 设备不存在");
                callBackResult.put("errorCode",
                        GizWifiErrorCode.GIZ_OPENAPI_DEVICE_NOT_FOUND.getResult());
                sendResultEvent(callback, null, callBackResult);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    @ReactMethod
    public void addMeshDeviceToGroup(ReadableMap readableMap, Callback callback) {
        handleSetMeshDeviceToGroup(1, readableMap, callback);
    }

    @ReactMethod
    public void deleteMeshDeviceFromGroup(ReadableMap readableMap, Callback callback) {
        handleSetMeshDeviceToGroup(2, readableMap, callback);
    }

    @ReactMethod
    public void startUpgrade(ReadableMap readableMap, Callback callback) {
        JSONObject args = readable2JsonObject(readableMap);
        JSONObject result = new JSONObject();
        Integer typeInt = args.optInt("type");
        JSONObject deviceobj = args.optJSONObject("device");
        GizOTAFirmwareType type = GizOTAFirmwareType.GizOTAFirmareModule;

        switch (typeInt) {
            case 0:
                type = GizOTAFirmwareType.GizOTAFirmareModule;
                break;
            case 1:
                type = GizOTAFirmwareType.GizOTAFirmareMcu;
                break;
            default:
                type = GizOTAFirmwareType.GizOTAFirmareModule;
                break;
        }
        try {
            String mac = deviceobj.optString("mac");
            GizWifiBleDevice device = RNGizwitsDeviceCache.getInstance()
                    .findBleDeviceByMac(mac);
            if (device == null) {
                result.put("errorCode",
                        GizWifiErrorCode.GIZ_SDK_DEVICE_DID_INVALID.getResult());
                result.put("msg", GizWifiErrorCode.GIZ_SDK_DEVICE_DID_INVALID.name());
                SDKLog.d("result = " + result);
                sendResultEvent(callback, null, result);
            } else {
                checkUpdateCallback = callback;
                device.startUpgrade(type, bleOtaListener);

                result.put("errorCode", GizWifiErrorCode.GIZ_SDK_SUCCESS.getResult());
                sendResultEvent(callback, result, null);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    @ReactMethod
    public void write(ReadableMap readableMap, Callback callback) {
        JSONObject args = readable2JsonObject(readableMap);
        JSONObject result = new JSONObject();
        JSONObject dataobj = args.optJSONObject("data");
        JSONObject deviceobj = args.optJSONObject("device");
        try {
            String mac = deviceobj.optString("mac");
            String did = deviceobj.optString("did");
            result.put("device", deviceobj);

            GizWifiDevice device = null;
            device = RNGizwitsDeviceCache.getInstance()
                    .findDeviceByMac(mac, did);

            GizWifiBleDevice bleDevice = RNGizwitsDeviceCache.getInstance()
                    .findBleDeviceByMac(mac);
            if(bleDevice!=null&&bleDevice.getNetStatus()==GizWifiDeviceNetStatus.GizDeviceControlled)
            {
                device = bleDevice;
            }
            if (device == null) {
                result.put("errorCode",
                        GizWifiErrorCode.GIZ_SDK_DEVICE_DID_INVALID.getResult());
                result.put("msg", GizWifiErrorCode.GIZ_SDK_DEVICE_DID_INVALID.name());
                SDKLog.d("result = " + result);
                sendResultEvent(callback, null, result);
            } else {
                device.setListener(deviceListener);
                if (args != null && !args.has("sn")) {
                    device.write(dataobj.toString());
                    writeCallback.put(0+"",callback);
                } else {
                    int sn = args.optInt("sn");
                    writeCallback.put(sn+"",callback);
                    Iterator<String> keys = dataobj.keys();
                    ConcurrentHashMap<String, Object> map = new ConcurrentHashMap<String, Object>();
                    while (keys.hasNext()) {
                        String key = keys.next();
                        Object value = dataobj.get(key);
                        if (value instanceof JSONArray) {
                            JSONArray jsonArray = dataobj.getJSONArray(key);
                            byte[] data = new byte[jsonArray.length()];
                            for (int i = 0; i < jsonArray.length(); i++) {
                                data[i] = (byte) jsonArray.getInt(i);
                            }
                            map.put(key, XPGWifiBinary.encode(data));
                        } else {
                            map.put(key, value);
                        }
                    }
                    device.write(map, sn);
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    @ReactMethod
    public void setSubscribe(ReadableMap readableMap, Callback callback) {
        JSONObject args = readable2JsonObject(readableMap);
        JSONObject result = new JSONObject();
        JSONObject deviceobj = args.optJSONObject("device");
        try {
            String did = "";
            String mac = "";
            if (deviceobj.has("mac")) {
                mac = deviceobj.optString("mac");
            }
            if (deviceobj.has("did")) {
                did = deviceobj.optString("did");
            }
            result.put("device", deviceobj);
            GizWifiDevice device = RNGizwitsDeviceCache.getInstance()
                    .findDeviceByMac(mac, did);

            if (device == null) {
                result.put("errorCode",
                        GizWifiErrorCode.GIZ_SDK_PARAM_INVALID.getResult());
                result.put("msg", GizWifiErrorCode.GIZ_SDK_PARAM_INVALID.name());
                sendResultEvent(callback, null, result);
            } else {
                subscribeCallbacks.put(mac, callback);
                device.setListener(deviceListener);
                boolean subscribed = args.optBoolean("subscribed");
                String productSecret = args.optString("productSecret");
                device.setSubscribe(productSecret, subscribed);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    public boolean setSubscribe_c(String mac, String did, String productSecret, boolean subscribed) {
        GizWifiDevice device = RNGizwitsDeviceCache.getInstance()
                .findDeviceByMac(mac, did);
        if (device != null) {
            device.setListener(deviceListener);
            device.setSubscribe(productSecret, subscribed);
            return true;
        }
        return false;
    }
    @ReactMethod
    public void setSubscribeNotGetDeviceStatus(ReadableMap readableMap, Callback callback) {
        JSONObject args = readable2JsonObject(readableMap);
        JSONObject result = new JSONObject();
        JSONObject deviceobj = args.optJSONObject("device");
        try {
            String did = "";
            String mac = "";
            if (deviceobj.has("mac")) {
                mac = deviceobj.optString("mac");
            }
            if (deviceobj.has("did")) {
                did = deviceobj.optString("did");
            }
            result.put("device", deviceobj);
            GizWifiDevice device = RNGizwitsDeviceCache.getInstance()
                    .findDeviceByMac(mac, did);

            if (device == null) {
                result.put("errorCode",
                        GizWifiErrorCode.GIZ_SDK_PARAM_INVALID.getResult());
                result.put("msg", GizWifiErrorCode.GIZ_SDK_PARAM_INVALID.name());
                sendResultEvent(callback, null, result);
            } else {
                subscribeCallbacks.put(mac, callback);
                device.setListener(deviceListener);
                boolean subscribed = args.optBoolean("subscribed");
                device.setSubscribe(subscribed, false);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    @ReactMethod
    public void connectBle(ReadableMap readableMap, Callback callback) {
        JSONObject args = readable2JsonObject(readableMap);
        JSONObject result = new JSONObject();
        JSONObject deviceobj = args.optJSONObject("device");
        try {
            String mac = deviceobj.optString("mac");
            result.put("device", deviceobj);

            GizWifiBleDevice device = RNGizwitsDeviceCache.getInstance()
                    .findBleDeviceByMac(mac);

            if (device == null) {
                result.put("errorCode",
                        GizWifiErrorCode.GIZ_SDK_DEVICE_DID_INVALID.getResult());
                result.put("msg", GizWifiErrorCode.GIZ_SDK_DEVICE_DID_INVALID.name());
                SDKLog.d("result = " + result);
                sendResultEvent(callback, null, result);
            } else {
                connectBleCallback = callback;
                device.setListener(deviceListener);
                device.connectBle();
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    @ReactMethod
    public void disconnectBle(ReadableMap readableMap, Callback callback) {
        JSONObject args = readable2JsonObject(readableMap);
        JSONObject result = new JSONObject();
        JSONObject deviceobj = args.optJSONObject("device");
        try {
            String mac = deviceobj.optString("mac");
            result.put("device", deviceobj);

            GizWifiBleDevice device = RNGizwitsDeviceCache.getInstance()
                    .findBleDeviceByMac(mac);

            if (device == null) {
                result.put("errorCode",
                        GizWifiErrorCode.GIZ_SDK_DEVICE_DID_INVALID.getResult());
                result.put("msg", GizWifiErrorCode.GIZ_SDK_DEVICE_DID_INVALID.name());
                SDKLog.d("result = " + result);
                sendResultEvent(callback, null, result);
            } else {
                connectBleCallback = callback;
                device.disconnectBle();
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void receiveData(GizWifiErrorCode result,
                             GizWifiDevice device,
                             ConcurrentHashMap<String, Object> dataMap, ConcurrentHashMap<String, Object> adapterAttrStatus, int sn, boolean isAppToDev) {
        boolean isConnected = false;
        boolean isOnline = false;
        int netStatus = 0;
        ConcurrentHashMap<String, Object> tempDataMap = null;
        JSONObject resultJson = new JSONObject();
        if (dataMap != null&&dataMap.size()!=0) {
            tempDataMap = dataMap;
        }
        if (adapterAttrStatus != null&&adapterAttrStatus.size()!=0) {
            tempDataMap = adapterAttrStatus;
        }
        try {

            if (result == GizWifiErrorCode.GIZ_SDK_SUCCESS) {

                if (tempDataMap != null && tempDataMap.size() > 0) {
                    JSONObject status = new JSONObject();
                    JSONObject entity0 = new JSONObject();

                    if (tempDataMap.toString().contains("data")) {
                        String data = tempDataMap.get("data").toString();
                        if (data != null && data.length() != 0) {
                            JSONObject json = new JSONObject();
                            ConcurrentHashMap<String, Object> object = (ConcurrentHashMap<String, Object>) tempDataMap
                                    .get("data");
                            for (String key : object.keySet()) {
                                Object value = object.get(key);
                                // 扩展类型需要base64编码
                                if (value instanceof byte[]) {
                                    byte[] byteStr = (byte[]) value;
                                    JSONArray jsonArray;
                                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.KITKAT) {
                                        jsonArray = new JSONArray(byteStr);
                                        for (int i = 0; i < jsonArray.length(); i++) {
                                            jsonArray.put(i, ((Byte) jsonArray.get(i)) & 0xff);
                                        }
                                    } else {
                                        jsonArray = new JSONArray();
                                        for (int i = 0; i < byteStr.length; i++) {
                                            jsonArray.put(byteStr[i]);
                                        }
                                    }
//                                        String str = bytesToHex(byteStr);
                                    json.put(key, jsonArray);
                                    Log.d("GizSDKClientLog", "byte Key=" + key + ";Value=" + jsonArray.toString());
                                } else if(value instanceof Long) {
                                    json.put(key,((Long) object.get(key)).doubleValue());
                                    Log.d("GizSDKClientLog", "Key=" + key + ";Value=" + object.get(key));
                                } else {
                                    json.put(key, object.get(key));
                                    Log.d("GizSDKClientLog", "Key=" + key + ";Value=" + object.get(key));
                                }
                            }


                            if (json != null) {
                                entity0.put("entity0", json);
                                status.put("data", entity0);
                                resultJson.put("data", json);
                            }
                        }
                    }

                    if (tempDataMap.toString().contains("alerts")) {

                        String alerts = tempDataMap.get("alerts").toString();
                        if (alerts != null && alerts.length() != 0) {
                            JSONObject json = new JSONObject(alerts);
                            if (json != null) {
                                status.put("alerts", json);
                                resultJson.put("alerts", json);
                            }
                        }
                    }

                    if (tempDataMap.toString().contains("faults")) {

                        String faults = tempDataMap.get("faults").toString();
                        if (faults != null && faults.length() != 0) {
                            JSONObject json = new JSONObject(faults);
                            if (json != null) {
                                status.put("faults", json);
                                resultJson.put("faults", json);
                            }
                        }
                    }

                    // if (tempDataMap.toString().contains("binary")) {
                    //     byte[] byteStr = (byte[]) tempDataMap.get("binary");
                    //     if (byteStr != null) {
                    //         String binary = GizWifiBinary.encode(byteStr);
                    //         if (binary != null && binary.length() != 0) {
                    //             status.put("binary", binary);
                    //             resultJson.put("binary", binary);
                    //         }
                    //     }
                    // }

                    if (tempDataMap.toString().contains("binary")) {
                        byte[] byteStr = (byte[]) tempDataMap.get("binary");
                        JSONArray jsonArray;
                        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.KITKAT) {
                            jsonArray = new JSONArray(byteStr);
                            for (int i = 0; i < jsonArray.length(); i++) {
                                jsonArray.put(i, ((Byte) jsonArray.get(i)) & 0xff);
                            }
                        } else {
                            jsonArray = new JSONArray();
                            for (int i = 0; i < byteStr.length; i++) {
                                jsonArray.put(byteStr[i]);
                            }
                        }
//                                        String str = bytesToHex(byteStr);
                        status.put("binary", jsonArray);
                        resultJson.put("binary", jsonArray);
                        Log.e("GizSDKClientLog", "Value=" + jsonArray.toString());
                    }

                    // resultJson.put("status", status);
                }

                // 状态上报回调，只在成功时回调就可以了


                // 控制命令回调
                resultJson.put("sn", sn);
                sendResultEvent(writeCallback.get(sn+""), resultJson, null);
                writeCallback.remove(sn+"");

                // 状态查询回调
                sendResultEvent(getDeviceStatusCallback.get(sn + ""), resultJson, null);
                getDeviceStatusCallback.remove(sn + "");



                if (device != null) {
                    JSONObject deviceobj = new JSONObject();
                    deviceobj.put("mac", device.getMacAddress());
                    deviceobj.put("did", device.getDid());
                    deviceobj.put("productKey", device.getProductKey());
                    // deviceobj.put("productName", device.getProductName());
                    deviceobj.put("ip", device.getIPAddress());
                    // deviceobj.put("passcode", device.getPasscode());
                    // deviceobj.put("isConnected", device.isConnected());
                    // deviceobj.put("isOnline", device.isOnline());
                    // deviceobj.put("isLAN", device.isLAN());
                    // deviceobj.put("isDisabled", device.isDisabled());
                    // deviceobj.put("remark", device.getRemark());
                    // deviceobj.put("alias", device.getAlias());
                    // deviceobj.put("isBind", device.isBind());
                    // deviceobj.put("rootDeviceId", device.getRootDevice() == null ? "" : device.getRootDevice().getDid());
                    // deviceobj.put("isProductDefined", device.isProductDefined());
                    deviceobj.put("isSubscribed", device.isSubscribed());
                    // deviceobj.put("isLowPower",device.isLowPower());
                    // deviceobj.put("isDormant",device.isDormant());
                    // deviceobj.put("stateLastTimestamp",device.getStateLastTimestamp());
                    // deviceobj.put("sleepDuration",device.getSleepDuration());
                    int type = 0;
                    if (device.getProductType() == GizWifiDeviceType.GizDeviceCenterControl) {
                        type = 1;
                    }
                    // deviceobj.put("type", type);

//                            isConnected = device.isConnected();
//                            isOnline = device.isOnline();
                    if (device.getNetStatus() == GizWifiDeviceNetStatus.GizDeviceOffline) {
                        netStatus = 0;
                    } else if (device.getNetStatus() == GizWifiDeviceNetStatus.GizDeviceOnline) {
                        netStatus = 1;
                    } else if (device.getNetStatus() == GizWifiDeviceNetStatus.GizDeviceControlled) {
                        netStatus = 2;
                    }
                    deviceobj.put("netStatus", netStatus);
                    resultJson.put("device", deviceobj);
                }
//                        resultJson.put("isConnected", isConnected); // 用于兼容
//                        resultJson.put("isOnline", isOnline); // 用于兼容
                resultJson.put("netStatus", netStatus);
                // 检查是否是蓝牙设备。如果是蓝牙设备的话
                if(device instanceof GizWifiBleDevice){
                    resultJson.put("isBlueLocal", ((GizWifiBleDevice)device).isBlueLocal());
                }

                if (isAppToDev) {
                    callbackAppToDevDeviceStatus(resultJson);
                } else {
                    callbackDeviceStatus(resultJson);
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
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
        }catch (Exception e)
        {

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

    public void callbackDeviceStatus(JSONObject params) {
        ReactApplicationContext context = getReactApplicationContext();
        emitJSI(context.getJavaScriptContextHolder().get(), "GizDeviceStatusNotifications", params.toString());
    }

    public void callbackAppToDevDeviceStatus(JSONObject params) {
        WritableMap writableMap = jsonObject2WriteableMap(params);
        reactContext
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit("GizDeviceAppToDevNotifications", writableMap);
    }

    public void callbackBleOTAStatus(JSONObject params) {
        WritableMap writableMap = jsonObject2WriteableMap(params);
        reactContext
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit("GizDeviceBleOTAStatus", writableMap);
    }

    public void callbackBleOTAProgress(JSONObject params) {
        WritableMap writableMap = jsonObject2WriteableMap(params);
        reactContext
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit("GizDeviceBleOTAProgress", writableMap);
    }

}
