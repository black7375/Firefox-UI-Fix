let EXPORTED_SYMBOLS = [];

console.warn( "Browser is executing custom scripts via autoconfig" );
const {Services} = ChromeUtils.import('resource://gre/modules/Services.jsm');

const yPref = {
  get: function (prefPath) {
    const sPrefs = Services.prefs;
    try {
      switch (sPrefs.getPrefType(prefPath)) {
        case 0:
          return undefined;
        case 32:
          return sPrefs.getStringPref(prefPath);
        case 64:
          return sPrefs.getIntPref(prefPath);
        case 128:
          return sPrefs.getBoolPref(prefPath);
      }
    } catch (ex) {
      return undefined;
    }
    return;
  },
  set: function (prefPath, value) {
    const sPrefs = Services.prefs;
    switch (typeof value) {
      case 'string':
        return sPrefs.setCharPref(prefPath, value) || value;
      case 'number':
        return sPrefs.setIntPref(prefPath, value) || value;
      case 'boolean':
        return sPrefs.setBoolPref(prefPath, value) || value;
    }
    return;
  },
  addListener:(a,b)=>{ let o = (q,w,e)=>(b(yPref.get(e),e)); Services.prefs.addObserver(a,o);return{pref:a,observer:o}},
  removeListener:(a)=>( Services.prefs.removeObserver(a.pref,a.observer) )
}

