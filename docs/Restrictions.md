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

Even the implementation is also different like ([Context menu's image](https://github.com/black7375/Firefox-UI-Fix/blob/36e9c94844fee2417662251cbd50c2b874d5b576/userChrome.css#L4558-L4595)).  
If you need to implement it in a variety of forms, make a sort of API using [`css var()`](https://developer.mozilla.org/en-US/docs/Web/CSS/var).

[Bookmark menu](https://github.com/black7375/Firefox-UI-Fix/issues/136) is also similar example([code](https://github.com/black7375/Firefox-UI-Fix/blob/36e9c94844fee2417662251cbd50c2b874d5b576/userChrome.css#L4745-L4840)).

### Firefox Version
There may be changes that change by version of Firefox.

It's [more frequent than your thought](https://github.com/black7375/Firefox-UI-Fix/issues?q=is%3Aissue+label%3Aupstream+), and we need to respond to compatibility between [Nightly](https://www.mozilla.org/en-US/firefox/nightly/notes/) and [ESR](https://www.mozilla.org/en-US/firefox/organizations/notes/) versions.

This project is using SCSS to make a [reusable compatible mixins](../src/utils).
```scss
@include OS($linux) {
  // Your CSS
}

@include Dark {
  // Your CSS
}
```

### Side Effect
Only CSS modifications can cause bugs that are hard to think of in the general web, such as the [context menu not appearing](https://github.com/black7375/Firefox-UI-Fix/issues/114).

## Internals
### CSS Loading Order
User CSS(`userChrome.css`, `userContent.css`) is usually loaded first.

In many cases, overriding should be prevented with [`important!`](https://developer.mozilla.org/en-US/docs/Web/CSS/Specificity#the_!important_exception)(Anti-pattern in general web), and side effects should also be considered. [#11](https://github.com/black7375/Firefox-UI-Fix/issues/11)

### DOM structure cannot be modified
It is possible with [JS(Autoconfig)](./Preference.md#auto-config), but there are security and configuration issues, so we should make the most of CSS.

[`::before`](https://developer.mozilla.org/en-US/docs/Web/CSS/::before) and [`::after`](https://developer.mozilla.org/en-US/docs/Web/CSS/::after) can indirectly add CSS elements.

Many implementations using `::before`, `::after`.
- [Bottom Rounded Corner](https://github.com/black7375/Firefox-UI-Fix/blob/36e9c94844fee2417662251cbd50c2b874d5b576/userChrome.css#L3319-L3393)
- [Dynamic Tab Separator](https://github.com/black7375/Firefox-UI-Fix/blob/36e9c94844fee2417662251cbd50c2b874d5b576/userChrome.css#L3394-L3457)
- [Static Tab Separator](https://github.com/black7375/Firefox-UI-Fix/blob/0f78a73b856e1335954ecded93d377b85134bd61/userChrome.css#L3387-L3428)
- [Picture In Picture Indicator](https://github.com/black7375/Firefox-UI-Fix/blob/36e9c94844fee2417662251cbd50c2b874d5b576/userChrome.css#L3716-L3753)
- [Contaner Indicator](https://github.com/black7375/Firefox-UI-Fix/blob/36e9c94844fee2417662251cbd50c2b874d5b576/userChrome.css#L3754-L3852)

For icons, [`list-style-image`](https://developer.mozilla.org/en-US/docs/Web/CSS/list-style-image) and [`background-image`](https://developer.mozilla.org/en-US/docs/Web/CSS/background-image) are available.

It is recommended to use `list-style-image` when a layout is provided for the image.  
`background-image` may require many calculations to fit the layout.
- [Replace Library Icon](https://github.com/black7375/Firefox-UI-Fix/blob/36e9c94844fee2417662251cbd50c2b874d5b576/userChrome.css#L3923-L3965)
- [Panel Icon](https://github.com/black7375/Firefox-UI-Fix/blob/36e9c94844fee2417662251cbd50c2b874d5b576/userChrome.css#L4136-L4214)
- [Menu Item Icon](https://github.com/black7375/Firefox-UI-Fix/blob/36e9c94844fee2417662251cbd50c2b874d5b576/userChrome.css#L4551-L4744)
- [Error Illustration](https://github.com/black7375/Firefox-UI-Fix/blob/36e9c94844fee2417662251cbd50c2b874d5b576/userContent.css#L275-L380)

You can use [`-moz-box-ordinal-group`](https://udn.realityripple.com/docs/Web/CSS/box-ordinal-group)([`-moz-box`](https://udn.realityripple.com/docs/Web/CSS/Mozilla_Extensions#display)) and [`order`](https://developer.mozilla.org/en-US/docs/Web/CSS/order)(at [flex](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Flexible_Box_Layout/Basic_Concepts_of_Flexbox)) to change the order of the layout.  
In experience, the detailed actions of `-moz-box` and `flex` are different, so tests are required.
- [Separator Order](https://github.com/black7375/Firefox-UI-Fix/blob/36e9c94844fee2417662251cbd50c2b874d5b576/userChrome.css#L4286-L4288)
- [Sync Menu Item's Image Order](https://github.com/black7375/Firefox-UI-Fix/blob/36e9c94844fee2417662251cbd50c2b874d5b576/userChrome.css#L4234-L4238)
- [Tabs On Bottom](https://github.com/black7375/Firefox-UI-Fix/blob/c453ef43a699759f55800a5d266a89ac11321b2b/src/tabbar/_tabs_on_bottom.scss#L4-L32)

Finally, it's time to respond to various states.

By default, [attribute selectors](https://developer.mozilla.org/en-US/docs/Web/CSS/Attribute_selectors) is used, and sometimes [hard coding](https://github.com/black7375/Firefox-UI-Fix/blob/36e9c94844fee2417662251cbd50c2b874d5b576/userChrome.css#L873-L893) according to [selector specificity](https://developer.mozilla.org/en-US/docs/Web/CSS/Specificity) may be required.  
If there is no state attributes, you can bypass by using [both transitions and keyframes](https://github.com/black7375/Firefox-UI-Fix/blob/36e9c94844fee2417662251cbd50c2b874d5b576/userChrome.css#L2704-L2730) for animation.

### Shadow DOM
Firefox actively uses [shadow dom](https://developer.mozilla.org/en-US/docs/Web/Web_Components/Using_shadow_DOM) internally.

To modify, it is often a roundabout approach or impossible to inherit.

Onething bypass method is to declare [`var()`](https://developer.mozilla.org/en-US/docs/Web/CSS/var) to shadow root.
- [Scrollbutton Padding](https://github.com/black7375/Firefox-UI-Fix/blob/36e9c94844fee2417662251cbd50c2b874d5b576/userChrome.css#L2906-L2924)
- [Audio, Video Player UI](https://github.com/black7375/Firefox-UI-Fix/blob/36e9c94844fee2417662251cbd50c2b874d5b576/userContent.css#L5-L47)
- [Video Player Twoline UI](https://github.com/black7375/Firefox-UI-Fix/blob/cbf14cd55a9edada7ab2f5f1b626608fb9fe38a2/src/contents/_video_player.scss#L68-L171): It is pretty difficult when the condition becomes complicated.

### XUL
Sometimes firefox can use [XUL](https://en.wikipedia.org/wiki/XUL) that have been written and binded with C++ for performance like a treeview of bookmarks.

There ar few appropriate documents, so we have to read the source code and work. (Ex. [1](https://github.com/mozilla/gecko-dev/blob/master/layout/style/nsCSSAnonBoxList.h), [2](https://github.com/mozilla/gecko-dev/blob/master/layout/xul/tree/nsITreeView.idl))

Available CSS features are also restricted.

Example of legacy documents that will help.
- [UDN: ::-moz-tree-cell](https://udn.realityripple.com/docs/Mozilla/Gecko/Chrome/CSS/::-moz-tree-cell)
- [UDN: ::-moz-tree-cell-text](https://udn.realityripple.com/docs/Mozilla/Gecko/Chrome/CSS/::-moz-tree-cell-text)
