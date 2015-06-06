/**
 * Copyright (c) 2015 深圳市辉游科技有限公司.
 */

package com.fungame.DDZ;

import java.util.HashMap;
import java.util.Map;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.telephony.TelephonyManager;

public class MobileInfoGetter {

	/**
	 * android.permission.READ_PHONE_STATE
	 */
	public static Context mContext;
	private TelephonyManager tm;
	private String MAC;

	public MobileInfoGetter() {
		mContext = AppActivity.getContext();
		tm = (TelephonyManager) mContext
				.getSystemService(Context.TELEPHONY_SERVICE);
	}

	public String getFingerprint() {
		return Build.FINGERPRINT;
	}

	public String getId() {
		return Build.ID;
	}

	public String getDisplay() {
		return Build.DISPLAY;
	}

	public String getProduct() {
		return Build.PRODUCT;
	}

	public String getDevice() {
		return Build.DEVICE;
	}

	public String getBoard() {
		return Build.BOARD;
	}

	public String getCpu_Abi() {
		return Build.CPU_ABI;
	}

	public String getManufacture() {
		return Build.MANUFACTURER;
	}

	public String getVersion() {
		return Build.VERSION.RELEASE;
	}

	public String getModel() {
		return Build.MODEL;
	}

	public String getBrand() {
		return Build.BRAND;
	}

	public String getImsi() {
		String imsi = tm.getSubscriberId();
		return imsi;
	}

	public String getImei() {
		return tm.getDeviceId();
	}
	
	public String getMobilePossible() {
		return tm.getLine1Number();
	}

	/**
	 * need permission: android.permission.ACCESS_WIFI_STATE
	 * 
	 * @return
	 */
	public String getMac() {
		if (MAC == null) {
			WifiManager mgr = (WifiManager) mContext
					.getSystemService(Context.WIFI_SERVICE);
			WifiInfo info = mgr.getConnectionInfo();
			MAC = info.getMacAddress();
		}
		return MAC != null ? MAC : "00:00:00:00:00:00";
	}

	//"wifi", "mobile:2g", "mobile:3g"
	public String getNetworkType() {
		return NetworkListener.getNetworkType(mContext);
	}
	
	public Map<String, String> getAllInfo() {
		Map<String, String> infos = new HashMap<String, String>();
		infos.put("hw_imei", getImei());
		infos.put("hw_mac", getMac());
		infos.put("hw_imsi", getImsi());
		infos.put("hw_brand", getBrand());
		infos.put("hw_model", getModel());
		infos.put("hw_version", getVersion());
		infos.put("hw_manufacture", getManufacture());
		infos.put("hw_cpu_abi", getCpu_Abi());
		infos.put("hw_board", getBoard());
		infos.put("hw_device", getDevice());
		infos.put("hw_product", getProduct());
		infos.put("hw_display", getDisplay());
		infos.put("hw_id", getId());
		infos.put("hw_fingerprint", getFingerprint());
		//infos.put("hw_mobilepossible", getMobilePossible());
		return infos;
	}
	
	public static String getAllInfoString() {
		String jsonString = "";
		
		MobileInfoGetter getter = new MobileInfoGetter();
		
		JSONObject jsonRoot = new JSONObject();
		try {
			jsonRoot.put("imei", getter.getImei());
			jsonRoot.put("mac", getter.getMac());
			jsonRoot.put("imsi", getter.getImsi());
			jsonRoot.put("brand", getter.getBrand());
			jsonRoot.put("model", getter.getModel());
			jsonRoot.put("os_ver", getter.getVersion());
			jsonRoot.put("manufacture", getter.getManufacture());
			jsonRoot.put("cpu_abi", getter.getCpu_Abi());
			jsonRoot.put("board", getter.getBoard());
			jsonRoot.put("device", getter.getDevice());
			jsonRoot.put("product", getter.getProduct());
			jsonRoot.put("display", getter.getDisplay());
			jsonRoot.put("id", getter.getId());
			jsonRoot.put("fingerprint", getter.getFingerprint());
			jsonRoot.put("network", getter.getNetworkType());
			jsonString = jsonRoot.toString();
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		return jsonString;
	}
	
}
