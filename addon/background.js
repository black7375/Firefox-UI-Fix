function setDefaultPrefs() {
  return Promise.all([
    // ** Theme Default Options ****************************************************
    browser.prefs.set("browser.proton.enabled", true),
    browser.prefs.set("svg.context-properties.content.enabled", true),
    browser.prefs.set("layout.css.color-mix.enabled", true),
    browser.prefs.set("layout.css.backdrop-filter.enabled", true),
    browser.prefs.set("browser.compactmode.show", true),
    browser.prefs.set("browser.newtabpage.activity-stream.improvesearch.handoffToAwesomebar", false),
    browser.prefs.set("layout.css.has-selector.enabled", true),

    // ** Theme Related Options ****************************************************
    // == Theme Distribution Settings ==============================================
    browser.prefs.set("userChrome.tab.connect_to_window", true, true),
    browser.prefs.set("userChrome.tab.color_like_toolbar", true, true),

    browser.prefs.set("userChrome.tab.lepton_like_padding", true, true),
    browser.prefs.set("userChrome.tab.photon_like_padding", true, true),

    browser.prefs.set("userChrome.tab.dynamic_separator", true, true),
    browser.prefs.set("userChrome.tab.static_separator", false, true),
    browser.prefs.set("userChrome.tab.static_separator.selected_accent", false, true),
    browser.prefs.set("userChrome.tab.bar_separator", false, true),

    browser.prefs.set("userChrome.tab.newtab_button_like_tab", true, true),
    browser.prefs.set("userChrome.tab.newtab_button_smaller", false, true),
    browser.prefs.set("userChrome.tab.newtab_button_proton", false, true),

    browser.prefs.set("userChrome.icon.panel_full", true, true),
    browser.prefs.set("userChrome.icon.panel_photon", false, true),

    browser.prefs.set("userChrome.tab.box_shadow", true, true),
    browser.prefs.set("userChrome.tab.bottom_rounded_corner", true, true),

    browser.prefs.set("userChrome.tab.photon_like_contextline", false, true),
    browser.prefs.set("userChrome.rounding.square_tab", false, true),

    browser.prefs.set("userChrome.tab.connect_to_window", true, true),
    browser.prefs.set("userChrome.tab.connect_to_window", true, true),
    browser.prefs.set("userChrome.tab.connect_to_window", true, true),
    browser.prefs.set("userChrome.tab.connect_to_window", true, true),

    // == Theme Default Settings ===================================================
    // -- User Chrome --------------------------------------------------------------
    browser.prefs.set("userChrome.compatibility.theme", true, true),
    browser.prefs.set("userChrome.compatibility.os", true, true),

    browser.prefs.set("userChrome.theme.built_in_contrast", true, true),
    browser.prefs.set("userChrome.theme.system_default", true, true),
    browser.prefs.set("userChrome.theme.proton_color", true, true),
    browser.prefs.set("userChrome.theme.proton_chrome", true, true),
    browser.prefs.set("userChrome.theme.fully_color", true, true),
    browser.prefs.set("userChrome.theme.fully_dark", true, true),

    browser.prefs.set("userChrome.decoration.cursor", true, true),
    browser.prefs.set("userChrome.decoration.field_border", true, true),
    browser.prefs.set("userChrome.decoration.download_panel", true, true),
    browser.prefs.set("userChrome.decoration.animate", true, true),

    browser.prefs.set("userChrome.padding.tabbar_width", true, true),
    browser.prefs.set("userChrome.padding.tabbar_height", true, true),
    browser.prefs.set("userChrome.padding.toolbar_button", true, true),
    browser.prefs.set("userChrome.padding.navbar_width", true, true),
    browser.prefs.set("userChrome.padding.urlbar", true, true),
    browser.prefs.set("userChrome.padding.bookmarkbar", true, true),
    browser.prefs.set("userChrome.padding.infobar", true, true),
    browser.prefs.set("userChrome.padding.menu", true, true),
    browser.prefs.set("userChrome.padding.bookmark_menu", true, true),
    browser.prefs.set("userChrome.padding.global_menubar", true, true),
    browser.prefs.set("userChrome.padding.panel", true, true),
    browser.prefs.set("userChrome.padding.popup_panel", true, true),

    browser.prefs.set("userChrome.tab.multi_selected", true, true),
    browser.prefs.set("userChrome.tab.unloaded", true, true),
    browser.prefs.set("userChrome.tab.letters_cleary", true, true),
    browser.prefs.set("userChrome.tab.close_button_at_hover", true, true),
    browser.prefs.set("userChrome.tab.sound_hide_label", true, true),
    browser.prefs.set("userChrome.tab.sound_with_favicons", true, true),
    browser.prefs.set("userChrome.tab.pip", true, true),
    browser.prefs.set("userChrome.tab.container", true, true),
    browser.prefs.set("userChrome.tab.crashed", true, true),

    browser.prefs.set("userChrome.fullscreen.overlap", true, true),
    browser.prefs.set("userChrome.fullscreen.show_bookmarkbar", true, true),

    browser.prefs.set("userChrome.icon.library", true, true),
    browser.prefs.set("userChrome.icon.panel", true, true),
    browser.prefs.set("userChrome.icon.menu", true, true),
    browser.prefs.set("userChrome.icon.context_menu", true, true),
    browser.prefs.set("userChrome.icon.global_menu", true, true),
    browser.prefs.set("userChrome.icon.global_menubar", true, true),

    // -- User Content -------------------------------------------------------------
    browser.prefs.set("userContent.player.ui", true, true),
    browser.prefs.set("userContent.player.icon", true, true),
    browser.prefs.set("userContent.player.noaudio", true, true),
    browser.prefs.set("userContent.player.size", true, true),
    browser.prefs.set("userContent.player.click_to_play", true, true),
    browser.prefs.set("userContent.player.animate", true, true),

    browser.prefs.set("userContent.newTab.full_icon", true, true),
    browser.prefs.set("userContent.newTab.animate", true, true),
    browser.prefs.set("userContent.newTab.pocket_to_last", true, true),
    browser.prefs.set("userContent.newTab.searchbar", true, true),

    browser.prefs.set("userContent.page.field_border", true, true),
    browser.prefs.set("userContent.page.illustration", true, true),
    browser.prefs.set("userContent.page.proton_color", true, true),
    browser.prefs.set("userContent.page.dark_mode", true, true),
    browser.prefs.set("userContent.page.proton", true, true)
  ]);
}

function loadStylesheets() {
  const load = browser.stylesheet.load;
  const getURL = browser.runtime.getURL;

  const globalSheet = getURL("css/leptonChrome.css");
  const contentSheet = getURL("css/leptonContent.css");

  return Promise.all([
    load(globalSheet, "AGENT_SHEET"),
    load(contentSheet, "USER_SHEET")
  ]);
}

// https://searchfox.org/mozilla-central/source/layout/base/nsIStyleSheetService.idl
async function startup() {
  if (!("prefs" in browser && "stylesheet" in browser)) {
    alert("MISSING API");
  }

  const installed = await browser.prefs.get("userChrome.lepton.installed");
  if (!installed) {
    await setDefaultPrefs();
    await browser.prefs.set("userChrome.lepton.installed", true);
  }

  await loadStylesheets();
}

startup();
