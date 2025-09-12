/**
 * Internationalization (i18n) System
 * Handles language switching between English and Vietnamese
 */
class I18n {
  constructor() {
    this.currentLanguage = localStorage.getItem("language") || "en";
    this.translations = {};
    this.fallbackLanguage = "en";

    this.init();
  }

  async init() {
    await this.loadTranslations();
    this.applyTranslations();
    this.bindEvents();
    this.updateLanguageSelector();
  }

  //   async loadTranslations() {
  //     try {
  //       const pageName = this.getPageName();
  //       console.log(pageName);

  //       // Try to load page-specific translations first
  //       try {
  //         const [enResponse, viResponse] = await Promise.all([
  //           fetch(`assets/js/lang/pages/${pageName}-en.json`),
  //           fetch(`assets/js/lang/pages/${pageName}-vi.json`),
  //         ]);

  //         if (enResponse.ok && viResponse.ok) {
  //           this.translations.en = await enResponse.json();
  //           this.translations.vi = await viResponse.json();
  //           console.log(`Loaded page-specific translations for: ${pageName}`);
  //           return;
  //         }
  //       } catch (pageError) {
  //         console.log(
  //           `Page-specific translations not found for ${pageName}, using main translations`
  //         );
  //       }

  //       // Fallback to main translation files
  //       const enResponse = await fetch("assets/js/lang/en.json");
  //       this.translations.en = await enResponse.json();

  //       const viResponse = await fetch("assets/js/lang/vi.json");
  //       this.translations.vi = await viResponse.json();

  //       console.log("Main translations loaded successfully");
  //     } catch (error) {
  //       console.error("Error loading translations:", error);
  //     }
  //   }

  async loadTranslations() {
    try {
      const pageName = this.getPageName();
      console.log(`Page name: ${pageName}`);

      // Try to load page-specific translations first
      try {
        // Use absolute paths from root
        const enPath = `assets/js/lang/pages/${pageName}-en.json`;
        const viPath = `assets/js/lang/pages/${pageName}-vi.json`;

        console.log(`Attempting to load: ${enPath}`);
        console.log(`Attempting to load: ${viPath}`);

        const [enResponse, viResponse] = await Promise.all([
          fetch(enPath),
          fetch(viPath),
        ]);

        if (enResponse.ok && viResponse.ok) {
          this.translations.en = await enResponse.json();
          this.translations.vi = await viResponse.json();
          console.log(`✅ Loaded page-specific translations for: ${pageName}`);
          return;
        }
      } catch (pageError) {
        console.log(
          `Page-specific translations not found for ${pageName}, using main translations`
        );
      }

      // Fallback to main translation files (also use absolute paths)
      const enResponse = await fetch("/assets/js/lang/en.json");
      this.translations.en = await enResponse.json();

      const viResponse = await fetch("/assets/js/lang/vi.json");
      this.translations.vi = await viResponse.json();

      console.log("✅ Main translations loaded successfully");
    } catch (error) {
      console.error("❌ Error loading translations:", error);
    }
  }

  getPageName() {
    // Get current page name from URL
    const path = window.location.pathname;
    const fileName = path.split("/").pop();
    return fileName.replace(".html", "") || "index";
  }

  t(key, params = {}) {
    const keys = key.split(".");
    let translation = this.translations[this.currentLanguage];

    // Navigate through nested keys
    for (const k of keys) {
      if (translation && translation[k]) {
        translation = translation[k];
      } else {
        // Fallback to default language
        translation = this.translations[this.fallbackLanguage];
        for (const k of keys) {
          if (translation && translation[k]) {
            translation = translation[k];
          } else {
            return key; // Return key if translation not found
          }
        }
        break;
      }
    }

    // Replace parameters in translation
    if (typeof translation === "string") {
      Object.keys(params).forEach((param) => {
        translation = translation.replace(`{{${param}}}`, params[param]);
      });
    }

    return translation || key;
  }

  async setLanguage(lang) {
    if (this.translations[lang]) {
      this.currentLanguage = lang;
      localStorage.setItem("language", lang);
      this.applyTranslations();
      this.updateLanguageSelector();

      // Dispatch language change event
      window.dispatchEvent(
        new CustomEvent("languageChanged", {
          detail: { language: lang },
        })
      );
    }
  }

  applyTranslations() {
    // Find all elements with data-i18n attribute
    const elements = document.querySelectorAll("[data-i18n]");

    elements.forEach((element) => {
      const key = element.getAttribute("data-i18n");
      const translation = this.t(key);

      // Check if element has data-i18n-attr for attribute translation
      const attrKey = element.getAttribute("data-i18n-attr");
      if (attrKey) {
        const [attr, translationKey] = attrKey.split(":");
        element.setAttribute(attr, this.t(translationKey));
      } else {
        // Default behavior - replace text content
        if (element.tagName === "INPUT" && element.type === "text") {
          element.placeholder = translation;
        } else {
          element.textContent = translation;
        }
      }
    });
  }

  updateLanguageSelector() {
    // Update language flag and text in header
    const langFlag = document.querySelector(".flag-nav img");
    const langText = document.querySelector(".flag-nav span");

    if (this.currentLanguage === "vi") {
      if (langFlag) langFlag.src = "assets/img/flags/vietnam.png";
      if (langText) langText.textContent = "Tiếng Việt";
    } else {
      if (langFlag) langFlag.src = "assets/img/flags/us.png";
      if (langText) langText.textContent = "English";
    }
  }

  bindEvents() {
    // Bind click events to language switcher
    document.addEventListener("click", (e) => {
      // Check if clicked element is a language switcher
      if (e.target.closest(".dropdown-item[data-lang]")) {
        e.preventDefault();
        const langElement = e.target.closest(".dropdown-item[data-lang]");
        const lang = langElement.getAttribute("data-lang");
        this.setLanguage(lang);
      }
    });
  }

  getCurrentLanguage() {
    return this.currentLanguage;
  }

  getAvailableLanguages() {
    return Object.keys(this.translations);
  }
}

// Initialize i18n when DOM is loaded
document.addEventListener("DOMContentLoaded", () => {
  window.i18n = new I18n();
});

// Export for module usage
if (typeof module !== "undefined" && module.exports) {
  module.exports = I18n;
}
