import sys
import os, os.path
import shutil
import time 
import datetime 
from optparse import OptionParser
from xml.etree import ElementTree
import subprocess
import json
import hashlib
import io

import zipfile
from zipfile import ZipFile

xxtea_enc = None
xxtea_key = None
xxtea_sign = None

versionInfo = {}

import struct 

_DELTA = 0x9E3779B9  

def _long2str(v, w):  
    n = (len(v) - 1) << 2  
    if w:  
        m = v[-1]  
        if (m < n - 3) or (m > n): return ''  
        n = m  
    s = struct.pack('<%iL' % len(v), *v)  
    return s[0:n] if w else s  
  
def _str2long(s, w):  
    n = len(s)  
    m = (4 - (n & 3) & 3) + n  
    s = s.ljust(m, "\0")  
    v = list(struct.unpack('<%iL' % (m >> 2), s))  
    if w: v.append(n)  
    return v  
  
def encrypt(str, key):  
    if str == '': return str  
    v = _str2long(str, True)  
    k = _str2long(key.ljust(16, "\0"), False)  
    n = len(v) - 1  
    z = v[n]  
    y = v[0]  
    sum = 0  
    q = 6 + 52 // (n + 1)  
    while q > 0:  
        sum = (sum + _DELTA) & 0xffffffff  
        e = sum >> 2 & 3  
        for p in xrange(n):  
            y = v[p + 1]  
            v[p] = (v[p] + ((z >> 5 ^ y << 2) + (y >> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z))) & 0xffffffff  
            z = v[p]  
        y = v[0]  
        v[n] = (v[n] + ((z >> 5 ^ y << 2) + (y >> 3 ^ z << 4) ^ (sum ^ y) + (k[n & 3 ^ e] ^ z))) & 0xffffffff  
        z = v[n]  
        q -= 1  
    return _long2str(v, False)  
  
def decrypt(str, key):  
    if str == '': return str  
    v = _str2long(str, False)  
    k = _str2long(key.ljust(16, "\0"), False)  
    n = len(v) - 1  
    z = v[n]  
    y = v[0]  
    q = 6 + 52 // (n + 1)  
    sum = (q * _DELTA) & 0xffffffff  
    while (sum != 0):  
        e = sum >> 2 & 3  
        for p in xrange(n, 0, -1):  
            z = v[p - 1]  
            v[p] = (v[p] - ((z >> 5 ^ y << 2) + (y >> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z))) & 0xffffffff  
            y = v[p]  
        z = v[n]  
        v[0] = (v[0] - ((z >> 5 ^ y << 2) + (y >> 3 ^ z << 4) ^ (sum ^ y) + (k[0 & 3 ^ e] ^ z))) & 0xffffffff  
        y = v[0]  
        sum = (sum - _DELTA) & 0xffffffff  
    return _long2str(v, True)  




def read_xml(proj_path, assets_dir):
  text = open(os.path.join(proj_path, "AndroidManifest.xml")).read()
  root = ElementTree.fromstring(text)
  version = root.attrib['{http://schemas.android.com/apk/res/android}versionName']
  versionCode = root.attrib['{http://schemas.android.com/apk/res/android}versionCode']
  packageName = root.attrib['package']
  now = datetime.datetime.now().strftime('%Y-%m-%d %H:%M')
  # output = open(os.path.join(assets_dir, "version.lua"), 'w')
  # print ('\n\nwrite ' + assets_dir + '/version.lua')
  # print assets_dir
  # output.write('return \'' + version + '_' + now + '\'')
  # output.close

  # versionInfo = {}
  global versionInfo
  versionInfo['package'] = packageName
  versionInfo['version'] = version
  versionInfo['versionCode'] = versionCode
  versionInfo['timestamp'] = now

  # versionInfo_file = io.open(os.path.join(assets_dir, 'versionInfo.json'), 'wb')
  # versionInfo_file.write(json.dumps(versionInfo, sort_keys=True, indent=2, separators=(',', ': ')))
  # versionInfo_file.close()


def compile_lua(src, dst):
  for item in os.listdir(src):
    path = os.path.join(src, item)
    # Android can not package the file that ends with ".gz"
    if not item.startswith('.') and not item.endswith('.gz') and os.path.isfile(path) and item.endswith('.lua'):
      dst_file = os.path.join(dst, item)
      cmd = '/usr/local/bin/luajit -bg -t raw %s %s' % (path, dst_file)
      print cmd
      if os.system(cmd) != 0:
        raise RuntimeError("Couldn't compile lua")
    if os.path.isdir(path):
      new_dst = os.path.join(dst, item)
      if not os.path.exists(new_dst):
        os.mkdir(new_dst)
      compile_lua(path, new_dst)
    
