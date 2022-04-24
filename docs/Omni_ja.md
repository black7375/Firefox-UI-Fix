# Omni.ja

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Basics](#basics)
- [Related Project](#related-project)
- [Related Source file](#related-source-file)

<!-- markdown-toc end -->


## Basics
**Related Docs**
- [UDN: omni.ja (formerly omni.jar)](https://udn.realityripple.com/docs/Mozilla/About_omni.ja_(formerly_omni.jar))
- [Firefox 4: jar jar jar](https://web.archive.org/web/20161003115800/https://blog.mozilla.org/tglek/2010/09/14/firefox-4-jar-jar-jar/)
- [Firefox's Optimized Zip Format: Reading Zip Files Really Quickly](https://taras.glek.net/post/optimized-zip-format/)
- [How to Optimize or Deoptimize Firefox OMNI.JA File](https://www.raymond.cc/blog/edit-files-inside-firefox-4-omni-jar-to-auto-save-password/)

**Explanation**

Firefox achieve performance improvements by moving many of their internal parts from being standalone files or sets of JAR files into just one JAR file called `omni.ja`.  
This reduces the amount of I/O needed to load the application.

Chrome content, modules, non-binary components, and many other elements are packaged in an omni.jar file for each base directory.

- `actors/`: [JSActors](https://firefox-source-docs.mozilla.org/dom/ipc/jsactors.html) related files.
- `chrome.manifest`: The [chrome manifest](https://udn.realityripple.com/docs/Mozilla/Chrome_Registration) file.
- `chrome/`: User interface files for the application
- `components/`: XPCOM components the application relies upon.
- `defaults/`: Default preference files.
- `modules/`: [JavaScript code modules](https://udn.realityripple.com/docs/Mozilla/JavaScript_code_modules).
- `res/`: Miscellaneous resource files.

## Related Project
- https://github.com/SebastianSimon/firefox-omni-tweaks

## Related Source file
- https://github.com/mozilla/gecko-dev/blob/de91f5ee41251779ff2973d24d195d116cb6ebd7/python/mozbuild/mozpack/packager/formats.py#L258-L359
- https://github.com/humphd/mozilla-central-old/blob/9d4d9f265e24e6358c067ae1e300c1ce3227a91d/config/optimizejars.py
