"use strict";

// Reference
// https://github.com/mozilla/gecko-dev/blob/master/modules/libpref/nsIPrefBranch.idl
// https://github.com/mozilla/gecko-dev/blob/master/toolkit/modules/Preferences.sys.mjs
// https://github.com/mozilla/gecko-dev/blob/master/extensions/pref/autoconfig/src/prefcalls.js
// https://github.com/mozilla/gecko-dev/blob/master/devtools/shared/specs/preference.js
// https://github.com/mozilla/gecko-dev/blob/master/devtools/client/shared/test-helpers/jest-fixtures/Services.js
// https://github.com/mozilla/gecko-dev/blob/master/devtools/server/actors/preference.js
// https://github.com/MrOtherGuy/fx-autoconfig/blob/master/profile/chrome/utils/boot.jsm
// https://github.com/xiaoxiaoflood/firefox-scripts/blob/master/chrome/utils/xPref.jsm
// const Services = globalThis.Services ||
//       ChromeUtils.import("resource://gre/modules/Services.jsm").Services;

// TODO: Maybe to use Preferences.sys.mjs & ExtensionPreferencesManager.sys.mjs ??
const Services = globalThis.Services ||
      ChromeUtils.import("resource://gre/modules/Services.jsm").Services;

function getPrefs(isDefault = false) {
  const sPrefs = Services.prefs;
  return isDefault ? sPrefs.getDefaultBranch(null) : sPrefs.getBranch(null);
}

this.prefs = class extends ExtensionAPI {
  getAPI(context) {
    return {
      prefs: {
        get(prefName, isDefault = false) {
          try {
            const sPrefs = getPrefs(isDefault);

            switch (sPrefs.getPrefType(prefName)) {
            case sPrefs.PREF_INVALID: // 0
              return null;

            case sPrefs.PREF_STRING:  // 32
              return sPrefs.getStringPref(prefName);

            case sPrefs.PREF_INT:     // 64
              return sPrefs.getIntPref(prefName);

            case sPrefs.PREF_BOOL:    // 128
              return sPrefs.getBoolPref(prefName);

            default:
              return undefined;
            }
          }
          catch (err) { console.log(err) }
        },

        set(prefName, value, isDefault = false) {
          try {
            const sPrefs = getPrefs(isDefault);

            switch (typeof value) {
            case "string":
              return sPrefs.setStringPref(prefName, value) || value;

            case "number":
              return sPrefs.setIntPref(prefName, value) || value;

            case "boolean":
              return sPrefs.setBoolPref(prefName, value) || value;

            default:
              return undefined;
            }
          }
          catch (err) { }
        },

        lock(prefName, value) {
          try {
            const sPrefs = getPrefs();

            if (sPrefs.prefIsLocked(prefName)) {
              sPrefs.unlockPref(prefName);
            }

            this.set(prefName, value, true);
            sPrefs.lockPref(prefName);
          }
          catch (err) { }
        },

        unlock(prefName) {
          try {
            const sPrefs = getPrefs();
            sPrefs.unlockPref(prefName);
          }
          catch (err) { }
        },

        clear(prefName) {
          try {
            const sPrefs = getPrefs();
            sPrefs.clearUserPref(prefName);
          }
          catch (err) { }
        },

        addListener(prefName, callback) {
          const sPrefs = getPrefs();
          const observer = (domain, observer, prefName) => {
            return callback(prefName, this.get(prefName));
          }

          sPrefs.addObserver(prefName, observer);
          return observer;
        },

        removeListener(prefName, observer) {
          const sPrefs = getPrefs();
          sPrefs.removeObserver(prefName, observer);
        }
      }
    }
  }
}
