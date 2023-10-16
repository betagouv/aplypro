# frozen_string_literal: true

# the DSFRFormBuilder provides a form builder that wraps some of the
# logic of the DSFR. It's rather hacky at the moment but the goal is
# to evolve it into something that can be cleaned up, extracted and
# shared with the rest of the community.
#
# It takes inspiration from the GOV.UK Form Builder API
# (https://govuk-form-builder.netlify.app/form-elements/text-input/)

# rubocop:disable Metrics/ClassLength, it's a WIP
class DsfrFormBuilder < ActionView::Helpers::FormBuilder
  include TranslationHelper

  # Builds a DSFR text field with a label, an optional hint and a text
  # field with autocompletion disabled by default. A hash of options
  # can be passed to customise the field:
  #
  #   * code: whether the input should use extra spacing and slashed zeros[1].
  #
  # [1]: https://design-system.service.gov.uk/components/text-input/#codes-and-sequences
  def dsfr_text_field(attribute, opts = {})
    dsfr_input_group(attribute, opts) do
      @template.safe_join(
        [
          label_with_hint(attribute),
          text_field(attribute, class: input_classes(opts), autocomplete: "off", **opts.except(:class)),
          error_message(attribute)
        ]
      )
    end
  end

  def dsfr_check_box(attribute, opts = {})
    dsfr_input_group(attribute, opts) do
      @template.content_tag(:div, class: "fr-checkbox-group") do
        @template.safe_join(
          [
            check_box(attribute, class: input_classes(opts), **opts),
            label_with_hint(attribute)
          ]
        )
      end
    end
  end

  def dsfr_date_field(attribute, opts = {})
    dsfr_input_group(attribute, opts) do
      @template.safe_join(
        [
          label_with_hint(attribute),
          date_field(attribute, class: input_classes(opts), **opts),
          error_message(attribute)
        ]
      )
    end
  end

  def dsfr_input_group(attribute, opts, &block)
    @template.content_tag(:div, class: input_group_classes(attribute, opts)) do
      yield(block)
    end
  end

  def dsfr_radio_buttons(attribute, choices, opts = {})
    @template.content_tag(:fieldset, class: "fr-fieldset") do
      @template.safe_join(
        [
          @template.content_tag(
            :legend,
            @object.class.human_attribute_name(attribute).concat(hint(attribute)).html_safe, # rubocop:disable Rails/OutputSafety
            class: "fr-fieldset__legend--regular fr-fieldset__legend"
          ),
          choices.map { |choice| dsfr_radio_option(attribute, choice, opts) }
        ]
      )
    end
  end

  def dsfr_radio_option(attribute, value, opts = {})
    @template.content_tag(:div, class: "fr-fieldset__element") do
      @template.content_tag(:div, class: "fr-radio-group") do
        @template.safe_join(
          [
            radio_button(attribute, value, **opts),
            label([attribute, value].join("_").to_sym)
          ]
        )
      end
    end
  end

  # FIXME: merge HTML classes at some point
  def dsfr_submit(label, opts = {})
    submit(label, opts.merge(class: "fr-btn"))
  end

  def dsfr_error_summary
    return "" if @object.errors.none?

    @template.content_tag(:div, class: "fr-alert fr-alert--error fr-my-3w") do
      @template.safe_join(
        [
          @template.content_tag(:h2, class: "fr-alert__title") { save_label(@object) },
          @template.content_tag(:p) do
            @template.content_tag(:ul) do
              @template.safe_join(
                @object.errors.full_messages.map do |message|
                  @template.content_tag(:li, message)
                end
              )
            end
          end
        ]
      )
    end
  end

  private

  def label_with_hint(attribute)
    text = @object.class.human_attribute_name(attribute)

    label(attribute, class: "fr-label") do
      @template.safe_join(
        [
          text,
          hint(attribute)
        ]
      )
    end
  end

  def hint(attribute)
    text = hint_for(@object, attribute)

    return "" if text.blank?

    @template.content_tag(:span, class: "fr-hint-text") do
      text
    end
  end

  def error_message(attr)
    return if @object.errors[attr].none?

    @template.content_tag(:p, class: "fr-error-text") do
      @object.errors.full_messages_for(attr).join(", ")
    end
  end

  def join_classes(arr)
    arr.compact.join(" ")
  end

  def input_classes(opts)
    join_classes(
      [
        "fr-input",
        opts[:code] && "fr-input--code",
        input_width_class(opts)
      ]
    )
  end

  def input_width_class(opts)
    return "" if opts[:width].blank?

    opts[:width].split.map { |spec| "fr-col-#{spec}" }.join(" ")
  end

  def input_group_classes(attribute, opts)
    join_classes(
      [
        "fr-input-group",
        @object.errors[attribute].any? ? "fr-input-group--error" : nil,
        opts[:class]
      ]
    )
  end
end
# rubocop:enable Metrics/ClassLength
