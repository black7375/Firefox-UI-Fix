# Rules

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Basics](#basics)
  * [Issue](#issue)
  * [Version](#version)
  * [Branch](#branch)
- [Edit](#edit)
  * [Modify only source file](#modify-only-source-file)
  * [Coding style](#coding-style)
- [Commits](#commits)
  * [Commit](#commit)
  * [Commit Message](#commit-message)
  * [Pull request](#pull-request)

<!-- markdown-toc end -->

## Basics
This is a rough guideline. (Not forced)

Feel free to make PR.

### Issue

**Search:**
- Search the project’s [issues](https://github.com/black7375/Firefox-UI-Fix/issues) to make sure it's not a known issue.

**Versions:**
- Make sure you’re on the latest version.
- Try older versions.
- Try switching up dependency versions.

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

## Edit
### Modify only source file

Do not modify files that are built directly or automatically generated.

### Coding style

- **Indent:** 2 spaces for indentation rather than tabs.
- **Columns:** Fit `80`~`100` columns as much as possible. (Auto formatting is using 120 to avoid the worst case)

## Commits
### Commit

- **Meaningfully:**: It doesn't make meaningless commits.
- **One per task:** It's difficult to distinguish when various tasks are mixed.
- **Often:** Codes may corrupt during large changes.

### Commit Message

For intuitive recognition, I [put a **prefix**](https://github.com/black7375/Firefox-UI-Fix/commits/master).
- `Add:` Add feature or enhanced.
- `Bump:` Update dependency packages.
- `Fix:` Bug fix or change default values.
- `Clean:` Refactoring.
- `Doc:` Update docs.

### Pull request

- **Branch:** Check the [Branch](#branch) section and PR to the correct branch.
- **Issue:** We recommend that you open the issue first to discuss the changes with the owner of this repository.
- **Build:** Please check if it was built before PR.
