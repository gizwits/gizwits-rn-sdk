package com.reactlibrary;

import com.gizwits.gizwifisdk.api.GizWifiCentralControlDevice;
import com.gizwits.gizwifisdk.api.GizWifiDevice;
import com.gizwits.gizwifisdk.api.GizWifiSDK;
import com.gizwits.gizwifisdk.api.GizWifiSubDevice;
import com.gizwits.gizwifisdk.enumration.GizWifiDeviceType;
import com.gizwits.gizwifisdk.listener.GizWifiCentralControlDeviceListener;
import com.gizwits.gizwifisdk.listener.GizWifiDeviceListener;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Created by linyingqi on 2018/12/19.
 */

public class RNGizwitsDeviceCache {
    public GizWifiDeviceListener devicelistener;
    public GizWifiCentralControlDeviceListener centralControlDevicelistener;
    public GizWifiDeviceListener subDevicelistener;

    ConcurrentHashMap<JSONObject, List<GizWifiSubDevice>> subDeviceList = new ConcurrentHashMap<JSONObject, List<GizWifiSubDevice>>();

    Map<String, Integer> centralControlSubDeviceSizeList = new HashMap<String, Integer>();

    public Map<String, Integer> getCentralControlSubDeviceSizeList() {
        return centralControlSubDeviceSizeList;
    }

    public void setCentralControlSubDeviceSizeList(Map<String, Integer> centralControlSubDeviceSizeList) {
        centralControlSubDeviceSizeList = centralControlSubDeviceSizeList;
    }

    // 单例
    private static RNGizwitsDeviceCache deviceCache = new RNGizwitsDeviceCache() {
    };

    public static RNGizwitsDeviceCache getInstance() {
        return deviceCache;
    }

    // 设备监听
    public void setDeviceListener(GizWifiDeviceListener listener) {
        devicelistener = listener;
    }

    // 中控设备监听
    public void setCentralControlDevicelistener(GizWifiCentralControlDeviceListener listener) {
        centralControlDevicelistener = listener;
    }

    // 中控子设备监听
    public void setSubDevicelistener(GizWifiDeviceListener listener) {
        subDevicelistener = listener;
    }

    // 对每个设备设置监听
    public void setListenerForDeviceList(List<GizWifiDevice> devices) {
        for (int i = 0; i < devices.size(); i++) {
            GizWifiDevice device = devices.get(i);
            if (device.getProductType() == GizWifiDeviceType.GizDeviceCenterControl) {
                device.setListener(centralControlDevicelistener);
            } else {
                device.setListener(devicelistener);
            }
        }
    }

    // 在设备列表中找设备
    public GizWifiDevice findDeviceByMac(String mac, String did) {
        List<GizWifiDevice> deviceList = GizWifiSDK.sharedInstance().getDeviceList();
        for (int i = 0; i < deviceList.size(); i++) {
            GizWifiDevice device = deviceList.get(i);
            if (device.getMacAddress().equals(mac) && device.getDid().equals(did)) {
                return device;
            }
        }

        return null;
    }

    // 在设备列表中找设备
    public GizWifiDevice findDeviceByMac(String mac) {
        List<GizWifiDevice> deviceList = GizWifiSDK.sharedInstance().getDeviceList();
        for (int i = 0; i < deviceList.size(); i++) {
            GizWifiDevice device = deviceList.get(i);
            if (device.getMacAddress().equals(mac)) {
                return device;
            }
        }

        return null;
    }

    // 在设备列表中找中控设备
    public GizWifiCentralControlDevice findCenterControlDeviceByMac(String mac, String did) {
        List<GizWifiDevice> deviceList = GizWifiSDK.sharedInstance().getDeviceList();
        for (int i = 0; i < deviceList.size(); i++) {
            GizWifiDevice device = deviceList.get(i);
            if (device.getMacAddress().equals(mac) && device.getDid().equals(did) && device.getProductType() == GizWifiDeviceType.GizDeviceCenterControl) {
                return (GizWifiCentralControlDevice) device;
            }
        }
        return null;
    }

    // 在中控设备列表中找子设备
    public GizWifiDevice findSubDeviceByMac(GizWifiCentralControlDevice gizWifiCentralControlDevice, String mac) {
        if (gizWifiCentralControlDevice != null) {
            for (int i = 0; i < gizWifiCentralControlDevice.getSubDeviceList().size(); i++) {
                GizWifiDevice gizWifiDevice = gizWifiCentralControlDevice.getSubDeviceList().get(i);
                if (gizWifiDevice.getMacAddress().equals(mac))
                    return gizWifiDevice;
            }
        }
        return null;
    }


    // 为每个子设备设置监听
    public void setListenerForSubDeviceList(List<GizWifiSubDevice> subDevices) {
        for (GizWifiSubDevice subDevice : subDevices) {
            subDevice.setListener(subDevicelistener);
        }
    }

    // 在中控设备的子设备列表中找子设备
    public GizWifiSubDevice findDeviceBySubDid(String mac, String did, String subDid) {
        GizWifiDevice device = findDeviceByMac(mac, did);
        if (device == null || device.getProductType() != GizWifiDeviceType.GizDeviceCenterControl) {
            return null;
        }

        GizWifiSubDevice mSubDevice = null;

//		GizWifiCentralControlDevice mDevice = (GizWifiCentralControlDevice)device;
//		for (GizWifiSubDevice subDevice : mDevice.getSubDeviceList()) {
//			if(subDevice.getDid().equals(did) && subDevice.getMacAddress().equals(mac) && subDevice.getSubDid().equals(subDid)) {
//				mSubDevice = subDevice;
//				break;
//			}
//		}

        return mSubDevice;
    }
}
