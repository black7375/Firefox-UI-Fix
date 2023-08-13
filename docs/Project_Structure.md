# Project Structure

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Basics](#basics)
- [Icon files](#icon-files)
- [Install Scripts](#install-scripts)
  * [Meta Info files](#meta-info-files)
  * [Overriding](#overriding)

<!-- markdown-toc end -->

## Basics
The overall structure of this project.

```
root
|- __tests__/: Mixin spec test
|- icons/: Icons, illustrations
|- css/: Build result of SCSS Files (Don't modify directly!!)
|- docs/: Development Documents
|- src/: Source files
|- src/leptonChrome.scss: Entry of SCSS for Browser UI
|- src/leptonContent.scss: Entry of SCSS for Web pages
|- .gitattributes: Exclude at `Download ZIP`
|- .github: Issue/PR Template, Github Actions
|- .prettierignore: Exclude coding style
|- .prettierrc.json: Coding style
|- install.ps1: Install script written in powershell
|- install.sh: Install script written in bash
|- package.json: Build setup, package dependency
|- LEPTON: Meta infos (branch, version)
|- user.js: about:config settings
|- userChrome.css: Entry of css for Browser UI (Modify only when customizing!!)
|- userContent.css: Entry of css for Web pages (Modify only when customizing!!)
|- yarn.lock: Auto generated dependency (Don't modify directly!!)
```

If you first come, it's a good idea to see the [`/src/leptonChrome.scss`](/src/leptonChrome.scss) and [`leptonContent.scss`](/src/leptonContent.scss) files to understand the flow.

## Icon files

Most of them are made in SVG.

Except for illustrations, there must be an `fill="context-fill" fill-opacity="context-fill-opacity"` property to dynamically determine color and transparency.

Icons are mainly [FirefoxUX/acorn-icons](https://github.com/FirefoxUX/acorn-icons), [FirefoxUX/photon-icons](https://github.com/FirefoxUX/photon-icons)
or [microsoft/fluentui-system-icons](https://github.com/microsoft/fluentui-system-icons).  
Although not yet used, [tabler/tabler-icons](https://github.com/tabler/tabler-icons) and [feathericons/feather](https://github.com/feathericons/feather) can also be referred to.

You can see more in the issue, [Unify icon design language #213](https://github.com/black7375/Firefox-UI-Fix/issues/213).

## Install Scripts
### Meta Info files

It comes from [install.sh](https://github.com/black7375/Firefox-UI-Fix/blob/01ae88bf2c4710e1f364d9eb2901ca2b722cefe7/install.sh#L442).

**`LEPTON` file format**

If this file exist in same directory as the `userChrome.css` file,
it is recognized as the "Lepton" installation directory.

```ini
[Info]
Branch=master | photon-style | proton-style
Ver=<git tag> | <git hash> | [NULL]
```

**`lepton.ini` file Format**

In `lepton.ini`, various information is stored during the installation process.\
This file is recreated every time the installer is created.

```ini
[Profile Name]
Type=Local | Release | Git
Branch=master | photon-style | proton-style
Ver=<git tag> | <git hash> | [NULL]
Path=<Full PATH>
```

**Update Policy according to `Type`**
- Local(unknown): force latest commit update
- Release(<git tag>): force latest tag update
- Git<git hash>: latest commit update

## Overriding

Inspired by [arkenfox](https://github.com/arkenfox/user.js/wiki/3.1-Overrides).  
These files need to use a shell script and has some priorities.

CSS override settings (`userChrome-overrides.css`, `userContent-overrides.css`) are relatively simple.
- `./<CSS_OVERRIDES>` (Will be copied `<FIREFOX_PROFILE>/chrome/`)
- `<FIREFOX_PROFILE>/chrome/<CSS_OVERRIDES>`

`user-overrides.js` needs to use a shell script and has some priorities.
- `<FIREFOX_PROFILE>/user-overrides.js`
- `./user-overrides.js` (Will be copied `<FIREFOX_PROFILE>/chrome/`)
- `<FIREFOX_PROFILE>/chrome/user-overrides.js`