def compile_resources(lua_src_dir, assets_dst_dir):
  assets_dir = assets_dst_dir
  scripts_dir = os.path.normpath(lua_src_dir)
  #compile_lua(scripts_dir, assets_dir)
  compiler = '%s luacompile ' % (os.path.join(os.path.dirname(sys.argv[0]), 'cocos'))
  options = ''
  if xxtea_enc:
    options = ' -e -k "%s" -b "%s" ' % (xxtea_key, xxtea_sign)

  command = '%s %s -s "%s" -d "%s"' % (compiler, options, scripts_dir, assets_dir)

  print('COMMAND => ', command)
  ret = subprocess.call(command, shell=True)
  if ret != 0:
      message = "Error running command, return code: %s" % str(ret)
      raise RuntimeError(message)


def generate_app_version(proj_path, assets_dir):
  global versionInfo
  read_xml(proj_path, assets_dir)
  output = open(os.path.join(assets_dir, "version.lua"), 'w')
  print ('\n\nwrite ' + assets_dir + '/version.lua')
  print assets_dir
  output.write('return \'' + versionInfo['version'] + '_' + versionInfo['timestamp'] + '\'')
  output.close

def zip_lua(proj_path, lua_dir, assets_dir):
  # print('proj_path: %s' %(proj_path))
  # lua_dst_dir = os.path.normpath(os.path.join(proj_path, 'temp', 'luaScripts'))
  # print('shutil.rmtree(%s)' % (lua_dst_dir))
  # shutil.rmtree(lua_dst_dir)
  # print('mkdir %s' % (lua_dst_dir))
  # #os.mkdir(lua_dst_dir)
  # print('copytree ..')
  # shutil.copytree(os.path.join(proj_path, 'luaScripts'), lua_dst_dir)
  shutil.copytree(os.path.join(proj_path, 'src', 'cocos'), os.path.join(lua_dir, 'bootstrap', 'cocos'))
  os.system('cd %s && zip -r ../../../bootstrap.zip *' %(os.path.join(lua_dir, 'bootstrap')))
  os.system('cd %s && zip -r ../../../main.zip *' %(os.path.join(lua_dir, 'main')))
  shutil.copy(os.path.join(proj_path, 'bootstrap.zip'), os.path.join(assets_dir, 'bootstrap.zip'))
  shutil.copy(os.path.join(proj_path, 'main.zip'), os.path.join(assets_dir, 'main.zip'))
  shutil.copy(os.path.join(lua_dir, 'version.luac'), os.path.join(assets_dir, 'version.luac'))

def make_update_resources(proj_path, update_pkg_path):
  global versionInfo
  shutil.rmtree(update_pkg_path, True)
  prog_path = os.path.join(update_pkg_path, 'prog')
  os.makedirs(prog_path)
  shutil.copy(os.path.join(proj_path, 'bootstrap.zip'), prog_path)
  shutil.copy(os.path.join(proj_path, 'main.zip'), prog_path)
  shutil.copy(os.path.join(proj_path, 'temp', 'luaScripts', 'version.luac'), prog_path)
  shutil.copytree(os.path.join(proj_path, 'Resources'), os.path.join(update_pkg_path, 'res'))

  versionInfo_file = io.open(os.path.join(update_pkg_path, 'versionInfo.json'), 'wb')
  versionInfo_file.write(json.dumps(versionInfo, sort_keys=True, indent=2, separators=(',', ': ')))
  versionInfo_file.close()


  # versionInfo_file = io.open(os.path.join(assets_dir, 'versionInfo.json'), 'wb')
  # versionInfo_file.write(json.dumps(versionInfo, sort_keys=True, indent=2, separators=(',', ': ')))
  # versionInfo_file.close()

  print('create pkgZipFile')
  pkgZipFile = ZipFile(os.path.join(proj_path, 'update_pkg.zip'), 'w')
  assets_md5 = {}

  def zip_update_pkg(zipFile, assets_md5, res_path, dst_path):
    print('zip_update_pkg: ', res_path)
    for item in os.listdir(res_path):
      path = os.path.join(res_path, item)
      # Android can not package the file that ends with ".gz"
      if os.path.isfile(path):
        dst_file = os.path.join(dst_path, item)
        zipFile.write(path, dst_file, zipfile.ZIP_DEFLATED)
        md5 = hashlib.md5()
        src_file = io.open(path, 'rb')
        src_data = src_file.read()
        src_file.close()
        md5.update(src_data)
        md5_str = md5.hexdigest()
        assets_md5[dst_file] = {"md5": md5_str}
        msg = '[ZIP] add %s as %s , md5: %s' % (path, dst_file, md5_str)
        print msg
      if os.path.isdir(path):
        new_dst = os.path.join(dst_path, item)
        zip_update_pkg(zipFile, assets_md5, path, new_dst)

  print('start to packaging')
  zip_update_pkg(pkgZipFile, assets_md5, update_pkg_path, '')
  pkgZipFile.close()

  with io.open(os.path.join(proj_path, 'update_config.json'), 'rb') as cfg:
    version_template = json.load(cfg)
    cfg.close()

  version_template["version"] = versionInfo["version"] + "_" + versionInfo["timestamp"]
  asset_md5_file = io.open(os.path.join(proj_path, 'Resources', 'project.manifest'), 'wb')
  asset_md5_file.write(json.dumps(version_template, sort_keys=True, indent=2, separators=(',', ': ')))
  asset_md5_file.close()


  version_template["assets"] = assets_md5

  asset_md5_file = io.open(os.path.join(proj_path, 'assets_md5.txt'), 'wb')
  asset_md5_file.write(json.dumps(version_template, sort_keys=True, indent=2, separators=(',', ': ')))
  asset_md5_file.close()

