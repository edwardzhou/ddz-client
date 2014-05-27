package com.fungame.DDZ;

import java.io.File;

import android.os.Environment;

public class Utils {
	public static boolean hasExternalStorage() {
		String sdState = Environment.getExternalStorageState();
		if (Environment.MEDIA_MOUNTED.equals(sdState))
			return true;
		
		return false;
	}
	
	public static String getExternalStorageDirectory() {
		File dir = Environment.getExternalStorageDirectory();
		return dir.getAbsolutePath();
	}
	
	public static String mkdir(String path, boolean hasFilename) {
		File file = null;
		if (path.startsWith("/")) {
			file = new File(path);
		} else {
			file = new File(Environment.getExternalStorageDirectory(), path);
		}

		if (hasFilename) {
			file = file.getParentFile();
		}
		
		if (file.isFile()) {
			return null;
		} else if (file.isDirectory()) {
			return file.getAbsolutePath();
		}
		
		file.mkdirs();
		return file.getAbsolutePath();	
	}
	
	public static boolean removeFile(String path) {
		File file = null;
		if (path.startsWith("/")) {
			file = new File(path);
		} else {
			file = new File(Environment.getExternalStorageDirectory(), path);
		}
	
		if (file.exists()) {
			file.delete();
		}
		
		return true;
	}
}
