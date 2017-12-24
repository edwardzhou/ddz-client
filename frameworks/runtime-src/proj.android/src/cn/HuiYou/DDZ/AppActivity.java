/**
 * Copyright (c) 2015 深圳市辉游科技有限公司.
 */

package cn.HuiYou.DDZ;

import java.io.BufferedInputStream;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.security.cert.CertificateException;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;
import java.util.HashMap;

import android.content.res.Configuration;


import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxHelper;
import org.cocos2dx.lib.Cocos2dxGLSurfaceView;

import android.content.Context;
import android.content.IntentFilter;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.content.pm.Signature;
import android.net.ConnectivityManager;
import android.os.Bundle;
import android.text.TextUtils;

import android.content.Intent;
import com.anysdk.framework.PluginWrapper;

//import com.umeng.analytics.MobclickAgent;

public class AppActivity extends Cocos2dxActivity {
	private NetworkListener networkListener = new NetworkListener();
	public boolean appInForeground = true;
	public static AppActivity activity = null;
	public static String progPath = null;
	public static String resPath = null;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		// PluginWrapper.init(this); // for plugins
		// PluginWrapper.setGLSurfaceView(Cocos2dxGLSurfaceView.getInstance());
		// PluginWrapper.loadAllPlugins();

		activity = this;

		try {
			File progFile = new File(Cocos2dxHelper.getCocos2dxWritablePath(),
					"prg");
			progFile.mkdirs();
			progPath = progFile.getAbsolutePath();
			File resFile = new File(Cocos2dxHelper.getCocos2dxWritablePath(),
					"res");
			resFile.mkdirs();
			resPath = resFile.getAbsolutePath();

			System.out.println("Prog Path: " + this.progPath);
			System.out.println("Res Path: " + this.resPath);

			PackageInfo info = this
					.getContext()
					.getPackageManager()
					.getPackageInfo(this.getContext().getPackageName(),
							PackageManager.GET_SIGNATURES);
			System.out.println("PackageName: "
					+ this.getContext().getPackageName());
			final String strName = info.applicationInfo.loadLabel(
					this.getContext().getPackageManager()).toString();
			final String strVendor = info.packageName;
			StringBuffer sb = new StringBuffer();
			sb.append("\n" + strName + " / " + strVendor + "\n");

			for (Signature sign : info.signatures) {
				System.out.println("Signature CharsString: "
						+ sign.toCharsString());
				System.out.println("Signature toString: " + sign.toString());
				this.printHex(sign.toByteArray());

				final byte[] rawCert = sign.toByteArray();
				InputStream certStream = new ByteArrayInputStream(rawCert);
				System.out.println("Signature to byte array, length: "
						+ rawCert.length);

				final CertificateFactory certFactory;
				final X509Certificate x509Cert;
				try {
					certFactory = CertificateFactory.getInstance("X509");
					x509Cert = (X509Certificate) certFactory
							.generateCertificate(certStream);

					sb.append("Certificate subject: " + x509Cert.getSubjectDN()
							+ "\n");
					sb.append("Certificate issuer: " + x509Cert.getIssuerDN()
							+ "\n");
					sb.append("Certificate serial number: "
							+ x509Cert.getSerialNumber() + "\n");
					sb.append("getSubjectX500Principal: "
							+ x509Cert.getSubjectX500Principal() + "\n");
					sb.append("getSubjectX500Principal.Name: "
							+ x509Cert.getSubjectX500Principal().getName()
							+ "\n");
					sb.append("getIssuerX500Principal: "
							+ x509Cert.getIssuerX500Principal() + "\n");
					sb.append("getIssuerX500Principal.Name: "
							+ x509Cert.getIssuerX500Principal().getName()
							+ "\n");
					sb.append("\n");
				} catch (CertificateException e) {
					e.printStackTrace();
				}

				System.out.println("Certficate: \n" + sb.toString());
			}

			IntentFilter intentFilter = new IntentFilter();
			intentFilter.addAction(ConnectivityManager.CONNECTIVITY_ACTION);
			System.out.println("register network listener");
			this.registerReceiver(networkListener, intentFilter);

		} catch (NameNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		// com.umeng.mobclickcpp.MobClickCppHelper.init(this);
		// com.umeng.analytics.game.UMGameAgent.init(getContext());
		System.out.println("Device Info*********************: "
				+ getDeviceInfo(this.getApplicationContext()));

//		TalkingDataUtils.init("D4DB1295EA1B3298DD256AF4BEBCFC0C", "official");
//		TalkingDataGA.init(this, "D4DB1295EA1B3298DD256AF4BEBCFC0C", "official");
		
		// MobileInfoGetter.mContext = AppActivity.getContext();
	}

