# Preference

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Basics](#basics)
- [User Config](#user-config)
- [Using with User Custom CSS](#using-with-user-custom-css)
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
  - When you need an float, use a string. (Ex. `general.smoothScroll.currentVelocityWeighting`: `"0.25"`)

**Main Purpose**
- Feature enable/disable flags (Ex. `xpinstall.signatures.required`).
- User preferences (Ex. things set from `about:preferences`)
- Internal application parameters (Ex. `javascript.options.mem.nursery.max_kb`).
- Application data (Ex. `browser.onboarding.tour.onboarding-tour-addons.completed`, `services.sync.clients.lastSync`).
- Things that might need locking in an enterprise installation.

## User Config
**Related Docs**
- [mozillaZine: Editing configuration](https://kb.mozillazine.org/Editing_configuration)
- [Support Mozilla: How to fix preferences that won't save](https://support.mozilla.org/en-US/kb/how-to-fix-preferences-wont-save)
- [Support Mozilla: Reset Firefox preferences to troubleshoot and fix problems](https://support.mozilla.org/en-US/kb/reset-preferences-fix-problems)
- [UDN: A brief guide to Mozilla preferences](https://udn.realityripple.com/docs/Mozilla/Preferences/A_brief_guide_to_Mozilla_preferences)

**Restrictions**

It can be defined using only `user_pref()`.

> User pref file syntax is slightly more restrictive than default pref file syntax. In user pref files `user_pref` definitions are allowed but `pref` and `sticky_pref` definitions are not, and attributes (such as `locked`) are not allowed.

**`about:config`**

It is written to `prefs.js` in a way that can be set by the GUI.

- [Support Mozilla: Configuration Editor for Firefox](https://support.mozilla.org/en-US/kb/about-config-editor-firefox)

**`prefs.js`**

It exists in the profile directory, and is used to store settings that are changed from *defaults* or when users added *new settings*.

In general, Do NOT edit `prefs.js` directly.

- [mozillaZine: Prefs.js file](https://kb.mozillazine.org/Prefs.js_file)

**`user.js`**
- [mozillaZine: User.js file](https://kb.mozillazine.org/User.js_file)

**Example**

```javascript
// user.js
user_pref("browser.cache.disk.enable", false);                      // Bool
user_pref("layout.css.prefers-color-scheme.content-override", 3);   // Int
user_pref("general.smoothScroll.currentVelocityWeighting", "0.12"); // String
```

## Using with User Custom CSS
**Related Docs**
- [MDN: @supports](https://developer.mozilla.org/en-US/docs/Web/CSS/@supports)
- [UDN: `CSS -moz-bool-pref() @supports function`](https://udn.realityripple.com/docs/Mozilla/Gecko/Chrome/CSS/-moz-bool-pref)

**Restrictions**

`@supports` change in CSS is not detected in real time. (Only start time)

So a restart is required, and if the mozilla need real time changes, are using `@media` to handle it.

If project only use pure CSS, we cannot add `@media rules`.

- [Bug 1267890 - Support detecting bool preferences in chrome stylesheets](https://bugzilla.mozilla.org/show_bug.cgi?id=1267890)
- [Bug 1698132 - Improve caching behaviour of -moz-bool-pref](https://bugzilla.mozilla.org/show_bug.cgi?id=1698132)

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

## Related Source file

- https://github.com/mozilla/gecko-dev/blob/master/modules/libpref/parser/src/lib.rs
- https://github.com/mozilla/gecko-dev/blob/master/extensions/pref/autoconfig/src/prefcalls.js
