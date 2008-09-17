class FudgeFormBuilder < ActionView::Helpers::FormBuilder
  include FudgeFormHelper
  
  def field_settings(method, options = {}, tag_value = nil)
    field_name = "#{@object_name}_#{method.to_s}"
    default_label = tag_value.nil? ? "#{method.to_s.humanize.titleize}" : "#{tag_value.to_s.humanize.titleize}"
    label = options[:label] ? options.delete(:label) : default_label
    options[:class] ||= ""
    options[:class] += options[:required] ? "required" : ""
    label += '<em>*</em>' if options[:required]
    options.delete(:required)
    [field_name, label, options]
  end
  
  def text_field(method, options = {})
    add_class_name(options, 'text')
    field_name, label, options = field_settings(method, options)
    wrapping("text", field_name, label, super, options)
  end
  
  def file_field(method, options = {})
    add_class_name(options, 'file')
    field_name, label, options = field_settings(method, options)
    wrapping("file", field_name, label, super, options)
  end
  
  def datetime_select(method, options = {}, html_options = {})
    options[:order] = [:day, :month, :year]
    add_class_name(html_options, 'select')
    field_name, label, options = field_settings(method, options)
    wrapping("datetime", field_name, label, super, options)
  end
 
  def date_select(method, options = {}, html_options = {})
    options[:order] = [:day, :month, :year]
    add_class_name(html_options, 'select')
    field_name, label, options = field_settings(method, options)
    wrapping("date", field_name, label, super, options)
  end
  
  def radio_button(method, tag_value, options = {})
    add_class_name(options, 'radio')
    field_name, label, options = field_settings(method, options)
    wrapping("radio", field_name, label, super, options)
  end
    
  def check_box(method, options = {}, checked_value = "1", unchecked_value = "0")
    add_class_name(options, 'checkbox')
    field_name, label, options = field_settings(method, options)
    wrapping("check-box", field_name, label, super, options)
  end
  
  def select(method, choices, options = {}, html_options = {})
    add_class_name(html_options, 'select')
    field_name, label, options = field_settings(method, options)
    wrapping("select", field_name, label, super, options)
  end
  
  def password_field(method, options = {})
    add_class_name(options, 'password')
    field_name, label, options = field_settings(method, options)
    wrapping("password", field_name, label, super, options)
  end
 
  def text_area(method, options = {})
    options[:rows] = 5
    add_class_name(options, 'textarea')
    field_name, label, options = field_settings(method, options)
    wrapping("textarea", field_name, label, super, options)
  end
  
  def radio_button_group(method, values, options = {})
    add_class_name(options, 'radio')
    selections = []
    values.each do |value|
      if value.is_a?(Array)
        tag_value = value.last
        value_text = value.first
      else
        tag_value = value
        value_text = value
      end
      radio_button = @template.radio_button(@object_name, method, tag_value, options.merge(:object => @object))
      selections << boolean_field_wrapper(radio_button, "#{@object_name}_#{method.to_s}", tag_value, value_text)
    end
    selections
    field_name, label, options = field_settings(method, options)
    semantic_group("radio", field_name, label, selections, options)
  end
  
  def check_box_group(method, values, options = {})
    add_class_name(options, 'checkbox')
    selections = []
    values.each do |value|
      if value.is_a?(Array)
        checked_value = value.last.to_i
        value_text = value.first
      else
        checked_value = 1
        value_text = value
      end
      check_box = check_box = @template.check_box_tag("#{@object_name}[#{method.to_s}][]", checked_value, @object.send(method).include?(checked_value), options.merge(:object => @object))
      selections << boolean_field_wrapper(check_box, "#{@object_name}_#{method.to_s}", checked_value, value_text)
    end
    field_name, label, options = field_settings(method, options)
    semantic_group("check-box", field_name, label, selections, options)
  end
      
  def submit(method, options = {})
    add_class_name(options, 'submit')
    %Q{<div class="buttons">#{super}</div>}
  end
  
  def submit_and_back(submit_name, options = {})
    add_class_name(options, 'submit')
    submit_button = @template.submit_tag(submit_name, options)
    back_link = @template.link_to('Back', :back, :class => 'back')
    %Q{<div class="buttons">#{submit_button} #{back_link}</div>}
  end
  
  protected
  
  def add_class_name(options, class_name)
    classes = (options[:class]) ? options[:class].split(' ') : []
    options[:class] = (classes << class_name).join(' ')
  end
  
end