import Controller from "@ember/controller";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

const POSITIONS = [
  "below-site-header",
  "discovery-list-container-top",
  "topic-list-bottom",
  "topic-above-post-stream",
  "post-stream-bottom",
  "before-sidebar-sections",
];

const STYLES = ["classic", "dark", "minimal", "cards"];
const LANGUAGES = ["auto", "en", "es", "pt"];

const SETTINGS_I18N = {
  en: {
    title: "Settings",
    intro: "Configure the Load Foundry crypto ticker.",
    enabled: "Enable ticker",
    position: "Position",
    style: "Style",
    language: "Language",
    top_count: "Top coins count (when none selected)",
    save: "Save",
    saving: "Saving…",
    saved: "Saved!",
    positions: {
      "below-site-header": "Below the header",
      "discovery-list-container-top": "Above the topic list",
      "topic-list-bottom": "Below the topic list",
      "topic-above-post-stream": "Top of the topic",
      "post-stream-bottom": "End of the topic",
      "before-sidebar-sections": "Left sidebar",
    },
    styles: {
      classic: "Classic (scrolling strip)",
      dark: "Dark (scrolling strip)",
      minimal: "Minimal (flat, wraps)",
      cards: "Cards (static grid)",
    },
    languages: {
      auto: "Automatic (user's language)",
      en: "English",
      es: "Español",
      pt: "Português",
    },
  },
  es: {
    title: "Ajustes",
    intro: "Configura la barra de precios de Load Foundry.",
    enabled: "Activar el ticker",
    position: "Posición",
    style: "Estilo",
    language: "Idioma",
    top_count: "Número de monedas (top, si no eliges ninguna)",
    save: "Guardar",
    saving: "Guardando…",
    saved: "¡Guardado!",
    positions: {
      "below-site-header": "Debajo de la cabecera",
      "discovery-list-container-top": "Arriba de la lista de temas",
      "topic-list-bottom": "Debajo de la lista de temas",
      "topic-above-post-stream": "Arriba del tema",
      "post-stream-bottom": "Al final del tema",
      "before-sidebar-sections": "Barra lateral izquierda",
    },
    styles: {
      classic: "Clásico (franja deslizante)",
      dark: "Oscuro (franja deslizante)",
      minimal: "Minimalista (plano, se ajusta)",
      cards: "Tarjetas (cuadrícula estática)",
    },
    languages: {
      auto: "Automático (idioma del usuario)",
      en: "English",
      es: "Español",
      pt: "Português",
    },
  },
  pt: {
    title: "Ajustes",
    intro: "Configure o ticker da Load Foundry.",
    enabled: "Ativar o ticker",
    position: "Posição",
    style: "Estilo",
    language: "Idioma",
    top_count: "Número de moedas (top, se nenhuma selecionada)",
    save: "Salvar",
    saving: "Salvando…",
    saved: "Salvo!",
    positions: {
      "below-site-header": "Abaixo do cabeçalho",
      "discovery-list-container-top": "Acima da lista de tópicos",
      "topic-list-bottom": "Abaixo da lista de tópicos",
      "topic-above-post-stream": "Topo do tópico",
      "post-stream-bottom": "Fim do tópico",
      "before-sidebar-sections": "Barra lateral esquerda",
    },
    styles: {
      classic: "Clássico (faixa deslizante)",
      dark: "Escuro (faixa deslizante)",
      minimal: "Minimalista (plano, ajustável)",
      cards: "Cartões (grade estática)",
    },
    languages: {
      auto: "Automático (idioma do usuário)",
      en: "English",
      es: "Español",
      pt: "Português",
    },
  },
};

function interfaceLocale() {
  const html = (document.documentElement.getAttribute("lang") || "en")
    .slice(0, 2)
    .toLowerCase();
  return SETTINGS_I18N[html] ? html : "en";
}

export default class CryptoTickerSettingsController extends Controller {
  @tracked enabled = true;
  @tracked position = "below-site-header";
  @tracked style = "classic";
  @tracked language = "auto";
  @tracked topCount = 10;
  @tracked saving = false;
  @tracked saved = false;

  get locale() {
    if (this.language && this.language !== "auto" && SETTINGS_I18N[this.language]) {
      return this.language;
    }
    return interfaceLocale();
  }

  get strings() {
    return SETTINGS_I18N[this.locale] || SETTINGS_I18N.en;
  }

  get positionOptions() {
    return POSITIONS.map((value) => ({
      value,
      label: this.strings.positions[value] || value,
    }));
  }

  get styleOptions() {
    return STYLES.map((value) => ({
      value,
      label: this.strings.styles[value] || value,
    }));
  }

  get languageOptions() {
    return LANGUAGES.map((value) => ({
      value,
      label: this.strings.languages[value] || value,
    }));
  }

  @action
  updateEnabled(event) {
    this.enabled = event.target.checked;
    this.saved = false;
  }

  @action
  updatePosition(event) {
    this.position = event.target.value;
    this.saved = false;
  }

  @action
  updateStyle(event) {
    this.style = event.target.value;
    this.saved = false;
  }

  @action
  updateLanguage(event) {
    this.language = event.target.value;
    this.saved = false;
  }

  @action
  updateTopCount(event) {
    this.topCount = event.target.value;
    this.saved = false;
  }

  @action
  async save() {
    this.saving = true;
    try {
      await ajax("/admin/plugins/crypto-ticker/config", {
        type: "PUT",
        data: {
          enabled: this.enabled,
          position: this.position,
          style: this.style,
          language: this.language,
          top_count: this.topCount,
        },
      });
      this.saved = true;
    } catch (error) {
      popupAjaxError(error);
    } finally {
      this.saving = false;
    }
  }
}
