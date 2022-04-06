# Project Structure
<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Project Structure](#project-structure)
    - [Icon files](#icon-files)
    - [Meta Info files](#meta-info-files)

<!-- markdown-toc end -->

The overall structure of this project.

```
root
|- __tests__/: Mixin spec test
|- icons/: Icons, illustrations
|- src/: Source files
|- src/userChrome.scss: Entry of SCSS for Browser UI
|- src/userContent.scss: Entry of SCSS for Web pages
|- .gitattributes: Exclude at `Download Zip`
|- .github: Issue/PR Template, Github Actions
|- .prettierignore: Exclude coding style
|- .prettierrc.json: Coding style
|- install.ps1: Install script write in powersehll
|- install.sh: Install script write in bash
|- package.json: Build setup, package dependency
|- LEPTON: Meta infos (branch, version)
|- user.js: about:config settings
|- userChrome.css: Build result of src/userChrome.scss (Don't modify directly!!)
|- userContent.css: Build result of src/userContent.scss (Don't modify directly!!)
|- yarn.lock: Auto generated dependency (Don't modify directly!!)
```

## Icon files

Most of them are made in SVG.

Except for illustrations, there must be an `fill="context-fill" fill-opacity="context-fill-opacity"` property to dynamically determine color and transparency.

Icons are mainly [FirefoxUX/photon-icons](https://github.com/FirefoxUX/photon-icons)
or [microsoft/fluentui-system-icons](https://github.com/microsoft/fluentui-system-icons).

You can see more in the issue, [Unify icon design langauge #213](https://github.com/black7375/Firefox-UI-Fix/issues/213).

## Meta Info files

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
