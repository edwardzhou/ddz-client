package com.fungame.DDZ;

import android.app.Activity;

import com.tendcloud.tenddata.TalkingDataGA;

public final class TalkingDataUtils {
	public static boolean inited = false;
	
	public static boolean isInited(){
		return inited;
	}
	
	public static void init(String appkey, String channel) {
		final String _appKey = appkey;
		final String _channel = channel;
		TalkingDataGA.init(AppActivity.activity, _appKey, _channel);
		inited = true;
		TalkingDataUtils.onResume(AppActivity.activity);
	}
	
	public static void onResume(Activity activity){
		if (inited) {
			System.out.println("TalkingDataUtils.onResume");
			TalkingDataGA.onResume(activity);
		}
	}
	
	public static void onPause(Activity activity) {
		if (inited) {
			System.out.println("TalkingDataUtils.onPause");
			TalkingDataGA.onPause(activity);
		}
	}
}
