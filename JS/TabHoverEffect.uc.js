// == UserScript ==
// @include chrome : //browser/content/places/places.xhtml
// == / UserScript ==

// -- WARNNING!!!!! ------------------------------------------------------------
// It's very experimental
// Side effects such as performance may occur, and even if a problem occurs, we do not support it.

// -- Reveal Effect Library ----------------------------------------------------
/*
  Reveal Effect
  https://github.com/d2phap/fluent-reveal-effect
  MIT License
  Copyright (c) 2018 Duong Dieu Phap
  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:
  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
*/

function getOffset(element) {
  return {
    top: element.el.getBoundingClientRect().top,
    left: element.el.getBoundingClientRect().left
  };
}

function drawEffect(
  element,
  x,
  y,
  lightColor,
  gradientSize,
  cssLightEffect = null
) {
  let lightBg;

  if (cssLightEffect === null) {
    lightBg = `radial-gradient(circle ${gradientSize}px at ${x}px ${y}px, ${lightColor}, rgba(255,255,255,0))`;
  } else {
    lightBg = cssLightEffect;
  }

  element.el.style.backgroundImage = lightBg;
}

function preProcessElements(elements) {
  const res = [];

  elements.forEach(el => {
    res.push({
      oriBg: getComputedStyle(el)["background-image"],
      el: el
    });
  });

  return res;
}

function isIntersected(element, cursor_x, cursor_y, gradientSize) {
  const cursor_area = {
    left: cursor_x - gradientSize,
    right: cursor_x + gradientSize,
    top: cursor_y - gradientSize,
    bottom: cursor_y + gradientSize
  }

  const el_area = {
    left: element.el.getBoundingClientRect().left,
    right: element.el.getBoundingClientRect().right,
    top: element.el.getBoundingClientRect().top,
    bottom: element.el.getBoundingClientRect().bottom
  }

  function intersectRect(r1, r2) {
    return !(
      r2.left > r1.right ||
	r2.right < r1.left ||
	r2.top > r1.bottom ||
	r2.bottom < r1.top
    )
  }


  const result = intersectRect(cursor_area, el_area)

  return result
}



