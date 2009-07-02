module FudgeFormHelper
      
  def wrapping(type, field_name, label, field, options = {})
    help = %Q{<small>#{options[:help]}</small>} if options[:help]
    to_return = []
    to_return << %Q{<li class="m-form_element">}
    to_return << options[:before_html] if options[:before_html]
    to_return << %Q{<label for="#{options[:id] || field_name}" class="m-form_label">#{label}</label>} unless ["radio","check", "submit"].include?(type)
    to_return << field
    to_return << %Q{<label for="#{options[:id] || field_name}" class="m-form_label">#{label}</label>} if ["radio","check"].include?(type)
    to_return << help
    to_return << options[:after_html] if options[:after_html]
    to_return << %Q{</li>}
  end
 
  def semantic_group(type, field_name, label, fields, options = {})
    help = %Q{<span class="help">#{options[:help]}</span>} if options[:help]
    to_return = []
    to_return << %Q{<li><fieldset class="m-form_fieldset">}
    to_return << %Q{<legend class="m-form_legend">#{label}</legend>}
    to_return << %Q{<ol class="m-form_list">}
    to_return << fields.join("\n")
    to_return << %Q{</ol></fieldset></li>}
  end
 
  def boolean_field_wrapper(input, name, value, text, help = nil)
    field = []
    field << %Q{<li><label>#{input} #{text}</label>}
    field << %Q{<small>#{help}</small>} if help
    field << %Q{</li>}
    field
  end
  
  def field_set(legend = nil, &block)
    content = @template.capture(&block)
    @template.concat(@template.tag(:fieldset, { :class => 'm-form_fieldset' }, true))
    @template.concat(@template.content_tag(:legend, legend, :class => 'm-form_legend')) unless legend.blank?
    @template.concat(@template.tag(:ol, { :class => 'm-form_list' }, true))
    @template.concat(content)
    @template.concat("</ol></fieldset>")
  end
 
end
