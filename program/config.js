// skip 1st line
try {
  let Cu = Components.utils;
  Cu.import('resource://gre/modules/osfile.jsm');
  Cu.import(OS.Path.toFileURI(OS.Constants.Path.profileDir)+'/chrome/utils/boot.jsm');
} catch(ex) {};