def parse_args():
  global xxtea_enc, xxtea_key, xxtea_sign
  if xxtea_enc != None:
    return

  from argparse import ArgumentParser

  parser = ArgumentParser()
  group = parser.add_argument_group("lua project arguments")
  group.add_argument("--lua-encrypt", dest="lua_encrypt", action="store_true", help="Enable the encrypting of lua scripts.")
  group.add_argument("--lua-encrypt-key", dest="lua_encrypt_key", help="Specify the encrypt key for the encrypting of lua scripts.")
  group.add_argument("--lua-encrypt-sign", dest="lua_encrypt_sign", help="Specify the encrypt sign for the encrypting of lua scripts.")
  (args, unkonw) = parser.parse_known_args(sys.argv)
  xxtea_enc = args.lua_encrypt
  xxtea_key = args.lua_encrypt_key
  xxtea_sign = args.lua_encrypt_sign

  print("====== args => ", args)
  print("====== xxtea_enc:", xxtea_enc, ", xxtea_key: ", xxtea_key, ", xxtea_sign: ", xxtea_sign)



def handle_event(event, tp, args):
  #print('__handle_event', event, tp, args)
  parse_args()
  platform_proj_dir = args['platform-project-path']
  proj_path = args["project-path"]
  lua_src_dir = os.path.normpath(os.path.join(proj_path, "luaScripts"))
  lua_dst_dir = os.path.normpath(os.path.join(proj_path, 'temp', 'luaScripts'))
  # print('\n ========argv[0]: %s \n' % (sys.argv[0]))
  # print('\n ========argv: \n' , sys.argv)

  if event == 'pre-copy-assets':
    cocos_dst_dir = os.path.normpath(os.path.join(proj_path, "src", 'cocos'))
    cocos_src_dir = os.path.join(proj_path, 'frameworks', 'cocos2d-x', 'cocos', 'scripting', 'lua-bindings', 'script')
    # shutil.rmtree(cocos_dst_dir, True)
    # shutil.copytree(cocos_src_dir, cocos_dst_dir)

  elif event == 'post-copy-assets':
    zip_file = os.path.join(proj_path, "luaScripts.zip")
    print('lua_src_dir: ' , lua_src_dir)
    print('lua_dst_dir: ' , lua_dst_dir)
    shutil.rmtree(lua_dst_dir, True)
    os.makedirs(lua_dst_dir)
    assets_dir = args['assets-dir']
    #compile_resources(lua_src_dir, assets_dir)
    if os.access(zip_file, os.F_OK):
      os.remove(os.path.join(proj_path, "luaScripts.zip"))
    print('to compile resources')
    generate_app_version(platform_proj_dir, lua_src_dir)
    compile_resources(lua_src_dir, lua_dst_dir)
    zip_lua(proj_path, lua_dst_dir, assets_dir)
    make_update_resources(proj_path, os.path.join(proj_path, 'temp', 'upd_pkg'))
    # shutil.copy( os.path.join(proj_path, 'Resources', 'project.manifest') , os.path.join(assets_dir, 'project.manifest'))
    shutil.copy( os.path.join(proj_path, 'assets_md5.txt') , os.path.join(assets_dir, 'project.manifest'))
    #shutil.copy(os.path.normpath(os.path.join(args["project-path"], "luaScripts.zip")), os.path.join(assets_dir, "luaScripts.zip")) 
    # umengJarPath = os.path.normpath(os.path.join(platform_proj_dir, "..", "3rdLibs", "umeng", "android"))
    # umengJarFile = "mobclickcpphelper.jar"
    # shutil.copy( os.path.join(umengJarPath, umengJarFile) , os.path.join(platform_proj_dir, "libs", umengJarFile))
    # talkingDataJarPath = os.path.normpath(os.path.join(platform_proj_dir, "..", "3rdLibs", "TalkingData", "proj.android", "libs"))
    # talkingDataJarFile = "Game_Analytics_SDK_Android_3.0.64.jar"
    # shutil.copy( os.path.join(talkingDataJarPath, talkingDataJarFile) , os.path.join(platform_proj_dir, "libs", talkingDataJarFile))

    anySdkJarPath = os.path.normpath(os.path.join(platform_proj_dir, "protocols", "android"))
    anySdkJarFile = "libPluginProtocol.jar"
    shutil.copy( os.path.join(anySdkJarPath, anySdkJarFile) , os.path.join(platform_proj_dir, "libs", anySdkJarFile))
