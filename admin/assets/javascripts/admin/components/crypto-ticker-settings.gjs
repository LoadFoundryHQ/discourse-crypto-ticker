import { on } from "@ember/modifier";

export default <template>
  <div class="crypto-ticker-settings">
    <h2 class="crypto-ticker-settings__title">{{@controller.strings.title}}</h2>
    <p class="crypto-ticker-settings__intro">{{@controller.strings.intro}}</p>

    <div class="crypto-ticker-settings__row">
      <label class="crypto-ticker-settings__label" for="ct-enabled">
        {{@controller.strings.enabled}}
      </label>
      <input
        id="ct-enabled"
        type="checkbox"
        checked={{@controller.enabled}}
        {{on "change" @controller.updateEnabled}}
      />
    </div>

    <div class="crypto-ticker-settings__row">
      <label class="crypto-ticker-settings__label" for="ct-language">
        {{@controller.strings.language}}
      </label>
      <select
        id="ct-language"
        value={{@controller.language}}
        {{on "change" @controller.updateLanguage}}
      >
        {{#each @controller.languageOptions as |opt|}}
          <option value={{opt.value}}>{{opt.label}}</option>
        {{/each}}
      </select>
    </div>

    <div class="crypto-ticker-settings__row">
      <label class="crypto-ticker-settings__label" for="ct-position">
        {{@controller.strings.position}}
      </label>
      <select
        id="ct-position"
        value={{@controller.position}}
        {{on "change" @controller.updatePosition}}
      >
        {{#each @controller.positionOptions as |opt|}}
          <option value={{opt.value}}>{{opt.label}}</option>
        {{/each}}
      </select>
    </div>

    <div class="crypto-ticker-settings__row">
      <label class="crypto-ticker-settings__label" for="ct-style">
        {{@controller.strings.style}}
      </label>
      <select
        id="ct-style"
        value={{@controller.style}}
        {{on "change" @controller.updateStyle}}
      >
        {{#each @controller.styleOptions as |opt|}}
          <option value={{opt.value}}>{{opt.label}}</option>
        {{/each}}
      </select>
    </div>

    <div class="crypto-ticker-settings__actions">
      <button
        type="button"
        class="btn btn-primary"
        disabled={{@controller.saving}}
        {{on "click" @controller.save}}
      >
        {{#if @controller.saving}}
          {{@controller.strings.saving}}
        {{else}}
          {{@controller.strings.save}}
        {{/if}}
      </button>
      {{#if @controller.saved}}
        <span class="crypto-ticker-settings__saved">
          {{@controller.strings.saved}}
        </span>
      {{/if}}
    </div>
  </div>
</template>;
