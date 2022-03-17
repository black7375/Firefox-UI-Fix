// ** Theme Default Options ****************************************************
// userchrome.css usercontent.css activate
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// Proton Enabled #127
user_pref("browser.proton.enabled", true);

// Proton Tooltip
user_pref("browser.proton.places-tooltip.enabled", true);

// Fill SVG Color
user_pref("svg.context-properties.content.enabled", true);

// CSS Color Mix - 88 Above
user_pref("layout.css.color-mix.enabled", true);

// CSS Blur Filter - 88 Above
user_pref("layout.css.backdrop-filter.enabled", true);

// Restore Compact Mode - 89 Above
user_pref("browser.compactmode.show", true);

// about:home Search Bar - 89 Above
user_pref("browser.newtabpage.activity-stream.improvesearch.handoffToAwesomebar", false);

// Browser Theme Based Scheme - Will be activate 95 Above
// user_pref("layout.css.prefers-color-scheme.content-override", 3);

// ** Theme Related Options ****************************************************
user_pref("userChrome.tab.original",                true); // Original
// user_pref("userChrome.tab.photon",               true); // Photon
// user_pref("userChrome.tab.proton",               true); // Proton
user_pref("userChrome.tab.connect_to_window",       true); // Original, Photon
user_pref("userChrome.tab.box_shadow",              true); // Original
user_pref("userChrome.tab.bottom_rounded_corner",   true); // Original
user_pref("userChrome.tab.lepton_like_padding",     true); // Original
// user_pref("userChrome.tab.photon_like_contextline", true); // Photon
// user_pref("userChrome.tab.photon_like_padding",  true); // Photon

user_pref("userChrome.panel.proton", true); // Original, Proton
// user_pref("userChrome.panel.photon", true); // Photon

// == Theme Custom Settings ====================================================
// user_pref("userChrome.padding.firstTab",  true);
// user_pref("userChrome.padding.dragSpace", true);

// == Theme Default Settings ===================================================
user_pref("userChrome.compatibility.theme", true);
user_pref("userChrome.compatibility.os",    true);

user_pref("userChrome.theme.built_in_contrast", true);
user_pref("userChrome.theme.system_default",    true);
user_pref("userChrome.theme.proton_color",      true);
user_pref("userChrome.theme.proton_chrome",     true); // Need proton_color
user_pref("userChrome.theme.fully_color",       true); // Need proton_color
user_pref("userChrome.theme.fully_dark",        true); // Need proton_color

user_pref("userChrome.decoration.cursor",         true);
user_pref("userChrome.decoration.field_border",   true);
user_pref("userChrome.decoration.download_panel", true);
user_pref("userChrome.decoration.animate",        true);

user_pref("userChrome.padding.tabbarWidth",  true);
user_pref("userChrome.padding.tabbarHeight", true);
user_pref("userChrome.padding.navbarWidth",  true);
user_pref("userChrome.padding.urlbar",       true);
user_pref("userChrome.padding.bookmarkbar",  true);
user_pref("userChrome.padding.infobar",      true);
user_pref("userChrome.padding.menu",         true);
user_pref("userChrome.padding.bookmarkMenu", true);
user_pref("userChrome.padding.globalMenu",   true);
user_pref("userChrome.padding.popupPanel",   true);

user_pref("userChrome.tab.multi_selected",        true);
user_pref("userChrome.tab.unloaded",              true);
user_pref("userChrome.tab.letters_cleary",        true);
user_pref("userChrome.tab.close_button_at_hover", true);
user_pref("userChrome.tab.sound_hide_label",      true);
user_pref("userChrome.tab.sound_with_favicons",   true);
user_pref("userChrome.tab.pip",                   true);
user_pref("userChrome.tab.container",             true);
user_pref("userChrome.tab.crashed",               true);

user_pref("userChrome.fullscreen.overlap", true);

user_pref("userChrome.icon.library",      true);
user_pref("userChrome.icon.panel",        true);
user_pref("userChrome.icon.menu",         true);
user_pref("userChrome.icon.context_menu", true);
user_pref("userChrome.icon.global_menu",  true);

user_pref("userContent.player.ui",            true);
user_pref("userContent.player.icon",          true);
user_pref("userContent.player.noaudio",       true);
user_pref("userContent.player.size",          true);
user_pref("userContent.player.click_to_play", true);

user_pref("userContent.newTab.field_border", true);
user_pref("userContent.newTab.full_icon",    true);
user_pref("userContent.newTab.animate",      true);
user_pref("userContent.newTab.searchbar",    true);

user_pref("userContent.page.illustration", true);
user_pref("userContent.page.dark_mode",     true);
user_pref("userContent.page.proton",        true);

// ** Useful Options ***********************************************************
// Integrated calculator at urlbar
user_pref("browser.urlbar.suggest.calculator", true);

// Integrated unit convertor at urlbar
// user_pref("browser.urlbar.unitConversion.enabled", true);

// Draw in Titlebar
// user_pref("browser.tabs.drawInTitlebar", true);
// user_pref("browser.tabs.inTitlebar",        1); // Nightly, 96 Above
