# Restrictions
<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Compatibility](#compatibility)
  * [Cross Platform](#cross-platform)
  * [Firefox Version](#firefox-version)
  * [Side Effect](#side-effect)
- [Internals](#internals)
  * [CSS Loading Order](#css-loading-order)
  * [DOM structure cannot be modified](#dom-structure-cannot-be-modified)
  * [Shadow DOM](#shadow-dom)
  * [XUL](#xul)

<!-- markdown-toc end -->

## Compatibility
### Cross Platform
Different compatibility issues occur in Win7, Win8, Win10, KDE, Gnome, Mac, etc.

For example, The appearance of the context menu varies from platform to platform.

![context menu](https://user-images.githubusercontent.com/25581533/124066951-0eb21c00-da29-11eb-9ac4-c6b82a268c6f.png)

Consider compatibility as much as possible, but use [dedicated media queries](https://github.com/mozilla/gecko-dev/blob/d6188c9ce02efeea309e7177fc14c9eb2f09db37/servo/components/style/gecko/media_features.rs#L906-L930) in special cases.

[Bookmark menu](https://github.com/black7375/Firefox-UI-Fix/issues/136) is also similar example([code](https://github.com/black7375/Firefox-UI-Fix/blob/36e9c94844fee2417662251cbd50c2b874d5b576/userChrome.css#L4745-L4840)).

### Firefox Version
There may be changes that change by version of Firefox.

It's [more frequent than your thought](https://github.com/black7375/Firefox-UI-Fix/issues?q=is%3Aissue+label%3Aupstream+), and we need to respond to compatibility between [Nightly](https://www.mozilla.org/en-US/firefox/nightly/notes/) and [ESR](https://www.mozilla.org/en-US/firefox/organizations/notes/) versions.

This project is using SCSS to make a reusable compatible mixins.
```scss
@include OS($linux) {
  // Your CSS`
}

@include Dark {
  // Your CSS`
}
```

### Side Effect
Only CSS modifications can cause bugs that are hard to think of in the general web, such as the [context menu not appearing](https://github.com/black7375/Firefox-UI-Fix/issues/114).

## Internals
### CSS Loading Order
User CSS(`userChrome.css`, `userContent.css`) is usually loaded first.

In many cases, overriding should be prevented with [`important!`](https://developer.mozilla.org/en-US/docs/Web/CSS/Specificity#the_!important_exception)(Anti-pattern in general web), and side effects should also be considered.

### DOM structure cannot be modified
It is possible with [JS(Autoconfig)](./Prefence.md#auto-config), but there are security and configuration issues, so we should make the most of CSS.

[`::before`](https://developer.mozilla.org/en-US/docs/Web/CSS/::before) and [`::after`](https://developer.mozilla.org/en-US/docs/Web/CSS/::after) can indirectly add CSS elements.

### Shadow DOM
Firefox actively uses [shadow dom](https://developer.mozilla.org/en-US/docs/Web/Web_Components/Using_shadow_DOM) internally.

To modify, it is often a roundabout approach or impossible to inherit

### XUL
Sometimes firefox can use [XUL](https://en.wikipedia.org/wiki/XUL) that have been written and binded with C++ for performance like a treeview of bookmarks.

There ar few appropriate documents, so we have to read the source code and work. (Ex. [1](https://github.com/mozilla/gecko-dev/blob/master/layout/style/nsCSSAnonBoxList.h), [2](https://github.com/mozilla/gecko-dev/blob/master/layout/xul/tree/nsITreeView.idl))

Available CSS features are also restricted.

Example of legacy documents that will help.
- [UDN: ::-moz-tree-cell](https://udn.realityripple.com/docs/Mozilla/Gecko/Chrome/CSS/::-moz-tree-cell)
- [UDN: ::-moz-tree-cell-text](https://udn.realityripple.com/docs/Mozilla/Gecko/Chrome/CSS/::-moz-tree-cell-text)
