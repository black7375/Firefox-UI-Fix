# Contributing

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Introduce](#introduce)
  - [Code of Conduct](#code-of-conduct)
  - [We Develop with Github](#we-develop-with-github)
  - [Environment](#environment)
  - [Your First Contribution](#your-first-contribution)
  - [Contribution Targets](#contribution-targets)
  - [Project Structure](#project-structure)
    - [Icon files](#icon-files)
    - [Meta Info files](#meta-info-files)
  - [Restrictions](#restrictions)
- [Rules](#rules)
  - [Version](#version)
  - [Branch](#branch)
  - [Issue](#issue)
  - [Coding style](#coding-style)
  - [Commit](#commit)
  - [Commit Message](#commit-message)
  - [Pull request](#pull-request)
  - [License](#license)
- [References](#references)

<!-- markdown-toc end -->

## Introduce

I'm really glad you're reading this, because we need volunteer developers to help this project come to fruition.

Please note we have a code of conduct, please follow it in all your interactions with the project.

### Code of Conduct

Refer to [CODE\_OF\_CONDUCT.md](https://github.com/black7375/Firefox-UI-Fix/blob/master/CODE_OF_CONDUCT.md).

### We Develop with Github

We use [github](https://github.com/black7375/Firefox-UI-Fix) to host code, to track [issues](https://github.com/black7375/Firefox-UI-Fix/issues) and feature requests, as well as accept [pull requests](https://github.com/black7375/Firefox-UI-Fix/pulls).

After feedback has been given we expect responses within two weeks. After two weeks we may close the issue and pull request if it isn't showing any activity.

### Environment

You can configure it as follows:
```shell
## clone repository
git clone https://github.com/black7375/Firefox-UI-Fix.git
cd ./Firefox-UI-Fix

## checkout branch
git checkout <BRANCH_NAME>
```

### Your First Contribution

**Working on your first Pull Request?** You can learn how from this *free* series [How to Contribute to an Open Source Project on GitHub](https://egghead.io/series/how-to-contribute-to-an-open-source-project-on-github)

The following documents may be helpful:
- [Roadmap](https://github.com/black7375/Firefox-UI-Fix/issues/2)
- [Each Versions Plan](https://github.com/black7375/Firefox-UI-Fix/milestones)
- [Wiki:Compatibility Issues Solution](https://github.com/black7375/Firefox-UI-Fix/wiki/Compatibility-Issues-Solution)
- [Wiki:Tips](https://github.com/black7375/Firefox-UI-Fix/wiki/Tips)

Live Debugging:
- [Tutorial: How to create and live-debug userChrome.css](https://www.reddit.com/r/FirefoxCSS/comments/73dvty/tutorial_how_to_create_and_livedebug_userchromecss/)
- [Browser Toolbox](https://developer.mozilla.org/en-US/docs/Tools/Browser_Toolbox)
- [Style Editor](https://developer.mozilla.org/en-US/docs/Tools/Style_Editor)

Firefox Source Code:
- [Github](https://github.com/mozilla/gecko-dev)
- [Searchfox](https://searchfox.org/)
- [Firefox Source Docs](https://firefox-source-docs.mozilla.org/)

Test for None mac users:
- [Docker-OSX](https://github.com/sickcodes/Docker-OSX)

### Contribution Targets

We love your input! We want to make contributing to this project as easy and transparent as possible, whether it's:

**Promotions**
- Introduce project
  - Video (Recommend!!, We need it)
  - Blog
  - SNS
  - Reddit, Hackernews..etc
- Sample
  - [Producthunt](https://www.producthunt.com/posts/firefox-ui-fix-proton)([#43](https://github.com/black7375/Firefox-UI-Fix/issues/43))
  - [Youtube](https://www.youtube.com/watch?v=ECta0icNMgY)

**Docs**
- Fix typos, alignments.
- Correct awkward sentences.
- Improve document readability.

**Issues**
- Report a bug.
- Discussing the current state of the code.
- Tell us about related or relevant projects and documents.
- Help other users issue.
- Proposing others..

**Codes**
- New Features.
- Bug fixes.
- Improved compatibility or accessibility.
- Refactoring.

### Project Structure

```
root
|- .gitattributes: Exclude at `Download Zip`
|- .github: Issue/PR Template, Github Actions
|- .prettierignore: Exclude coding style
|- .prettierrc.json: Coding style
|- icons/: Icons, illustrations
|- install.ps1: Install script write in powersehll
|- install.sh: Install script write in bash
|- LEPTON: Meta infos (branch, version)
|- user.js: about:config settings
|- userChrome.css: CSS for Browser UI
|- userContent.css: CSS for Web pages
```

#### Icon files

Most of them are made in SVG.

Except for illustrations, there must be an `fill="context-fill" fill-opacity="context-fill-opacity"` property to dynamically determine color and transparency.

Icons are mainly [FirefoxUX/photon-icons](https://github.com/FirefoxUX/photon-icons)
or [microsoft/fluentui-system-icons](https://github.com/microsoft/fluentui-system-icons).

#### Meta Info files

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

### Restrictions

- Cross Platform
  - Different compatibility issues occur in Win7, Win8, Win10, KDE, Gnome, Mac, etc.
  - Consider compatibility as much as possible, but use [dedicated media queries](https://github.com/mozilla/gecko-dev/blob/d6188c9ce02efeea309e7177fc14c9eb2f09db37/servo/components/style/gecko/media_features.rs#L906-L930) in special cases
- CSS Loading Order
  - User CSS(`userChrome.css`, `userContent.css`) is usually loaded first.
  - In many cases, overriding should be prevented with [`important!`](https://developer.mozilla.org/en-US/docs/Web/CSS/Specificity#the_!important_exception)(Anti-pattern in general web), and side effects should also be considered.
- DOM structure cannot be modified
  - It is possible with JS, but there are security and configuration issues, so we should make the most of CSS.
  - [`::before`](https://developer.mozilla.org/en-US/docs/Web/CSS/::before) and [`::after`](https://developer.mozilla.org/en-US/docs/Web/CSS/::after) can indirectly add CSS elements.
- [Shadow DOM](https://developer.mozilla.org/en-US/docs/Web/Web_Components/Using_shadow_DOM)
  - Firefox actively uses shadow dom internally
  - To modify, it is often a roundabout approach or impossible to inherit
- [XUL](https://en.wikipedia.org/wiki/XUL)
  - Sometimes written and bound in C++ for performance, like a treeview of bookmarks.
  - The proper document does not exist, so we have to read the source code and work
  - Available CSS features are also restricted.
- Side Effects
  - Only CSS modifications can cause bugs that are hard to think of in the general web, such as the [context menu not appearing](https://github.com/black7375/Firefox-UI-Fix/issues/114).  

## Rules

### Version

Milestone, The versioning scheme we use is [SemVer](https://semver.org/). (Maintainer decides, do not pull request.)

We will release the feature as soon as it is complete, but the cycle should be 2-4 weeks.
Rapid releases.

It comes from [#109](https://github.com/black7375/Firefox-UI-Fix/issues/109#issuecomment-873313945).

### Branch

Stable: Only bugfix, Documentation.
- `master`: Common bugfix, documentation.
- `photon-style`: Bugfix, documentation specified in `photon-style`.
- `proton-sryle`: Bugfix, documentation specified in `proton-style`.

Development: New Features.
- `dev`: Common new features.
- `photon-style-dev`: New features specified in `photon-style`.
- `proton-style-dev`: New features specified in `proton-style`.

### Issue

- **Versions:**
- Make sure you’re on the latest version.
- Try older versions.
- Try switching up dependency versions.
- **Search:** Search the project’s [issues](https://github.com/black7375/Firefox-UI-Fix/issues) to make sure it's not a known issue.

### Coding style

- **Indent:** 2 spaces for indentation rather than tabs.
- **Columns:** Fit `80`~`100` columns as much as possible. (Auto formatting is using 120 to avoid the worst case)

### Commit

- **Meaningfully:**: It doesn't make meaningless commits.
- **One per task:** It's difficult to distinguish when various tasks are mixed.
- **Often:** Codes may corrupt during large changes.

### Commit Message

For intuitive recognition, I [put a **prefix**](https://github.com/black7375/Firefox-UI-Fix/commits/master).
- `Add:` Add feature or enhanced.
- `Fix:` Bug fix or change default values.
- `Clean:` Refactoring.
- `Doc:` Update docs.

### Pull request

- **Branch:** Check the [Branch](#branch) section and PR to the correct branch.
- **Issue:** We recommend that you open the issue first to discuss the changes with the owner of this repository.

### License

**Any contributions you make will be under the MPL 2.0 Software License**

In short, when you submit code changes, your submissions are understood to be under the same [MPL 2.0 License](https://choosealicense.com/licenses/mpl-2.0/) that covers the project.
Feel free to contact the maintainers if that's a concern.

**Reference specification**

Even if you copy the code snippet, it is recommended that you leave a link.

**FAQ**

If you have any questions about other licenses, please see [Moailla's MPL 2.0 FAQ](https://www.mozilla.org/en-US/MPL/2.0/FAQ/).


## References

- [Good-CONTRIBUTING.md-template](https://gist.github.com/PurpleBooth/b24679402957c63ec426)
- [Contributing to Transcriptase](https://gist.github.com/briandk/3d2e8b3ec8daf5a27a62)
- [contributing-template](https://github.com/nayafia/contributing-template/blob/master/CONTRIBUTING-template.md)
- [Contributing to Open Source Projects](https://www.contribution-guide.org/)
