module MsForm
  module ActionViewExtensions
    # This modules create simple form wrappers around default form_for,
    # fields_for and remote_form_for.
    #
    # Example:
    #
    #   ms_form_for @user do |f|
    #     f.input :name, :hint => 'My hint'
    #   end
    #
    module FormHelper
      # based on what is done in formtastic
      # http://github.com/justinfrench/formtastic/blob/master/lib/formtastic.rb#L1706
      @@default_field_error_proc = nil

      # Override the default ActiveRecordHelper behaviour of wrapping the input.
      # This gets taken care of semantically by adding an error class to the wrapper tag
      # containing the input.
      #
      FIELD_ERROR_PROC = proc do |html_tag, instance_tag|
        html_tag
      end

      def with_custom_field_error_proc(&block)
        @@default_field_error_proc = ::ActionView::Base.field_error_proc
        ::ActionView::Base.field_error_proc = FIELD_ERROR_PROC
        result = yield
        ::ActionView::Base.field_error_proc = @@default_field_error_proc
        result
      end

      [:form_tag, :form_for, :fields_for, :remote_form_for].each do |helper|
        class_eval <<-METHOD, __FILE__, __LINE__
          def ms_#{helper}(record_or_name_or_array, *args, &block)
            options = args.extract_options!
            options[:builder] = MsForm::FormBuilder
            css_class = case record_or_name_or_array
              when String, Symbol then record_or_name_or_array.to_s
              when Array then dom_class(record_or_name_or_array.last)
              else dom_class(record_or_name_or_array)
            end
            options[:html] ||= {}
            options[:html][:class] = "ms_form \#{css_class} \#{options[:html][:class]}".strip

            with_custom_field_error_proc do
              #{helper}(record_or_name_or_array, *(args << options), &block)
            end
          end
        METHOD
      end

      def ms_display_form(legend = nil, *args, &block)
        options = args.extract_options!
        content = capture(&block)

        "<div class=\"ms_display_form\">".html_safe + content + "</div>".html_safe
      end

      def ms_display(label = '', value = '', options = {})
        fieldstyle = options.delete(:fieldstyle) || ""
        fieldstyle += " width: #{options.delete(:fieldwidth) || "100%"};"
        fieldextra = options.delete(:fieldextra) || ""
        "<div class=\"ms_field\", style=\"#{fieldstyle}\"><div class=\"ms_field_label\"><span class=\"ms_label\">#{fieldextra}#{label}</span></div><span class=\"ms_field_content\">#{value}</span></div>".html_safe
      end

      def ms_wrap(label = '', *args, &block)
        options = args.extract_options!
        content = capture(&block)

        fieldstyle = options.delete(:fieldstyle) || ""
        fieldstyle += " width: #{options.delete(:fieldwidth) || "100%"};"
        fieldextra = options.delete(:fieldextra) || ""

        forvalue = options.delete(:for) || ""
        text = options.delete(:label) || "#{label.to_s.titleize}"
        hint = options.delete(:hint) || ""
        text = text + "<span class=\"ms_hint\">#{hint}</span>" unless hint.blank?

        "<div class=\"ms_field\", style=\"#{fieldstyle}\"><div class=\"ms_field_label\">#{fieldextra}<label class=\"ms_label\" for=\"#{forvalue}\">#{text}</label></div>".html_safe + content + "</div>".html_safe
      end

    end
  end
end

ActionView::Base.send :include, MsForm::ActionViewExtensions::FormHelper
