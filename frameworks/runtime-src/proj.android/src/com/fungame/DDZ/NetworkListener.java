package com.fungame.DDZ;

import java.util.List;
import java.util.Locale;

import android.app.ActivityManager;
import android.app.ActivityManager.RunningTaskInfo;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.telephony.TelephonyManager;

public class NetworkListener extends BroadcastReceiver {
	
	private static NetworkState last_state = null;
	private static native void messageCpp(String event, String data);

	@Override
	public void onReceive(Context context, Intent intent) {
		boolean is_connected = isNetworkConnected(context);
		System.out.println("on network connectivity change:" + is_connected);
		String type = getNetworkType(context);
		if (null == last_state) {
			last_state = new NetworkState();
		} else if (is_connected == last_state.is_connected) {
			System.out.println("network connected state has not change, ignore");
			last_state.type = type;
			return;
		}
		System.out.println("process network connected state change");
		last_state.is_connected = is_connected;
		last_state.type = type;
		String str = "on_network_change_disable";
		if (is_connected) {
			str = "on_network_change_available";
		}
		
		final String eventName = str;
		
		AppActivity.activity.runOnGLThread(new Runnable() {
			
			@Override
			public void run() {
				// TODO Auto-generated method stub
				messageCpp(eventName, "");
			}
		});
		
		if (isAppForeground(context)) {
			//DDZJniHelper.messageToCpp(str);
		} else {
			System.out.println("app is in background, do not message network change");
		}
	}
	
	public static boolean isNetworkConnected(Context context) {
		ConnectivityManager cm = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo ni = cm.getActiveNetworkInfo();
		if (null == ni) return false;
		return ni.isAvailable() && ni.isConnected();
	}
	
	public static String getNetworkType(Context context) {
		ConnectivityManager cm = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo ni = cm.getActiveNetworkInfo();
		if (null == ni) return "no_network";
		String type = ni.getTypeName();
		type = type.toLowerCase(Locale.US);
		if (type.equalsIgnoreCase("mobile"))
			type = type + ":" + getMobileNetworkType(context);
		return type;
	}
	
	public static String getMobileNetworkType(Context context) {
		TelephonyManager tm = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
		int type = tm.getNetworkType();
		String ntype = "3g";
		if (1 == type || 2 == type || 4 == type)
			ntype = "2g";
		return ntype;
	}
	
	public static boolean isAppForeground(Context context) {
		String top_activity_name = getTopActivityName(context);
		System.out.println("top_activity_name:" + top_activity_name);
		return top_activity_name.startsWith("com.fungame.DDZ");
	}
	
	public static String getTopActivityName(Context context) {
		ActivityManager mgr = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
		List<RunningTaskInfo> tasksInfo = mgr.getRunningTasks(1);
		if (tasksInfo.size() > 0) {
		   ComponentName component = tasksInfo.get(0).topActivity;
		   String name = component.getClassName();
		   return name;
		}
		return "";
	}
	
	private class NetworkState {
		public boolean is_connected = false;
		public String type = "MOBILE:2G";
	}

}