let _uc = {
  BROWSERCHROME: 'chrome://browser/content/browser.xhtml',
  PREF_ENABLED: 'userChromeJS.enabled',
  PREF_SCRIPTSDISABLED: 'userChromeJS.scriptsDisabled',
  SCRIPT_DIR: 'JS',
  RESOURCE_DIR: 'resources',
  BASE_FILEURI: null, // set later

  get chromeDir() {return Services.dirsvc.get('UChrm',Ci.nsIFile)},
  
  get chromeDirEntries() {return _uc.chromeDir.directoryEntries.QueryInterface(Ci.nsISimpleEnumerator)},
  
  getDirectoryEntries: function(nsDirEnum,name,matchDirectory = false){
    while(nsDirEnum.hasMoreElements()){
      let entry = nsDirEnum.getNext().QueryInterface(Ci.nsIFile);
      if(name === entry.leafName){
        if(matchDirectory){
          if(entry.isDirectory()){
            return entry.directoryEntries.QueryInterface(Ci.nsISimpleEnumerator);
          }
        }else{
          if(entry.isFile()){
            return entry
          }
        }
      }
    }
    return null
  },

  getDirEntry: function(filename,isLoader = false){
    filename = filename.replace("\\","/");
    let pathParts = ((isLoader ? _uc.SCRIPT_DIR : _uc.RESOURCE_DIR) + "/" + filename).split("/").filter((a)=>(!!a));
    let leafName = pathParts.pop();
    let isFile = leafName.indexOf(".") != -1;
    let currentDir = _uc.chromeDirEntries;
    for(let part of pathParts){
      currentDir = _uc.getDirectoryEntries(currentDir,part,true)
    }
    return currentDir ? _uc.getDirectoryEntries(currentDir,leafName,!isFile) : null
  },

  createFileURI: (fileName,isLoader = false) => (`${_uc.BASE_FILEURI}${isLoader?_uc.SCRIPT_DIR:_uc.RESOURCE_DIR}/${fileName.replace("\\","/")}`),

  getScripts: function () {
    this.scripts = {};
    if(!yPref.get(_uc.PREF_ENABLED) || !(/^[\w_]*$/.test(_uc.SCRIPT_DIR))){
      console.log("Scripts are disabled or the given script directory name is invalid");
      return
    }

    let files = _uc.getDirEntry('',true);
    while(files.hasMoreElements()){
      let file = files.getNext().QueryInterface(Ci.nsIFile);
      if (/\.uc\.js$/i.test(file.leafName)) {
        _uc.getScriptData(file);
      }
    }
  },

  getScriptData: function (aFile) {
    let header = (_uc.utils.readFile(aFile,true).match(/^\/\/ ==UserScript==\s*\n(?:.*\n)*?\/\/ ==\/UserScript==\s*\n/m) || [''])[0];
    let match, rex = {
      include: [],
      exclude: []
    };
    let findNextRe = /^\/\/ @(include|exclude)\s+(.+)\s*$/gm;
    while ((match = findNextRe.exec(header))) {
      rex[match[1]].push(match[2].replace(/^main$/i, _uc.BROWSERCHROME).replace(/\*/g, '.*?'));
    }
    if (!rex.include.length) {
      rex.include.push(_uc.BROWSERCHROME);
    }
    let exclude = rex.exclude.length ? `(?!${rex.exclude.join('$|')}$)` : '';
    let def = ['', ''];
    let author = (header.match(/\/\/ @author\s+(.+)\s*$/im) || def)[1];
    let filename = aFile.leafName || '';

    return this.scripts[filename] = {
      filename: filename,
      name: (header.match(/\/\/ @name\s+(.+)\s*$/im) || def)[1],
      charset: (header.match(/\/\/ @charset\s+(.+)\s*$/im) || def)[1],
      description: (header.match(/\/\/ @description\s+(.+)\s*$/im) || def)[1],
      version: (header.match(/\/\/ @version\s+(.+)\s*$/im) || def)[1],
      author: (header.match(/\/\/ @author\s+(.+)\s*$/im) || def)[1],
      regex: new RegExp(`^${exclude}(${rex.include.join('|') || '.*'})$`,'i'),
      id: (header.match(/\/\/ @id\s+(.+)\s*$/im) || ['', filename.split('.uc.js')[0] + '@' + (author || 'userChromeJS')])[1],
      homepageURL: (header.match(/\/\/ @homepageURL\s+(.+)\s*$/im) || def)[1],
      downloadURL: (header.match(/\/\/ @downloadURL\s+(.+)\s*$/im) || def)[1],
      updateURL: (header.match(/\/\/ @updateURL\s+(.+)\s*$/im) || def)[1],
      optionsURL: (header.match(/\/\/ @optionsURL\s+(.+)\s*$/im) || def)[1],
      //startup: (header.match(/\/\/ @startup\s+(.+)\s*$/im) || def)[1],
      //shutdown: (header.match(/\/\/ @shutdown\s+(.+)\s*$/im) || def)[1],
      onlyonce: /\/\/ @onlyonce\b/.test(header),
      isRunning: false,
      get isEnabled() {
        return (yPref.get(_uc.PREF_SCRIPTSDISABLED) || '').split(',').indexOf(this.filename) === -1;
      }
    }
  },

  everLoaded: [],
  
  loadScript: function (script, win) {
    if (!script.regex.test(win.location.href) || !script.isEnabled) {
      return
    }
    if (script.onlyonce && script.isRunning) {
      if (script.startup) {
      //  eval(script.startup);
      }
      return
    }

    try {
      Services.scriptloader.loadSubScript(_uc.createFileURI(script.filename,true), win);
      
      script.isRunning = true;
      if (script.startup) {
      //  eval(script.startup);
      }
      if (!script.shutdown) {
        this.everLoaded.push(script.id);
      }
    } catch (ex) {
      this.error(script.filename, ex);
    }
    return
  },

  error: function (aMsg, err) {
    let error = Cc['@mozilla.org/scripterror;1'].createInstance(Ci.nsIScriptError);
    if (typeof err == 'object') {
      error.init(aMsg + '\n' + err.name + ' : ' + err.message, err.fileName || null, null, err.lineNumber, null, 2, err.name);
    } else {
      error.init(aMsg + '\n' + err + '\n', null, null, null, null, 2, null);
    }
    Services.console.logMessage(error);
  },
  // things to be exported for use by userscripts
  utils:{
    
    createElement: function(doc,tag,props){
      let el = doc.createXULElement(tag);
      for(let prop in props){
        el.setAttribute(prop,props[prop])
      }
      return el
    },
    
    readFile: function (aFile, metaOnly = false) {
      let stream = Cc['@mozilla.org/network/file-input-stream;1'].createInstance(Ci.nsIFileInputStream);
      let cvstream = Cc['@mozilla.org/intl/converter-input-stream;1'].createInstance(Ci.nsIConverterInputStream);
      try{
        stream.init(aFile, 0x01, 0, 0);
        cvstream.init(stream, 'UTF-8', 1024, Ci.nsIConverterInputStream.DEFAULT_REPLACEMENT_CHARACTER);
      }catch(e){
        console.error(e);
        return null
      }
      let content = '',
      data = {};
      while (cvstream.readString(4096, data)) {
        content += data.value;
        if (metaOnly && content.indexOf('// ==/UserScript==') > 0) {
          break;
        }
      }
      cvstream.close();
      stream.close();
      return content.replace(/\r\n?/g, '\n');
    },
    
    createFileURI: (fileName) => ( _uc.createFileURI(fileName) ),
    
    getFSEntry: (fileName) => ( _uc.getDirEntry(fileName) ),
    
    getScriptData: () => {
      let scripts = [];
      for(let script in _uc.scripts){
        let data = {};
        let o = _uc.scripts[script];
        for(let p in o){
          if(p != "isEnabled"){
            data[p] = o[p];
          }
        }
        scripts.push(data)
      }
      return scripts
    },
    
    getWindows: function (onlyBrowsers = true) {
      let windows = Services.wm.getEnumerator(onlyBrowsers ? 'navigator:browser' : null);
      let wins = [];
      while (windows.hasMoreElements()) {
        let win = windows.getNext();
        win._ucUtils && wins.push(win);
      }
      return wins
    },
    toggleScript: function(el){
      let isElement = !!el.tagName;
      if(!isElement && typeof el != "string"){
        return
      }
      let script = _uc.scripts[isElement ? el.getAttribute("filename") : el];
      if(!script){
        console.log("no script to toggle");
        return
      }
      if (script.isEnabled) {
        yPref.set(_uc.PREF_SCRIPTSDISABLED, `${script.filename},${yPref.get(_uc.PREF_SCRIPTSDISABLED)}`);
      } else {
        yPref.set(_uc.PREF_SCRIPTSDISABLED, yPref.get(_uc.PREF_SCRIPTSDISABLED).replace(new RegExp(`^${script.filename},?|,${script.filename}`), ''));
      }
      Services.appinfo.invalidateCachesOnRestart();
    },
    updateMenuStatus: function(menu){
      if(!menu){
        return
      }
      let disabledScripts = yPref.get(_uc.PREF_SCRIPTSDISABLED).split(",");
      for(let item of menu.children){
        if (disabledScripts.includes(item.getAttribute("filename"))){
          item.removeAttribute("checked");
        }else{
          item.setAttribute("checked","true");
        }
      }
    },
    get prefs(){ return yPref },

    restart: function (clearCache){
      clearCache && Services.appinfo.invalidateCachesOnRestart();
      _uc.utils.getWindows()[0].BrowserUtils.restartApplication();
    }
  }
};

