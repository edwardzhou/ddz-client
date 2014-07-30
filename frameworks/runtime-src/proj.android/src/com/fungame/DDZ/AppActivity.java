/****************************************************************************
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2011      Zynga Inc.
Copyright (c) 2013-2014 Chukong Technologies Inc.
 
http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
package com.fungame.DDZ;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.security.cert.CertificateException;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;

import org.cocos2dx.lib.Cocos2dxActivity;
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

import com.umeng.analytics.MobclickAgent;

public class AppActivity extends Cocos2dxActivity {
	private NetworkListener networkListener = new NetworkListener();
	public boolean appInForeground = true;
	public static AppActivity activity = null;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		
		activity = this;
		
		try {
			PackageInfo info = this.getContext().getPackageManager().getPackageInfo(this.getContext().getPackageName(), PackageManager.GET_SIGNATURES);
			System.out.println("PackageName: " + this.getContext().getPackageName());
			   final String strName = info.applicationInfo.loadLabel(this.getContext().getPackageManager()).toString();
			    final String strVendor = info.packageName;
			    StringBuffer sb = new StringBuffer();
			    sb.append("\n" + strName + " / " + strVendor + "\n");

			    for (Signature sign : info.signatures) {
				System.out.println("Signature CharsString: " + sign.toCharsString());
				System.out.println("Signature toString: " + sign.toString());
				this.printHex(sign.toByteArray());
				
		        final byte[] rawCert = sign.toByteArray();
		        InputStream certStream = new ByteArrayInputStream(rawCert);

		        final CertificateFactory certFactory;
		        final X509Certificate x509Cert;
		        try {
		            certFactory = CertificateFactory.getInstance("X509");
		            x509Cert = (X509Certificate) certFactory.generateCertificate(certStream);

		            sb.append("Certificate subject: " + x509Cert.getSubjectDN() + "\n");
		            sb.append("Certificate issuer: " + x509Cert.getIssuerDN() + "\n");
		            sb.append("Certificate serial number: " + x509Cert.getSerialNumber() + "\n");
		            sb.append("\n");
		        }
		        catch (CertificateException e) {
		            // e.printStackTrace();
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
		
		
		//MobileInfoGetter.mContext = AppActivity.getContext();
	}
	
	@Override
	protected void onDestroy() {
		super.onDestroy();
		System.out.println("unregister network listener");
		unregisterReceiver(networkListener);
	};

	@Override
    public Cocos2dxGLSurfaceView onCreateView() {
        Cocos2dxGLSurfaceView glSurfaceView = new Cocos2dxGLSurfaceView(this);
        // TestCpp should create stencil buffer
        glSurfaceView.setEGLConfigChooser(5, 6, 5, 0, 16, 8);
        com.umeng.analytics.game.UMGameAgent.init(getContext());
        System.out.println("Device Info*********************: " + getDeviceInfo(this.getApplicationContext()));
        
        return glSurfaceView;
    }
    
    @Override
    public void onResume() {
      super.onResume();
      MobclickAgent.onResume(this);
    }

    @Override
    public void onPause() {
      super.onPause();
      MobclickAgent.onPause(this);
    }
    
    public static void enterBackground() {
    	activity.appInForeground = false;
    }
    
    public static void enterForground() {
    	activity.appInForeground = true;
    }


    public static String getDeviceInfo(Context context) {
        try{
          org.json.JSONObject json = new org.json.JSONObject();
          android.telephony.TelephonyManager tm = (android.telephony.TelephonyManager) context
              .getSystemService(Context.TELEPHONY_SERVICE);
      
          String device_id = tm.getDeviceId();
          
          android.net.wifi.WifiManager wifi = (android.net.wifi.WifiManager) context.getSystemService(Context.WIFI_SERVICE);
              
          String mac = wifi.getConnectionInfo().getMacAddress();
          json.put("mac", mac);
          
          if( TextUtils.isEmpty(device_id) ){
            device_id = mac;
          }
          
          if( TextUtils.isEmpty(device_id) ){
            device_id = android.provider.Settings.Secure.getString(context.getContentResolver(),android.provider.Settings.Secure.ANDROID_ID);
          }
          
          json.put("device_id", device_id);
          
          return json.toString();
        }catch(Exception e){
          e.printStackTrace();
        }
      return null;
    }

    private void printHex(byte[] buffer) {
      StringBuilder sb = new StringBuilder();
      StringBuilder sbAscii = new StringBuilder();
      for(int i=0; i<buffer.length; i++) {
    	  sb.append(String.format("%02x ", buffer[i]));
    	  if (buffer[i]<0x20 || buffer[i]>127) {
    		  sbAscii.append('.');
    	  } else {
    		  sbAscii.append(String.format("%c", buffer[i]));
    	  }
        
    	  if ((i+1) % 16 == 0) {
    		  sb.append(" |  ").append(sbAscii);
    		  System.out.println(sb.toString());
    		  sb = new StringBuilder();
    		  sbAscii = new StringBuilder();
    	  }
      }
      
      int n = 16 - buffer.length % 16;
      for(int i=0;i<n;i++) {
    	  sb.append("   ");
      }
      sb.append(" |  ").append(sbAscii);
	  System.out.println(sb.toString());
     
    }
                 

    static {
      System.loadLibrary("bspatch");
    }

 
}
