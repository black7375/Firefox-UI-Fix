// == UserScript ==
// @include chrome : //browser/content/places/places.xhtml
// == / UserScript ==

// -- WARNNING!!!!! ------------------------------------------------------------
// It's experimental
// If a problem occurs, we do not support it.
// However, we do receive a contribution. Create an issue and then PR.

// Todo:
// - Name Space

// Done:
// - Refactoring: Modulize, Reduce offset
// - Slim: Remove leaving only the required code
// - Single Element: Add a function that applies only to one element
// - Using Browser API at Newtab: Avoid Redefine (_handleNewTab)
// - Load Optimize: Lazy initialization, asynchronous application

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

// TS Version
// https://gist.github.com/black7375/381950352a76f0336f2abe9eb6b1fff1

// ** Postion ******************************************************************
function getOffset(element) {
  const bounding = element.getBoundingClientRect();

  return ({
    top: bounding.top,
    left: bounding.left
  });
}

// with Mouse
function getXY(element, e) {
  const offset = getOffset(element);
  const x = e.pageX - offset.left - window.scrollX;
  const y = e.pageY - offset.top  - window.scrollY;

  return [x, y];
}

// ** CSS Effect ***************************************************************
function lightHoverEffect(gradientSize, x, y, lightColor) {
  return `radial-gradient(circle ${gradientSize}px at ${x}px ${y}px, ${lightColor}, rgba(255,255,255,0))`;
}

function lightClickEffect(gradientSize, x, y, lightColor) {
  return `${lightHoverEffect(gradientSize, x, y, lightColor)}, radial-gradient(circle ${70}px at ${x}px ${y}px, rgba(255,255,255,0), ${lightColor}, rgba(255,255,255,0), rgba(255,255,255,0))`;
}

// ** Basic Draw Effect ********************************************************
function drawEffect(element, x, y, lightColor, gradientSize, cssLightEffect = null) {
  const lightBg = cssLightEffect === null
        ? lightHoverEffect(gradientSize, x, y, lightColor)
        : cssLightEffect;
  element.style.backgroundImage = lightBg;
}

// with Mouse
function drawHoverEffect(element, lightColor, gradientSize, e) {
  const [x, y] = getXY(element, e);
  drawEffect(element, x, y, lightColor, gradientSize);
}

function drawClickEffect(element, lightColor, gradientSize, e) {
  const [x, y] = getXY(element, e);

  const cssLightEffect = lightClickEffect(gradientSize, x, y, lightColor);
  drawEffect(element, x, y, lightColor, gradientSize, cssLightEffect);
}

// ** SideEffect Draw Effect ***************************************************
function clearEffect(resource, is_pressed) {
  is_pressed[0] = false;
  resource.el.style.backgroundImage = resource.oriBg;
}

// Wrapper
function enableBackgroundEffects(resource, lightColor, gradientSize, clickEffect, is_pressed) {
  const element = resource.el;
  element.addEventListener("mousemove", (e) => {
    if (clickEffect && is_pressed[0]) {
      drawClickEffect(element, lightColor, gradientSize, e);
    }
    else {
      drawHoverEffect(element, lightColor, gradientSize, e);
    }
  });

  element.addEventListener("mouseleave", (e) => {
    clearEffect(resource, is_pressed);
  });
}

function enableClickEffects(resource, lightColor, gradientSize, is_pressed) {
  const element = resource.el;
  element.addEventListener("mousedown", (e) => {
    is_pressed[0] = true;
    drawClickEffect(element, lightColor, gradientSize, e);
  });

  element.addEventListener("mouseup", (e) => {
    is_pressed[0] = false;
    drawHoverEffect(element, lightColor, gradientSize, e);
  });
}

// ** Element Processing *******************************************************
function preProcessElement(element) {
  return ({
    oriBg: getComputedStyle(element).backgroundImage,
    el: element
  });
}

function preProcessElements(elements) {
  const ressources = [];
  const elementsL = elements.length;
  for (let i = 0; i < elementsL; i++) {
    const element = elements[i];
    ressources.push(preProcessElement(element));
  }

  return ressources;
}

// ** ApplyEffect **************************************************************
// Option
function applyEffectOption(userOptions) {
  const defaultOptions = {
    lightColor: "rgba(255,255,255,0.25)",
    gradientSize: 150,
    clickEffect: false,
  };

  return Object.assign(defaultOptions, userOptions);
}

function applyEffectInit(userOptions) {
  const is_pressed = [false];
  const options = applyEffectOption(userOptions);

  return [is_pressed, options];
}

// Apply Effect Core
function applyElementEffect(resource, options, is_pressed) {
  enableBackgroundEffects(resource, options.lightColor, options.gradientSize, options.clearEffect, is_pressed);
  if (options.clickEffect) {
    enableClickEffects(resource, options.lightColor, options.gradientSize, is_pressed);
  }
}
function applyElementsEffect(resources, options, is_pressed) {
  const resourceL = resources.length;
  for (let i = 0; i < resourceL; i++) {
    const resource = resources[i];
    applyElementEffect(resource, options, is_pressed);
  }
}

// Apply Effect
function applySingleEffect(element, userOptions = {}) {
  const [is_pressed, options] = applyEffectInit(userOptions);
  const resource = preProcessElement(element);

  applyElementEffect(resource, options, is_pressed);
}
function applyEffect(elements, userOptions = {}) {
  const [is_pressed, options] = applyEffectInit(userOptions);
  const resources = preProcessElements(elements);

    applyElementsEffect(resources, options, is_pressed);
}


// -- Hover Effect -------------------------------------------------------------
const hoverEffectOption = {
  clickEffect: true,
  lightColor: "color-mix(in srgb, currentColor 11%, transparent)",
  gradientSize: 150
}

function tabHoverEffect() {
  return new Promise(() => {
    // Init Tab
    // https://github.com/mozilla/gecko-dev/blob/1465ef37f27584b00b70587d18a3c2f96c9dae78/browser/themes/shared/tabs.inc.css#L841
    applyEffect(gBrowser.tabs, hoverEffectOption);

    // New Tab
    gBrowser.tabContainer.addEventListener("TabOpen", (e) => {
      applySingleEffect(e.target, hoverEffectOption);
    });
  });
}

function tabHoverEffectInit() {
  // wait for the chrome window to finish starting up. we apply the effect to tabs by modifying class methods of objects like gTabsPanel.allTabsPanel and gBrowser.tabContainer. those modules must load before we can modify them. when startup finishes it sets delayedStartupFinished to true. so if it's already finished by the time this script executes we can just init() immediately.
  if (gBrowserInit.delayedStartupFinished) {
     tabHoverEffect();
  }
  else {
      // otherwise, we need to hook up an observer so we can wait and be informed when startup finishes.
      let delayedListener = (subject, topic) => {
      // make sure we're not responding to notifications about other windows, since a different instance of this script executes separately inside each chrome window.
      if (topic == "browser-delayed-startup-finished" && subject == window) {
        Services.obs.removeObserver(delayedListener, topic); // remove the observer once we're done
        tabHoverEffect(); // start everything
      }
    };

    Services.obs.addObserver(delayedListener, "browser-delayed-startup-finished"); // when the main chrome modules are initialized, the "browser-delayed-startup-finished" notification is sent to observers. so by adding an observer we'll know when this happens and can respond to it.
  }
}
tabHoverEffectInit();
