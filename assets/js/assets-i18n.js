// JavaScript function to change language
function changeLanguage(lang) {
  if (typeof I18n !== "undefined") {
    const i18n = new I18n();
    i18n.changeLanguage(lang);
  }
}

// Update the i18n initialization script in assets.html
document.addEventListener("DOMContentLoaded", function () {
  const i18n = new I18n("assets");

  // Make changeLanguage function available globally
  window.changeLanguage = function (lang) {
    i18n.changeLanguage(lang);
  };
});