	// protected HashMap<String, String> loadTalkingData() {
	// try {
	// BufferedInputStream stream= new
	// BufferedInputStream(this.getAssets().open("talkingdata.json"));
	// int bufferSize = stream.available();
	// byte[] buffer = new byte[bufferSize];
	// stream.read(buffer);
	// String jsonString = new String(buffer);
	// //JSONObject
	// } catch (IOException e) {
	// // TODO Auto-generated catch block
	// e.printStackTrace();
	// }
	// return null;
	// }
/*
	@Override
	protected void onDestroy() {
		PluginWrapper.onDestroy();
		super.onDestroy();
		System.out.println("unregister network listener");
		unregisterReceiver(networkListener);
	};

	@Override
	public void onResume() {
		PluginWrapper.onResume();
		super.onResume();
		// TalkingDataUtils.onResume(this);
		// MobclickAgent.onResume(this);
	}

	@Override
	public void onPause() {
		PluginWrapper.onPause();
		super.onPause();
		// TalkingDataUtils.onPause(this);
		// MobclickAgent.onPause(this);
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		PluginWrapper.onActivityResult(requestCode, resultCode, data);
		super.onActivityResult(requestCode, resultCode, data);
	}

	@Override
	protected void onNewIntent(Intent intent) {
		PluginWrapper.onNewIntent(intent);
		super.onNewIntent(intent);
	}

	@Override
	protected void onStop() {
		PluginWrapper.onStop();
		super.onStop();
	}

	@Override
	protected void onRestart() {
		PluginWrapper.onRestart();
		super.onRestart();
	}

	@Override
	public void onBackPressed() {
	    PluginWrapper.onBackPressed();
	    super.onBackPressed();
	}

	@Override
	public void onConfigurationChanged(Configuration newConfig) {
	    PluginWrapper.onConfigurationChanged(newConfig);
	    super.onConfigurationChanged(newConfig);
	}

	@Override
	protected void onRestoreInstanceState(Bundle savedInstanceState) {
	    PluginWrapper.onRestoreInstanceState(savedInstanceState);
	    super.onRestoreInstanceState(savedInstanceState);
	}

	@Override
	protected void onSaveInstanceState(Bundle outState) {
	    PluginWrapper.onSaveInstanceState(outState);
	    super.onSaveInstanceState(outState);
	}

	@Override
	protected void onStart() {
	    PluginWrapper.onStart();
	    super.onStart();
	}
*/

	public static void enterBackground() {
		activity.appInForeground = false;
	}

	public static void enterForground() {
		activity.appInForeground = true;
	}

	public static String getDeviceInfo(Context context) {
		try {
			org.json.JSONObject json = new org.json.JSONObject();
			android.telephony.TelephonyManager tm = (android.telephony.TelephonyManager) context
					.getSystemService(Context.TELEPHONY_SERVICE);

			String device_id = tm.getDeviceId();

			android.net.wifi.WifiManager wifi = (android.net.wifi.WifiManager) context
					.getSystemService(Context.WIFI_SERVICE);

			String mac = wifi.getConnectionInfo().getMacAddress();
			json.put("mac", mac);

			if (TextUtils.isEmpty(device_id)) {
				device_id = mac;
			}

			if (TextUtils.isEmpty(device_id)) {
				device_id = android.provider.Settings.Secure.getString(
						context.getContentResolver(),
						android.provider.Settings.Secure.ANDROID_ID);
			}

			json.put("device_id", device_id);

			return json.toString();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	private void printHex(byte[] buffer) {
		StringBuilder sb = new StringBuilder();
		StringBuilder sbAscii = new StringBuilder();
		for (int i = 0; i < buffer.length; i++) {
			sb.append(String.format("%02x ", buffer[i]));
			if (buffer[i] < 0x20 || buffer[i] > 127) {
				sbAscii.append('.');
			} else {
				sbAscii.append(String.format("%c", buffer[i]));
			}

			if ((i + 1) % 16 == 0) {
				sb.append(" |  ").append(sbAscii);
				System.out.println(sb.toString());
				sb = new StringBuilder();
				sbAscii = new StringBuilder();
			}
		}

		int n = 16 - buffer.length % 16;
		for (int i = 0; i < n; i++) {
			sb.append("   ");
		}
		sb.append(" |  ").append(sbAscii);
		System.out.println(sb.toString());

	}

	static {
		// System.loadLibrary("bspatch");
	}

}
