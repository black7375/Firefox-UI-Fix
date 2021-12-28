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
user_pref("userChrome.tab.original",          true); // Original
// user_pref("userChrome.tab.photon",            true); // Photon
// user_pref("userChrome.tab.proton",            true); // Proton
user_pref("userChrome.tab.connect_to_window", true); // Original, Photon

user_pref("userChrome.panel.proton", true); // Original, Proton
// user_pref("userChrome.panel.photon", true); // Photon

// == Theme Default Settings ===================================================
user_pref("userChrome.theme.built_in_contrast", true);
user_pref("userChrome.theme.compatibility", true);
user_pref("userChrome.theme.compatibility.theme", true);
user_pref("userChrome.theme.compatibility.os", true);
user_pref("userChrome.theme.system_default", true);
user_pref("userChrome.theme.fully_color", true);

// ** Useful Options ***********************************************************
// Integrated calculator at urlbar
user_pref("browser.urlbar.suggest.calculator", true);

// Integrated unit convertor at urlbar
// user_pref("browser.urlbar.unitConversion.enabled", true);

// Draw in Titlebar
// user_pref("browser.tabs.drawInTitlebar", true);
// user_pref("browser.tabs.inTitlebar",        1); // Nightly, 96 Above