_uc.BASE_FILEURI = Services.io.getProtocolHandler('file').QueryInterface(Ci.nsIFileProtocolHandler).getURLSpecFromDir(_uc.chromeDir);
Object.freeze(_uc.utils);

if (yPref.get(_uc.PREF_ENABLED) === undefined) {
  yPref.set(_uc.PREF_ENABLED, true);
}

if (yPref.get(_uc.PREF_SCRIPTSDISABLED) === undefined) {
  yPref.set(_uc.PREF_SCRIPTSDISABLED, '');
}

function UserChrome_js() {
  _uc.getScripts();
  Services.obs.addObserver(this, 'domwindowopened', false);
}

UserChrome_js.prototype = {
  observe: function (aSubject, aTopic, aData) {
      aSubject.addEventListener('DOMContentLoaded', this, true);
  },

  handleEvent: function (aEvent) {
    let document = aEvent.originalTarget;
    let window = document.defaultView;
    if (/^chrome:(?!\/\/global\/content\/(commonDialog|alerts\/alert)\.xul)|about:(?!blank)/i.test(window.location.href)) {
      window._ucUtils = _uc.utils;
      document.allowUnsafeHTML = false; // https://bugzilla.mozilla.org/show_bug.cgi?id=1432966
      if (window._gBrowser){ // bug 1443849
        window.gBrowser = window._gBrowser;
      }
      let isWindow = window.isChromeWindow;
      const ENABLED = yPref.get(_uc.PREF_ENABLED); 
        /* Add a way to toggle scripts in tools menu */
      let menu, popup, item;
      let ce = _uc.utils.createElement;
      if(isWindow){
        menu = document.querySelector("#menu_openDownloads");
        if(menu){
          try{
            popup = ce(document,"menupopup",{id:"menuUserScriptsPopup",onpopupshown:`_ucUtils.updateMenuStatus(this)`});
            item =  ce(document,"menu",{id:"userScriptsMenu",label:"userScripts"});
          }catch(e){
            isWindow = false;
          }
        }else{
          isWindow = false;
        }
      }
      if(ENABLED){
        Object.values(_uc.scripts).forEach(script => {
          _uc.loadScript(script, window);
          if(isWindow){
            popup.appendChild(ce(document,"menuitem",{type:"checkbox",label:script.name||script.filename,filename:script.filename,checked:"true",oncommand:`_ucUtils.toggleScript(this)`}))
          }
        });
      }
      if(isWindow){
        popup.appendChild(ce(document,"menuseparator",{}));
        popup.appendChild(ce(document,"menuitem",{label:"Restart now!",oncommand:"_ucUtils.restart(true)",tooltiptext:"Toggling scripts requires a restart"}));
        item.appendChild(popup);
        menu.parentNode.insertBefore(item,menu);
      }
    }
  }
};

!Services.appinfo.inSafeMode && new UserChrome_js();

try{
  yPref.set("toolkit.legacyUserProfileCustomizations.stylesheets",true);
}catch(e){}