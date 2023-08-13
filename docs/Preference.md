# Preference

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Basics](#basics)
- [Default Config](#default-config)
- [User Config](#user-config)
  * [about:config](#aboutconfig)
  * [prefs.js](#prefsjs)
  * [user.js](#userjs)
- [Auto Config](#auto-config)
- [Using with User Custom CSS](#using-with-user-custom-css)
- [Sync](#sync)
- [Related Source file](#related-source-file)

<!-- markdown-toc end -->

## Basics
**Related Docs**
- [Firefox Source Docs: libpref](https://firefox-source-docs.mozilla.org/modules/libpref/index.html)

**Key/Value**
- Key:
  - Pref name
  - Type: 8-bit string
  - Convention is to use a dotted segmented form (Ex. `browser.cache.disk.enable`)
- Value:
  - Type: bool, 32-bit ints, 8-bit C string
  - When you need a float, use a string (Ex. `general.smoothScroll.currentVelocityWeighting`: `"0.25"`)

**Main Purpose**
- Feature enable/disable flags (Ex. `xpinstall.signatures.required`).
- User preferences (Ex. things set from `about:preferences`)
- Internal application parameters (Ex. `javascript.options.mem.nursery.max_kb`).
- Application data (Ex. `browser.onboarding.tour.onboarding-tour-addons.completed`, `services.sync.clients.lastSync`).
- Things that might need locking in an enterprise installation.

**Preference file RFC**

Key information on the sets that can be used in the configuration file.

- `pref()`: Set default pref
  - `sticky` attr: same as `sticky_pref()`
  - `locked` attr: cannot change from default.
- `sticky_pref()`: Always logged even if the defaults match
- `user_pref()`: Set user pref

The following is a method of operating the configuration file parser.  
See [EBNF (Extended Backus-Naur form)](https://en.wikipedia.org/wiki/Extended_Backus%E2%80%93Naur_form) if you want to know about syntax.

```ebnf
<pref-file>   = <pref>*;
<pref>        = <pref-spec> "(" <pref-name> "," <pref-value> <pref-attrs> ")" ";";
<pref-spec>   = "user_pref" | "pref" | "sticky_pref"; (* in default pref files *)
<pref-spec>   = "user_pref";                          (* in user pref files    *)
<pref-name>   = <string-literal>;
<pref-value>  = <string-literal> | "true" | "false" | <int-value>;
<int-value>   = <sign>? <int-literal>;
<sign>        = "+" | "-";
<int-literal> = [0-9]+ (and cannot be followed by [A-Za-z_]);
<string-literal> = ?
  A single or double-quoted string, with the following escape sequences
  allowed: "\"", "\'" "\\", "\n", "\r", "\xNN", "\uNNNN", where "\xNN" gives a raw byte
  value that is copied directly into an 8-bit string value, and "\uNNNN"
  gives a UTF-16 code unit that is converted to UTF-8 before being copied
  into an 8-bit string value. "\x00" and "\u0000" are disallowed because they
  would cause C++ code handling such strings to misbehave.
?;
<pref-attrs>  = ("," <pref-attr>)*       (* in default pref files   *)
              = <empty>;                 (* in user pref files      *)
<pref-attr>   = "sticky" | "locked";     (* default pref files only *)
```

## Default Config
- [`modules/libpref/init/all.js`](https://github.com/mozilla/gecko-dev/blob/master/modules/libpref/init/all.js): all products
- [`browser/app/profile/firefox.js`](https://github.com/mozilla/gecko-dev/blob/master/browser/app/profile/firefox.js): only firefox desktop

In release builds these are all put into [`omni.ja`](./Omni_ja.md).

## User Config
**Related Docs**
- [mozillaZine: Editing configuration](https://kb.mozillazine.org/Editing_configuration)
- [Support Mozilla: How to fix preferences that won't save](https://support.mozilla.org/en-US/kb/how-to-fix-preferences-wont-save)
- [Support Mozilla: Reset Firefox preferences to troubleshoot and fix problems](https://support.mozilla.org/en-US/kb/reset-preferences-fix-problems)
- [UDN: A brief guide to Mozilla preferences](https://udn.realityripple.com/docs/Mozilla/Preferences/A_brief_guide_to_Mozilla_preferences)

**Restrictions**

It can be defined using only `user_pref()`.

> User pref file syntax is slightly more restrictive than default pref file syntax. In user pref files `user_pref` definitions are allowed but `pref` and `sticky_pref` definitions are not, and attributes (such as `locked`) are not allowed.

**File Path**

`prefs.js`, `user.js`  is located in the profile directory.

### about:config

It is written to `prefs.js` in a way that can be set by the GUI.

- [Support Mozilla: Configuration Editor for Firefox](https://support.mozilla.org/en-US/kb/about-config-editor-firefox)

### prefs.js
**Related Docs**
- [mozillaZine: Prefs.js file](https://kb.mozillazine.org/Prefs.js_file)

**Basics**
It exists in the profile directory, and is used to store settings that are changed from *defaults* or when users added *new settings*.

In general, do NOT edit `prefs.js` directly.

### user.js
**Related Docs**
- [mozillaZine: User.js file](https://kb.mozillazine.org/User.js_file)

**Restrictions**

A `user.js` file can make certain preference settings more or less "permanent" in a specific profile.

Once an entry for a preference setting exists in the `user.js` file, any change you make to that setting in the options and preference dialogs or via `about:config` will be lost when you restart your firefox because the `user.js` entry will override it.

You'll have to first delete or edit the `user.js` file to remove the entries before the preferences can be changed in the application.

**Example**

```javascript
// user.js
user_pref("browser.cache.disk.enable", false);                      // Bool
user_pref("layout.css.prefers-color-scheme.content-override", 3);   // Int
user_pref("general.smoothScroll.currentVelocityWeighting", "0.12"); // String
```

## Auto Config
**Related Docs**
- [Support Mozilla: Customizing Firefox Using AutoConfig](https://support.mozilla.org/en-US/kb/customizing-firefox-using-autoconfig)
- [What is Autoconfig Startup Scripting (AKA userChrome.js)?](https://www.userchrome.org/what-is-userchrome-js.html)
- [UDN: Gecko Chrome](https://udn.realityripple.com/docs/Mozilla/Gecko/Chrome)
- [UDN: JavaScript code modules](https://udn.realityripple.com/docs/Mozilla/JavaScript_code_modules)
- [UDN: Limitations of chrome scripts](https://udn.realityripple.com/docs/Mozilla/Firefox/Multiprocess_Leftovers/Limitations_of_chrome_scripts)

**Basics**
Customizations that cannot be done with add-on and [`User Custom CSS`](./README.md#user-custom-css), such as adding browser UI elements directly or changing default behavior, must use `Auto Config`.

`.mjs`(ES6 Module) is also used in FF `v102` or above.
- [Bug 1432901 - Prototype loading ES6 Module as JSM](https://bugzilla.mozilla.org/show_bug.cgi?id=1432901)

**How to**
- `<FIREFOX_DIR>/defaults/pref/autoconfig.js`
```javascript
pref("general.config.filename", "config.js"); // alternative to "firefox.cfg", for using highlight
pref("general.config.obscure_value", 0);
pref("general.config.sandbox_enabled", false); // Sandbox needs to be disabled in release and Beta versions
```

- `<FIREFOX_DIR>/config.js`
```javascript
// skip 1st line
try {
  const cmanifest = Cc['@mozilla.org/file/directory_service;1'].getService(Ci.nsIProperties).get('UChrm', Ci.nsIFile);
  cmanifest.append('utils');
  cmanifest.append('chrome.manifest');

  if(cmanifest.exists()){
    Components.manager.QueryInterface(Ci.nsIComponentRegistrar).autoRegister(cmanifest);
    ChromeUtils.import('chrome://userchromejs/content/boot.jsm');
  }

} catch(ex) {};
```

**Example**
- [MrOtherGuy/fx-autoconfig](https://github.com/MrOtherGuy/fx-autoconfig)
- [xiaoxiaoflood/firefox-scripts](https://github.com/xiaoxiaoflood/firefox-scripts)

## Using with User Custom CSS
**Related Docs**
- [MDN: @supports](https://developer.mozilla.org/en-US/docs/Web/CSS/@supports)
- [UDN: `CSS -moz-bool-pref() @supports function`](https://udn.realityripple.com/docs/Mozilla/Gecko/Chrome/CSS/-moz-bool-pref)

**Restrictions**

Please refer to [Doc: Restrictions.md](./Restrictions.md#supports)'s `@support`.

**Example**

Test each case by turning on/off the following settings.
- `userChrome.navBar.red`
- `userChrome.navBar.margin`

```css
/* userChrome.css */

/* 1. If config is true */
@supports -moz-bool-pref("userChrome.navBar.red") {
  #nav-bar {
    background-color: red !important;
  }
}

/* 2. When any one of the config is true */
@supports -moz-bool-pref("userChrome.navBar.red") or -moz-bool-pref("userChrome.navBar.margin") {
  #nav-bar {
    background-color: red !important;
    margin-block: 20px;
  }
}

/* 3. Multiple configs must all be satisfied */
@supports -moz-bool-pref("userChrome.navBar.red") and -moz-bool-pref("userChrome.navBar.margin") {
  #nav-bar {
    background-color: red !important;
    margin-block: 20px;
  }
}

/* 4. 3's Other version */
@supports -moz-bool-pref("userChrome.navBar.red") {
  @supports -moz-bool-pref("userChrome.navBar.margin") {
    #nav-bar {
      background-color: red !important;
      margin-block: 20px;
    }
  }
}

/* 5. If not exist or false */
@supports not -moz-bool-pref("userChrome.navBar.red") {
  #nav-bar {
    background-color: blue !important;
  }
}
```

## Sync

**Related Docs**
- [Support Mozilla: Sync custom preferences](https://support.mozilla.org/en-US/kb/sync-custom-preferences)

**How to**

Firefox Sync allows you to [choose the types of data](https://support.mozilla.org/en-US/kb/how-do-i-choose-what-information-sync-firefox) to sync across all devices.

![Choose sync data](https://user-images.githubusercontent.com/25581533/162106009-85f8efe6-c310-488b-9940-763b6e7dd271.png)

The following options are required to sync custom configs.
- `services.sync.prefs.dangerously_allow_arbitrary` to `true`

Then, subsequently any pref can be pushed there by creating a remote with prefix.
- `services.sync.prefs.sync.`

**Example**

```javascript
// user.js
user_pref("services.sync.prefs.dangerously_allow_arbitrary", true); // Must need

// Sync UI
user_pref("services.sync.prefs.sync.browser.uiCustomization.state", true);
user_pref("services.sync.prefs.sync.browser.uidensity", true);
```

## Related Source file

- https://github.com/mozilla/gecko-dev/blob/master/modules/libpref/parser/src/lib.rs
- https://github.com/mozilla/gecko-dev/blob/master/extensions/pref/autoconfig/src/prefcalls.js
