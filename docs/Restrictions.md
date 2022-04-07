# Restrictions

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
