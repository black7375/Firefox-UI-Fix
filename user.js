// ** Theme Default Options ****************************************************
// userchrome.css usercontent.css activate
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// Proton Enabled #127 || Removed at 97 #328 (Maintained for compatibility with ESR)
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
// Mutliple
user_pref("userChrome.tab.connect_to_window",          true); // Original, Photon

user_pref("userChrome.tab.lepton_like_padding",        true); // Original
// user_pref("userChrome.tab.photon_like_padding",     true); // Photon

user_pref("userChrome.tab.dynamic_separtor",           true); // Original, Proton
// user_pref("userChrome.tab.static_separator",        true); // Photon

user_pref("userChrome.tab.newtab_button_like_tab",     true); // Original
// user_pref("userChrome.tab.newtab_button_smaller",   true); // Photon
// user_pref("userChrome.tab.newtab_button_proton",    true); // Proton

user_pref("userChrome.icon.panel_full",                true); // Original, Proton
// user_pref("userChrome.icon.panel_sparse",           true); // Photon

// Original Only
user_pref("userChrome.tab.box_shadow",                 true);
user_pref("userChrome.tab.bottom_rounded_corner",      true);

// Photon Only
// user_pref("userChrome.tab.photon_like_contextline", true);
// user_pref("userChrome.tab.photon_like_radius",      true);

// == Theme Custom Settings ====================================================
// user_pref("userChrome.padding.first_tab",                true);
// user_pref("userChrome.padding.drag_space",               true);

// user_pref("userChrome.padding.menu_compact",             true);
// user_pref("userChrome.padding.urlView_expanding",        true);
// user_pref("userChrome.padding.urlView_result",           true);

// user_pref("userChrome.urlView.move_icon_to_left",        true);
// user_pref("userChrome.urlView.go_button_when_typing",    true);
// user_pref("userChrome.urlView.always_show_page_actions", true);

// user_pref("userChrome.tab.always_show_tab_icon",         true);
// user_pref("userChrome.tab.close_button_at_hover.always", true); // Need close_button_at_hover
// user_pref("userChrome.tab.sound_show_label",             true); // Need remove sound_hide_label
// user_pref("userChrome.tab.centered_label",               true);

// user_pref("userChrome.panel.remove_strip",               true);

// == Theme Default Settings ===================================================
// -- User Chrome --------------------------------------------------------------
user_pref("userChrome.compatibility.theme",       true);
user_pref("userChrome.compatibility.os",          true);

user_pref("userChrome.theme.built_in_contrast",   true);
user_pref("userChrome.theme.system_default",      true);
user_pref("userChrome.theme.proton_color",        true);
user_pref("userChrome.theme.proton_chrome",       true); // Need proton_color
user_pref("userChrome.theme.fully_color",         true); // Need proton_color
user_pref("userChrome.theme.fully_dark",          true); // Need proton_color

user_pref("userChrome.decoration.cursor",         true);
user_pref("userChrome.decoration.field_border",   true);
user_pref("userChrome.decoration.download_panel", true);
user_pref("userChrome.decoration.animate",        true);

user_pref("userChrome.padding.tabbar_width",      true);
user_pref("userChrome.padding.tabbar_height",     true);
user_pref("userChrome.padding.toolbar_button",    true);
user_pref("userChrome.padding.navbar_width",      true);
user_pref("userChrome.padding.urlbar",            true);
user_pref("userChrome.padding.bookmarkbar",       true);
user_pref("userChrome.padding.infobar",           true);
user_pref("userChrome.padding.menu",              true);
user_pref("userChrome.padding.bookmark_menu",     true);
user_pref("userChrome.padding.global_menu",       true);
user_pref("userChrome.padding.panel",             true);
user_pref("userChrome.padding.popup_panel",       true);

user_pref("userChrome.tab.multi_selected",        true);
user_pref("userChrome.tab.unloaded",              true);
user_pref("userChrome.tab.letters_cleary",        true);
user_pref("userChrome.tab.close_button_at_hover", true);
user_pref("userChrome.tab.sound_hide_label",      true);
user_pref("userChrome.tab.sound_with_favicons",   true);
user_pref("userChrome.tab.pip",                   true);
user_pref("userChrome.tab.container",             true);
user_pref("userChrome.tab.crashed",               true);

user_pref("userChrome.fullscreen.overlap",        true);

user_pref("userChrome.icon.library",              true);
user_pref("userChrome.icon.panel",                true);
user_pref("userChrome.icon.menu",                 true);
user_pref("userChrome.icon.context_menu",         true);
user_pref("userChrome.icon.global_menu",          true);

// -- User Content -------------------------------------------------------------
user_pref("userContent.player.ui",            true);
user_pref("userContent.player.icon",          true);
user_pref("userContent.player.noaudio",       true);
user_pref("userContent.player.size",          true);
user_pref("userContent.player.click_to_play", true);
user_pref("userContent.player.animate",       true);

user_pref("userContent.newTab.field_border",  true);
user_pref("userContent.newTab.full_icon",     true);
user_pref("userContent.newTab.animate",       true);
user_pref("userContent.newTab.searchbar",     true);

user_pref("userContent.page.illustration",    true);
user_pref("userContent.page.proton_color",    true);
user_pref("userContent.page.dark_mode",       true); // Need proton_color
user_pref("userContent.page.proton",          true); // Need proton_color

// ** Useful Options ***********************************************************
// Integrated calculator at urlbar
user_pref("browser.urlbar.suggest.calculator", true);

// Integrated unit convertor at urlbar
// user_pref("browser.urlbar.unitConversion.enabled", true);

// Draw in Titlebar
// user_pref("browser.tabs.drawInTitlebar", true);
// user_pref("browser.tabs.inTitlebar",        1); // Nightly, 96 Above
