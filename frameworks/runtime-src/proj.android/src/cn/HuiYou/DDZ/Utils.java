/**
 * Copyright (c) 2015 深圳市辉游科技有限公司.
 */

package cn.HuiYou.DDZ;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import android.content.Intent;
import android.provider.Settings;
import android.util.Log;
import org.cocos2dx.lib.Cocos2dxHelper;


public class Utils {
	
    private static String TAG = Utils.class.getName();
    private static List<String> sdcards = null;

	public static List<String> getStorageList() {

        List<String> list = new ArrayList<String>();
        
        BufferedReader buf_reader = null;
        try {
        	File fMntSdcard = new File("/mnt/sdcard");
        	if (fMntSdcard.exists() && fMntSdcard.canWrite()) {
        		Log.d(TAG, "found /mnt/sdcard is writable");
        		list.add("/mnt/sdcard");
        		return list;
        	}
        	
            buf_reader = new BufferedReader(new FileReader("/proc/mounts"));
            String line;
            Log.d(TAG , "/proc/mounts");
            while ((line = buf_reader.readLine()) != null) {
                Log.d(TAG, line);
                if (line.contains("vfat")) {
                	String[] info = line.split(" ");
                	
                	if (line.contains("secure") 
                			|| line.contains("asec") 
                			|| line.contains("obb") 
                			|| line.contains("mapper")
                      || line.contains("tmpfs")
                			|| line.contains("loop")
                			|| line.contains("lfs")) {
                		continue;
                	}
                	
                	if (!info[0].startsWith("/dev/block/vold/") && !info[3].contains("rw")){
                		continue;
                	}
                	
                	list.add(info[1]);
                }
            }

        } catch (FileNotFoundException ex) {
            ex.printStackTrace();
        } catch (IOException ex) {
            ex.printStackTrace();
        } finally {
            if (buf_reader != null) {
                try {
                    buf_reader.close();
                } catch (IOException ex) {}
                buf_reader = null;
            }
        }
        return list;
    }
	
	public static boolean hasExternalStorage() {
		
		if (sdcards == null)
			sdcards = getStorageList();
		
//		String sdState = Environment.getExternalStorageState();
//		if (Environment.MEDIA_MOUNTED.equals(sdState))
//			return true;
//		
		return sdcards.size()>0;
	}
	
	
	
	public static String getExternalStorageDirectory() {
		if (sdcards == null)
			sdcards = getStorageList();
		
		if (sdcards.size() == 0)
			return Cocos2dxHelper.getCocos2dxWritablePath();
			//return "";
		
		return sdcards.get(0);
//		File dir = Environment.getExternalStorageDirectory();
//		System.out.println(String.format("SDCard '%s' writable: %s", dir.getAbsolutePath(), dir.canWrite()));
//		
//		String extSdName = "EXTERNAL_STORAGE";
//		String[] suffix = {"", "2"};
//		for(int i=0; i<suffix.length; i++) {
//			String sdName = extSdName + suffix[i];
//			String path = System.getenv(sdName) + "/fungame";
//			File f = new File(path);
//			boolean result = f.mkdir();
//			System.out.println(sdName + " => " + path + " mkdirs: " + result);
//		}
		
		//return dir.getAbsolutePath();
	}
	
	public static String mkdir(String path, boolean hasFilename) {
		File file = null;
		if (path.startsWith("/")) {
			file = new File(path);
		} else {
			file = new File(getExternalStorageDirectory(), path);
		}

		if (hasFilename) {
			file = file.getParentFile();
		}
		
		if (file.isFile()) {
			return null;
		} else if (file.isDirectory()) {
			return file.getAbsolutePath();
		}
		
		boolean result = file.mkdirs();
		System.out.println(String.format("mkdir '%s' %s", file.getAbsolutePath(), result));
		return file.getAbsolutePath();	
	}
	
	public static boolean removeFile(String path) {
		File file = null;
		if (path.startsWith("/")) {
			file = new File(path);
		} else {
			file = new File(getExternalStorageDirectory(), path);
		}
	
		if (file.exists()) {
			file.delete();
		}
		
		return true;
	}
	
	public static void wifiSetting() {
		AppActivity.activity.startActivity(new Intent(Settings.ACTION_WIFI_SETTINGS));
	}
}
