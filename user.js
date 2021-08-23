// ** Theme Related Options ****************************************************
// userchrome.css usercontent.css activate
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// Proton Enabled #127
user_pref("browser.proton.enabled", true);

// Fill SVG Color
user_pref("svg.context-properties.content.enabled", true);

// CSS Blur Filter - 88 Above
user_pref("layout.css.backdrop-filter.enabled", true);

// Restore Compact Mode - 89 Above
user_pref("browser.compactmode.show", true);

// about:home Search Bar
// user_pref("browser.newtabpage.activity-stream.improvesearch.handoffToAwesomebar", false);

// ** Useful Options ***********************************************************
// Integrated calculator at urlbar
user_pref("browser.urlbar.suggest.calculator", true);

// Integrated unit convertor at urlbar
// user_pref("browser.urlbar.unitConversion.enabled", true);

// ** Scrolling Options ********************************************************
//         Pref                                             Value      Original
user_pref("mousewheel.min_line_scroll_amount",                 10); //        5
user_pref("general.smoothScroll.mouseWheel.durationMinMS",     80); //       50
user_pref("general.smoothScroll.currentVelocityWeighting", "0.15"); //   "0.25"
user_pref("general.smoothScroll.stopDecelerationWeighting", "0.6"); //    "0.4"
