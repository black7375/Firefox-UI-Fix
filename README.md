# Lepton (old name: Proton Fix)

**Table of Contents**

- [Lepton (old name: Proton Fix)](#lepton-old-name-proton-fix)
  - [Introduction](#introduction)
  - [Installation Guide](#installation-guide)
  - [WHY Proton?](#why-proton)
  - [WHY Not Proton?](#why-not-proton)
  - [Padding Comparisons](#padding-comparisons)
  - [Sponsors & Contributors](#sponsors--contributors)
  - [Bug / Questions?](#bug--questions)
  - [FAQ](#faq)

---

🔔🔔 Does the theme not work after installation?

You should copy [`user.js`](./user.js) file before the theme works.

The option system depends on user configuration, and nothing applies without settings. \
Also, real-time changes are difficult because of [technical limitations](./docs/Restrictions.md#supports) and require a restart.

Some settings [can be conflicted](https://github.com/black7375/Firefox-UI-Fix/wiki/Options#using-userjs) and should be explicitly set to `false`.

---

🔔🔔 Is your Firefox version `v102` or lower?

You [have to set](https://github.com/black7375/Firefox-UI-Fix/wiki/Compatibility-Issues-Solution#accent-color-at-v102-or-lower) `userChrome.compatibility.accent_color` to `true` additionally.

---

## Introduction

[Proton](https://wiki.mozilla.org/Firefox/Proton) is Firefox's [new design](https://acorn.firefox.com/), starting from Firefox 89. \
[Photon](https://firefoxux.github.io/photon/) is the old design of Firefox which was used until version 88.

Proton's [overall feel is good](#why-proton), but there were a few things I [didn't like](#why-not-proton) and wanted to improve. \
That's why this project was born, and Lepton to denote light theme layer.

*Disclaimer:* It works on **Firefox 89** and above!!

| **Wiki** | | | | | | |
| --- | --- | --- | --- | --- | --- | --- |
| [Installation Guide](https://github.com/black7375/Firefox-UI-Fix/wiki/Installation-Guide) | [Screenshots](https://github.com/black7375/Firefox-UI-Fix/wiki/Screenshots) | [Tutorial](https://github.com/black7375/Firefox-UI-Fix/wiki/Tutorial) | [Options](https://github.com/black7375/Firefox-UI-Fix/wiki/Options) | [Compatibility Issues Solution](https://github.com/black7375/Firefox-UI-Fix/wiki/Compatibility-Issues-Solution) | [Tips](https://github.com/black7375/Firefox-UI-Fix/wiki/Tips) | [Show Off Your Config](https://github.com/black7375/Firefox-UI-Fix/wiki/Show-Off-Your-Config) |

![Lepton's design](https://user-images.githubusercontent.com/25581533/119774062-20942280-beb1-11eb-80aa-c18dd52f18d7.png)

(Lepton's design :arrow_up:)

<details>
<summary><strong>Feature List (Click)</strong></summary>

- **Color**
  - Default light/dark theme contrast enhancement
  - Colorful context menu
  - More dark mode support
  - Windows/Mac/Linux system theme support
  - Windows 7 compatibility
- **Icons**
  - Panel
  - Context Menu
  - Global Menu
  - Library's open context
  - Video Player
- **Padding Narrower**
  - Tab
  - Panel
  - Menu
  - Density
  - Others…
- **Tab Bar Layouts**
  - Tabs on Bottom
  - One Liner
  - Vertical Tab Support
- **Tab Design**
  - General:
    - Connect with toolbar (buttons like tabs)
  - Selected:
    - Box Shadow: Highlight the selected tab
    - Bottom Rounding: Natural
  - MultiSelected
    - Adjust Color: Easily recognizable
  - Unselect:
    - Divide Line: React to hover like chrome
  - Unloaded:
    - Dimmed: Looks like inactive
  - Clipped:
    - Clearer Text: Adjusted clipped gradation
    - Closed Button: Visible on hover
  - Sound:
    - Remove Second Label
    - Show Favicon: Always show favicon
    - PIP Icon
  - Container Tab:
    - Highlight line position: Displayed under tab
- **Button Design**
  - New tab: Looks like tab
- **Activity Stream Design**
  - Search Bar:
    - Focused Shadow: Same as the accent color
    - Hand off to Awesomebar
  - Icons:
    - Size: Fill (Changes dynamically to your size)
- **Error Page Design**
  - Illustrations: Restore error page illustrations
- **Video Player**
  - Background Style
  - Size at fullscreen
- **Fullscreen**
  - Overlap mode
- **Others**
  - Animations
  - Hidden & Auto Hide
  - Activate calculator at address bar
  - Mouse pointer for each context

</details>

## Installation Guide

**Installation script (experimental)**

Linux/Mac users:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/black7375/Firefox-UI-Fix/master/install.sh)"
```

Windows users: Run with powershell ([Does not work at Win7?](https://github.com/black7375/Firefox-UI-Fix/wiki/Compatibility-Issues-Solution#windows-7-powershell-script-not-works))

```powershell
Powershell -c "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iwr https://raw.githubusercontent.com/black7375/Firefox-UI-Fix/master/install.ps1 -useb | iex"
```

**Manual Installation**

You can see the [installation guide](https://github.com/black7375/Firefox-UI-Fix/wiki/Installation-Guide) with screenshots on the wiki.

1. Download files
   - Click the green ":arrow_down: Code" button above
   - Select ":package: Download ZIP"
2. Find your profile directory
   - Open `about:support` in a new tab
   - Find the `Profile Directory(Linux)` / `Profile Folder(Windows)` entry
   - Click the `Open Directory(Linux)` / `Open Folder(Windows)` button
3. Copy downloaded files
   - Extract the downloaded zip file
   - Copy the `user.js` file to the previously opened profile directory
   - Create a new directory inside your profile directory called `chrome`
   - Copy the remaining files from the extracted zip-file into previously created the `chrome` directory
4. Restart Firefox
   - Click the `Clear startup cache…` at the top of `about:support`

If you prefer Photon, see [Lepton's photon-style](https://github.com/black7375/Firefox-UI-Fix/tree/photon-style).\
If you prefer Proton, see [Lepton's proton-style](https://github.com/black7375/Firefox-UI-Fix/tree/proton-style).

## WHY Proton?

I think a lot has improved.

![Proton's design](https://user-images.githubusercontent.com/25581533/119773764-a6639e00-beb0-11eb-8023-498b6293c4b2.png)

(Proton's design :arrow_up:)

- Neatly organized menu
- Icon beautiful enough to remind you of Edge
- Nice color scheme
- Satisfied Rounding
- Modal window & Scrollbar!!

## WHY Not Proton?

However, there are also many flaws.

![Photon's design](https://user-images.githubusercontent.com/25581533/119773812-b5e2e700-beb0-11eb-923c-55ae1a8ca249.png)

(Photon's design :arrow_up:)

- Is it a tab or a button?
- Where are the menu icons?
- Icons in ActivityStream are too small
- Padding gaps are wide
- :warning: Address bar 3-point menu, screenshot moves to toolbar (can't fix)

## Padding Comparisons

![Padding comparison 1](https://user-images.githubusercontent.com/25581533/120262626-8c97d180-c289-11eb-87a6-68e285d6d77c.png)

![Padding comparison 2](https://user-images.githubusercontent.com/25581533/120253257-6ae11f00-c276-11eb-93cf-393f9845f30b.png)

![Padding comparison 3](https://user-images.githubusercontent.com/25581533/118402352-1e33fc00-b659-11eb-89fc-3cb38207fe39.png)

![Padding comparison 4](https://user-images.githubusercontent.com/25581533/124066951-0eb21c00-da29-11eb-9ac4-c6b82a268c6f.png)

- Photon (Quantum)
- Proton
- Lepton

## Sponsors & Contributors

Thanks to all sponsors & contributors to this project for providing help and developing features!

**Sponsors**

[![OSS](https://user-images.githubusercontent.com/25581533/203210367-9f2eed69-666a-4218-acde-128892aa09d8.png)](https://www.oss.kr/)
[<img alt="BrowserWorks" width="60" height="60" src="https://avatars.githubusercontent.com/u/78850935?s=60&v=4"/>](https://github.com/BrowserWorks)
[<img alt="ojaha065" width="60" height="60" src="https://avatars.githubusercontent.com/u/37581768?s=60&v=4"/>](https://github.com/ojaha065)
[<img alt="DPS0340" width="60" height="60" src="https://avatars.githubusercontent.com/u/32592965?s=60&v=4"/>](https://github.com/DPS0340)
[<img alt="ZachKnife1" width="60" height="60" src="https://avatars.githubusercontent.com/u/114311925?s=60&v=4"/>](https://github.com/ZachKnife1)
[<img alt="kanlukasz" width="60" height="60" src="https://avatars.githubusercontent.com/u/30685349?s=60&v=4"/>](https://github.com/kanlukasz)
[<img alt="nikkehtine" width="60" height="60" src="https://avatars.githubusercontent.com/u/27138416?s=60&v=4"/>](https://github.com/nikkehtine)
[<img alt="Babbiorsetto" width="60" height="60" src="https://avatars.githubusercontent.com/u/36596647?s=60&v=4"/>](https://github.com/Babbiorsetto)
[<img alt="Mike-Kennelly" width="60" height="60" src="https://avatars.githubusercontent.com/u/151653777?s=60&v=4"/>](https://github.com/Mike-Kennelly)
[<img alt="Cyberax" width="60" height="60" src="https://avatars.githubusercontent.com/u/1136550?s=60&v=4"/>](https://github.com/Cyberax)
[<img alt="AuRiMaS666" width="60" height="60" src="https://avatars.githubusercontent.com/u/59185222?s=60&v=4"/>](https://github.com/AuRiMaS666)
[<img alt="firefox9067" width="60" height="60" src="https://avatars.githubusercontent.com/u/80527364?s=60&v=4"/>](https://github.com/firefox9067)
[<img alt="Ygg01" width="60" height="60" src="https://avatars.githubusercontent.com/u/1146204?s=60&v=4"/>](https://github.com/Ygg01)
[<img alt="engelju" width="60" height="60" src="https://avatars.githubusercontent.com/u/2188152?s=60&v=4"/>](https://github.com/engelju)
[<img alt="xrstf" width="60" height="60" src="https://avatars.githubusercontent.com/u/127499?s=60&v=4"/>](https://github.com/xrstf)
[<img alt="akwala" width="60" height="60" src="https://avatars.githubusercontent.com/u/1786?s=60&v=4"/>](https://github.com/akwala)

- A donation was received on [Ko-Fi](https://ko-fi.com/black7375)
  - [Safira](https://ko-fi.com/home/coffeeshop?txid=97e5fa0d-c73e-4308-a2fd-6b44b08cd828)
  - [duncanyoyo1](https://ko-fi.com/duncanyoyo1)
  - [Minithra](https://ko-fi.com/home/coffeeshop?txid=a84c4838-f0e8-45b4-8b61-46684697e9b2)
  - [Kevin Ernst](https://github.com/black7375/Firefox-UI-Fix/issues/1095#issuecomment-3682151859)
- Private sponsors: 5

**Contributors**

[<img alt="Contributors" src="https://contrib.rocks/image?repo=black7375/Firefox-UI-Fix"/>](https://github.com/black7375/Firefox-UI-Fix/graphs/contributors)

A list of all contributors can be found in [CREDITS](./CREDITS).

## Bug / Questions?

If you found a bug, please contact [issue](https://github.com/black7375/Firefox-UI-Fix/issues). \
If you have any questions or inquiries, please contact [discussions](https://github.com/black7375/Firefox-UI-Fix/discussions).

## FAQ

- **Black pixels around the selected tab bottom corners** \
  ![Black pixels around the selected tab's bottom corners](https://user-images.githubusercontent.com/5571586/120401980-edf58a00-c2f5-11eb-9e64-ce50c5b189b2.png)

  Please follow the [Installation Guide](https://github.com/black7375/Firefox-UI-Fix/wiki/Installation-Guide), \
  or set `about:config`'s `svg.context-properties.content.enabled` to `true` .

- **The closed button and some panel menu icons are not visible.** \
  ![Missing close button](https://user-images.githubusercontent.com/77958663/130395848-7af58241-bbbf-4273-bb62-14382c44098d.png)

  ![Missing panel menu icons](https://user-images.githubusercontent.com/25581533/120487528-93b40200-c3a5-11eb-98ad-3498beb9f38e.png)

  Please follow the [Installation Guide](https://github.com/black7375/Firefox-UI-Fix/wiki/Installation-Guide), \
  or copy the `icons` directory to `chrome` .

- **Less icons in the panel with photon-style**\
  ![Photon-style panel icons 1](https://user-images.githubusercontent.com/25581533/123761424-5746c980-d8b1-11eb-9a0f-83fb305f9f08.png)

  ![Photon-style panel icons 2](https://user-images.githubusercontent.com/25581533/123762962-d4bf0980-d8b2-11eb-8492-d497d330c72a.png)

  I didn't put all the icons like before.\
  ![Previous panel icons](https://user-images.githubusercontent.com/25581533/123602947-dd4b0d80-d7e8-11eb-93a6-2b263bdd99f7.png)
