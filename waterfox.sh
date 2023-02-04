## Please refer to the following commit:
# https://github.com/WaterfoxCo/Waterfox/commit/f92e95c09ecd98f987bf54e1e6a1cf969b683277

## Replace Path
# `./leptonIcons/` to `chrome://browser/skin/lepton/`
replace_icon_path() {
  file=$1
  sed -i "s/\.\.\/leptonIcons\//chrome:\/\/browser\/skin\/lepton\//g" "${file}"
}
replace_icon_path leptonCss/leptonChrome.css
replace_icon_path leptonCss/leptonContent.css