function applyEffect(selector, options = {}) {

  let is_pressed = false

  let _options = {
    lightColor: "rgba(255,255,255,0.25)",
    gradientSize: 150,
    clickEffect: false,
    isContainer: false,
    children: {
      borderSelector: ".eff-reveal-border",
      elementSelector: ".eff-reveal",
      lightColor: "rgba(255,255,255,0.25)",
      gradientSize: 150
    }
  }

  // update options
  _options = Object.assign(_options, options)
  const els =  preProcessElements(document.querySelectorAll(selector))




  function clearEffect(element) {
    is_pressed = false
    element.el.style.backgroundImage = element.oriBg
  }


  function enableBackgroundEffects(element, lightColor, gradientSize) {

    //element background effect --------------------
    element.el.addEventListener("mousemove", (e) => {
      let x = e.pageX - getOffset(element).left - window.scrollX
      let y = e.pageY - getOffset(element).top - window.scrollY

      if (_options.clickEffect && is_pressed) {

	let cssLightEffect = `radial-gradient(circle ${gradientSize}px at ${x}px ${y}px, ${lightColor}, rgba(255,255,255,0)), radial-gradient(circle ${70}px at ${x}px ${y}px, rgba(255,255,255,0), ${lightColor}, rgba(255,255,255,0), rgba(255,255,255,0))`

	drawEffect(element, x, y, lightColor, gradientSize, cssLightEffect)
      }
      else {
	drawEffect(element, x, y, lightColor, gradientSize)
      }
    })


    element.el.addEventListener("mouseleave", (e) => {
      clearEffect(element)
    })
  }



  function enableClickEffects(element, lightColor, gradientSize) {
    element.el.addEventListener("mousedown", (e) => {
      is_pressed = true
      const x = e.pageX - getOffset(element).left - window.scrollX
      const y = e.pageY - getOffset(element).top - window.scrollY

      const cssLightEffect = `radial-gradient(circle ${gradientSize}px at ${x}px ${y}px, ${lightColor}, rgba(255,255,255,0)), radial-gradient(circle ${70}px at ${x}px ${y}px, rgba(255,255,255,0), ${lightColor}, rgba(255,255,255,0), rgba(255,255,255,0))`

      drawEffect(element, x, y, lightColor, gradientSize, cssLightEffect)
    })

    element.el.addEventListener("mouseup", (e) => {
      is_pressed = false
      const x = e.pageX - getOffset(element).left - window.scrollX
      const y = e.pageY - getOffset(element).top - window.scrollY

      drawEffect(element, x, y, lightColor, gradientSize)
    })
  }




  //Children *********************************************
  if (!_options.isContainer) {

    //element background effect
    els.forEach(element => {
      enableBackgroundEffects(element, _options.lightColor, _options.gradientSize)

      //element click effect
      if (_options.clickEffect) {
	enableClickEffects(element, _options.lightColor, _options.gradientSize)
      }
    })

  }
  //Container *********************************************
  else {

    els.forEach(element => {

      // get border items list
      const childrenBorder = _options.isContainer ? preProcessElements(document.querySelectorAll(_options.children.borderSelector)) : []


      //Container *********************************************
      //add border effect
      element.el.addEventListener("mousemove", (e) => {
	for (let i = 0; i < childrenBorder.length; i++) {
	  const x = e.pageX - getOffset(childrenBorder[i]).left - window.scrollX
	  const y = e.pageY - getOffset(childrenBorder[i]).top - window.scrollY

	  if (isIntersected(childrenBorder[i], e.clientX, e.clientY, _options.gradientSize)) {
	    drawEffect(childrenBorder[i], x, y, _options.lightColor, _options.gradientSize)
	  }
	  else {
	    clearEffect(childrenBorder[i])
	  }

	}

      })

      //clear border light effect
      element.el.addEventListener("mouseleave", (e) => {
	for (let i = 0; i < childrenBorder.length; i++) {
	  clearEffect(childrenBorder[i])
	}
      })


      //Children *********************************************
      const children =  preProcessElements(element.el.querySelectorAll(_options.children.elementSelector))
      // console.log(children)

      for (let i = 0; i < children.length; i++) {

	//element background effect
	enableBackgroundEffects(children[i], _options.children.lightColor, _options.children.gradientSize)

	//element click effect
	if (_options.clickEffect) {
	  enableClickEffects(children[i], _options.children.lightColor, _options.children.gradientSize)
	}
      }

    })

  }
}


// -- Apply Effect -------------------------------------------------------------
// https://github.com/mozilla/gecko-dev/blob/1465ef37f27584b00b70587d18a3c2f96c9dae78/browser/themes/shared/tabs.inc.css#L841
applyEffect(".tabbrowser-tab", {
  clickEffect: true,
  lightColor: "color-mix(in srgb, currentColor 11%, transparent)",
  gradientSize: 150
});

// Redefine Handler
// https://github.com/mozilla/gecko-dev/blob/6b099d836c882bc155d2ef285e0ad0ab9f5038f6/browser/base/content/tabbrowser-tabs.js#L1945
document.querySelector("#tabbrowser-tabs")._handleNewTab = (tab) => {
  applyEffect(".tabbrowser-tab", {
    clickEffect: true,
    lightColor: "color-mix(in srgb, currentColor 11%, transparent)",
    gradientSize: 150
  });

  if (tab.container != this) {
    return;
  }
  console.log("newtab");
  tab._fullyOpen = true;
  gBrowser.tabAnimationsInProgress--;

  this._updateCloseButtons();

  if (tab.getAttribute("selected") == "true") {
    this._handleTabSelect();
  } else if (!tab.hasAttribute("skipbackgroundnotify")) {
    this._notifyBackgroundTab(tab);
  }

  // XXXmano: this is a temporary workaround for bug 345399
  // We need to manually update the scroll buttons disabled state
  // if a tab was inserted to the overflow area or removed from it
  // without any scrolling and when the tabbar has already
  // overflowed.
  this.arrowScrollbox._updateScrollButtonsDisabledState();

  // If this browser isn't lazy (indicating it's probably created by
  // session restore), preload the next about:newtab if we don't
  // already have a preloaded browser.
  if (tab.linkedPanel) {
    NewTabPagePreloading.maybeCreatePreloadedBrowser(window);
  }

  if (UserInteraction.running("browser.tabs.opening", window)) {
    UserInteraction.finish("browser.tabs.opening", window);
  };
}
