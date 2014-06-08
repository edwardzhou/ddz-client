import sys
import os, os.path
import shutil
import time 
import datetime 
from optparse import OptionParser
from xml.etree import ElementTree

def read_xml(proj_path, assets_dir):
  text = open(os.path.join(proj_path, "AndroidManifest.xml")).read()
  root = ElementTree.fromstring(text)
  version = root.attrib['{http://schemas.android.com/apk/res/android}versionName']
  now = datetime.datetime.now().strftime('%Y-%m-%d %H:%M')
  output = open(os.path.join(assets_dir, "version.lua"), 'w')
  print ('\n\nwrite ' + assets_dir + '/version.lua')
  print assets_dir
  output.write('return \'' + version + '_' + now + '\'')
  output.close


def compile_lua(src, dst):
  for item in os.listdir(src):
    path = os.path.join(src, item)
    # Android can not package the file that ends with ".gz"
    if not item.startswith('.') and not item.endswith('.gz') and os.path.isfile(path) and item.endswith('.lua'):
      dst_file = os.path.join(dst, item)
      cmd = '/usr/local/bin/luajit -bg -t raw %s %s' % (path, dst_file)
      print cmd
      os.system(cmd)
    if os.path.isdir(path):
      new_dst = os.path.join(dst, item)
      os.mkdir(new_dst)
      compile_lua(path, new_dst)
    
def compile_resources(lua_src_dir, assets_dst_dir):
  assets_dir = assets_dst_dir
  scripts_dir = os.path.normpath(lua_src_dir)
  compile_lua(scripts_dir, assets_dir)

def generate_app_version(proj_path, assets_dir):
  read_xml(proj_path, assets_dir)


class CustomBuilder(object):
  def __init__(self, builder):
    self.builder = builder

  def after_copy_assets(self):
    print "Hi~, app_android_root is %s" % (self.builder.app_android_root)
    lua_src_dir = os.path.normpath(os.path.join(self.builder.app_android_root, "../../../luaScripts"))
    assets_dir = os.path.normpath(os.path.join(self.builder.app_android_root, 'assets'))
    compile_resources(lua_src_dir, assets_dir)
    generate_app_version(self.builder.app_android_root, assets_dir) 


def handle_event(event, tp, args):
  print('__handle_event', event, tp, args)
  if event == 'post-copy-assets':
    platform_proj_dir = args['platform-project-path']
    lua_src_dir = os.path.normpath(os.path.join(args["project-path"], "luaScripts"))
    print('lua_src_dir: ' , lua_src_dir)
    assets_dir = args['assets-dir']
    compile_resources(lua_src_dir, assets_dir)
    generate_app_version(platform_proj_dir, assets_dir)
