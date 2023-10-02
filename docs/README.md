# Developer Documents for Firefox Custom

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Basics](#basics)
- [Project-Specific](#project-specific)
  * [Environment](#environment)
  * [Project Structure](#project-structure)
  * [Rules](#rules)
- [Advanced Customizing](#advanced-customizing)
  * [Smart Bookmarks](#smart-bookmarks)
  * [Policies](#policies)
  * [Preference](#preference)
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

Firefox Documents:
- [Mozilla Support: Firefox advanced customization and configuration options](https://support.mozilla.org/en-US/kb/firefox-advanced-customization-and-configuration)
- [Mozilla Support: Profiles - Where Firefox stores your bookmarks, passwords and other user data](https://support.mozilla.org/en-US/kb/profiles-where-firefox-stores-user-data)

Test for non-Mac users:
- [Docker-OSX](https://github.com/sickcodes/Docker-OSX)

If you have difficulty contributing, please feel free to [click this link](https://github.com/black7375/Firefox-UI-Fix/discussions/new?category=help-contribute-to-this-project) to explain.  
I will help you as much as I know.

## Project-Specific
### Environment
[`git`](https://git-scm.com/) and [`yarn`](https://yarnpkg.com/) must be installed.

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
# __tests__ directory, You can also find out how to use internal utils.
yarn test

## validate - Will be failed, this project uses non-standard features.
# Just use only for checking.
yarn validate
```

### Project Structure
- [Doc: Project\_Structure.md](./Project_Structure.md)

### Rules
This is a rough guideline. (Not forced)

- [Doc: Rules.md](./Rules.md)

## Advanced Customizing
### Smart Bookmarks
- [Doc: Smart_Bookmarks.md](./Smart_Bookmarks.md)

### Policies
- [Support Mozilla: Policies overview](https://support.mozilla.org/en-US/products/firefox-enterprise/policies-customization-enterprise/policies-overview-enterprise)
- [Policy Templates](https://github.com/mozilla/policy-templates)

### Preference
- [Doc: Preference.md](./Preference.md)

## User Custom CSS
### Basics
`userChrome.css` file is for browser UI, `userContent.css` file is for web contents.

Unlike [User config](./Preference.md#user-config), they are located in `<FIREFOX_PROFILE>/chrome/`.

Start Guide:
- [What is userChrome.css? What can it do?](https://www.userchrome.org/what-is-userchrome-css.html)
- [How to Create a userChrome.css File](https://www.userchrome.org/how-create-userchrome-css.html)
- [Where to Find Style Recipes](https://www.userchrome.org/find-user-style-recipes.html)

CSS, SASS Documents:
- [MDN: CSS](https://developer.mozilla.org/en-US/docs/Web/CSS)
- [MDN: Introducing the CSS Cascade](https://developer.mozilla.org/en-US/docs/Web/CSS/Cascade)
- [MDN: Introducing the CSS Specific](https://developer.mozilla.org/en-US/docs/Web/CSS/Specificity)
- [SASS(SCSS)](https://sass-lang.com/documentation)
- [SASS Live Compile](https://www.sassmeister.com/)

Live Debugging:
- [Tutorial: How to create and live-debug userChrome.css](https://www.reddit.com/r/FirefoxCSS/comments/73dvty/tutorial_how_to_create_and_livedebug_userchromecss/)
- [Browser Toolbox](https://developer.mozilla.org/en-US/docs/Tools/Browser_Toolbox)
- [Style Editor](https://developer.mozilla.org/en-US/docs/Tools/Style_Editor)

Advanced CSS keywords:
- [UDN: Chrome-only CSS reference](https://udn.realityripple.com/docs/Mozilla/Gecko/Chrome/CSS)
- [UDN: Mozilla CSS extensions](https://udn.realityripple.com/docs/Web/CSS/Mozilla_Extensions)

### Restrictions
- [Doc: Restrictions.md](./Restrictions.md)
