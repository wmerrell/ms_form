module TblForm
  class FormBuilder < ActionView::Helpers::FormBuilder

    include ActionView::Helpers::TagHelper

    # Creates a button:
    #
    #   form_for @user do |f|
    #     f.button :submit
    #   end
    #
    # It just acts as a proxy to method name given.
    #
    def button(type, *args, &block)
      if respond_to?(:"#{type}_button")
        send(:"#{type}_button", *args, &block)
      else
        send(type, *args, &block)
      end
    end

    # Generates a label
    #
    # If +options+ includes :for,
    # that is used as the :for of the label.  Otherwise,
    # "#{this form's object name}_#{method}" is used.
    #
    # If +options+ includes :label,
    # that value is used for the text of the label.  Otherwise,
    # "#{method titleized}: " is used.
    def label method, options = {}
      text = options.delete(:label) ||  "#{method.to_s.titleize}: "
      hint = options.delete(:hint) || ""
      text = text + " <span class=\"ms_hint\">#{hint}</span>" unless hint.blank?
      if options[:for]
        "<label class=\"ms_label\" for='#{options.delete(:for)}'>#{text}</label>"
      else
        #need to use InstanceTag to build the correct ID for :for
        ActionView::Helpers::InstanceTag.new(@object_name, method, self, @object).to_label_tag(text, {:class=>"ms_label"})
      end
    end

    def submit(value = "Submit", options = {})
      text = options.delete(:label) || value
      tag_str = tag( :input, { "type" => "submit", "name" => "commit", "value" => text }.update(options.stringify_keys) )
      output  = "<br /><div class=\"button_bar\">#{ tag_str }</div>".html_safe
    end

    def value(method, options = {})
      @object[method.to_s]
    end

    def display(method, options = {})
      options.to_options!
      front(method, options) + ("<span class=\"ms_field_content\">#{method.is_a?(String) ? method.to_s : @object[method.to_s]}</span>").html_safe + back(method, options)
    end

    def select method, choices, options = {}, html_options = {}
      options.to_options!
      front(method, options) + super + back(method, options)
    end

    def text_field method, options = {}
      options.to_options!
      naked = options.delete(:naked) || false
      if naked
        super
      else
        front(method, options) + super + back(method, options)
      end
    end

    def password_field method, options = {}
      options.to_options!
      front(method, options) + super + back(method, options)
    end

    def file_field method, options = {}
      options.to_options!
      front(method, options) + super + back(method, options)
    end

    def text_area method, options = {}
      options.to_options!
      front(method, options) + super + back(method, options)
    end

    def check_box method, options = {}
      options.to_options!
      front(method, options) + super + back(method, options)
    end

    def radio_button method, tag_value, options = {}
      options.to_options!
      fieldstyle = options.delete(:fieldstyle) || ""
      fieldstyle += " width: #{options.delete(:fieldwidth) || "100%"};"
      fieldextra = options.delete(:fieldextra) || ""
      front(method, options) + super + back(method, options)
    end

    def calendar_field method, options = {}
      options.to_options!
      expired = options.delete(:expired) || false
      if not expired; options.merge!(:class => 'calendar'); else; options.merge!(:disabled => true); end
      text_field method, options
    end

    def date_select method, options = {}
      options.to_options!
      front(method, options) + super + back(method, options)
    end

    def select method, choices, options = {}, html_options = {}
      options.to_options!
      html_options.to_options!
      front(method, options) + super + back(method, options)
    end

    def front method = '', options = {}
      fieldstyle = options.delete(:fieldstyle) || ""
      fieldstyle += " width: #{options.delete(:fieldwidth) || "100%"};"
      fieldextra = options.delete(:fieldextra) || ""
      "<tr class=\"tbl_field\", style=\"#{fieldstyle}\"><th class=\"tbl_field_label\">#{fieldextra}#{label(method, options)}</th><td>".html_safe
    end

    def back method = '', options = {}
      "</td></tr>".html_safe
    end
  end
end
