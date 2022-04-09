# Develper Documents

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Basics](#basics)
- [Project-Specific](#project-specific)
  * [Environment](#environment)
  * [Project Structure](#project-structure)
  * [Rules](#rules)
- [User Custom CSS](#user-custom-css)
  * [Basics](#basics-1)
  * [Restrictions](#restrictions)

<!-- markdown-toc end -->

## Basics
The following documents may be helpful:
- [Roadmap](https://github.com/black7375/Firefox-UI-Fix/issues/2)
- [Each Versions Plan](https://github.com/black7375/Firefox-UI-Fix/milestones)
- [Wiki:Compatibility Issues Solution](https://github.com/black7375/Firefox-UI-Fix/wiki/Compatibility-Issues-Solution)
- [Wiki:Tips](https://github.com/black7375/Firefox-UI-Fix/wiki/Tips)

Firefox Source Code:
- [Github](https://github.com/mozilla/gecko-dev)
- [Searchfox](https://searchfox.org/)
- [Firefox Source Docs](https://firefox-source-docs.mozilla.org/)

Test for None mac users:
- [Docker-OSX](https://github.com/sickcodes/Docker-OSX)

## Project-Specific
### Environment
[`git`](https://git-scm.com/) and [`yarn`](https://yarnpkg.com/) should be installed.

You can configure it as follows:
```shell
## clone repository
git clone https://github.com/black7375/Firefox-UI-Fix.git
cd ./Firefox-UI-Fix

## checkout branch
git checkout <BRANCH_NAME>

## env setup
yarn install
```

You can build with this command:
```shell
yarn build
```

You can check test and css validate:
```shell
## test - When you make mixin or function
# __tests__ direcory, You can also find out how to use internal utils.
yarn test

## validate - Will be failed, this project uses non-standard features.
# Just use only for checking.
yarn validate
```

### Project Structure
- [Project\_Structure.md](./Project_Structure.md).

### Rules
This is a rough guideline. (Not forced)

- [Rules.md](./Rules.md).

## User Custom CSS
### Basics
CSS, SASS Documents:
- [CSS](https://developer.mozilla.org/en-US/docs/Web/CSS)
- [SASS(SCSS)](https://sass-lang.com/documentation)
- [SASS Live Compile](https://www.sassmeister.com/)

Live Debugging:
- [Tutorial: How to create and live-debug userChrome.css](https://www.reddit.com/r/FirefoxCSS/comments/73dvty/tutorial_how_to_create_and_livedebug_userchromecss/)
- [Browser Toolbox](https://developer.mozilla.org/en-US/docs/Tools/Browser_Toolbox)
- [Style Editor](https://developer.mozilla.org/en-US/docs/Tools/Style_Editor)

### Restrictions
- [Restrictions.md](./Restrictions.md).
