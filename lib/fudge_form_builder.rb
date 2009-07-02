class FudgeFormBuilder < ActionView::Helpers::FormBuilder
  include FudgeFormHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::FormOptionsHelper
  
  def field_settings(method, options = {}, tag_value = nil)
    sanitized_object_name = @object_name.to_s.gsub(/[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")
    field_name = "#{sanitized_object_name}_#{method.to_s}"
    default_label = tag_value.nil? ? "#{method.to_s.humanize.titleize}" : "#{tag_value.to_s.humanize.titleize}"
    label = options[:label] ? options.delete(:label) : default_label
    options[:class] ||= ""
    options[:class] += options[:required] ? "m-form_required" : ""
    options[:id] = "#{field_name}_#{@object.id}" if @object && !@object.new_record?
    label += '<em>*</em>' if options[:required]
    options.delete(:required)
    [field_name, label, options]
  end
  
  def text_field(method, options = {})
    add_class_name(options, 'm-form_text')
    field_name, label, options = field_settings(method, options)
    wrapping("text", field_name, label, super, options)
  end

  def hidden_field(method, options = {})
    field_name, label, options = field_settings(method, options)
    options.merge!(:id => "#{field_name}_#{@object.id}") if @object && !@object.new_record?
    super(method, options)
  end
  
  def file_field(method, options = {})
    add_class_name(options, 'm-form_file')
    field_name, label, options = field_settings(method, options)
    wrapping("file", field_name, label, super, options)
  end
  
  def datetime_select(method, options = {}, html_options = {})
    options[:order] = [:day, :month, :year]
    add_class_name(html_options, 'm-form_select')
    field_name, label, options = field_settings(method, options)
    wrapping("datetime", field_name, label, super, options)
  end
 
  def date_select(method, options = {}, html_options = {})
    #options[:order] = [:day, :month, :year]
    add_class_name(options, 'm-form_select')
    field_name, label, options = field_settings(method, options)
    elements = day_select(method, options, html_options) + month_select(method, options, html_options) + year_select(method, options, html_options)
    wrapping("date", field_name, label, elements, options)#super, options)
  end

  def year_select(method, options = {}, html_options = {})
    start_year = options.delete(:start_year) || 1970
    end_year = options.delete(:end_year) || 2030
    default = Date.today.year
    select_options = options_for_select(start_year..end_year, @object.send(method).year || default)
    field_name, label, options = field_settings(method, options)
    options[:id] += '_1i'
    sanitized_object_name = @object_name.to_s.gsub(/[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")
    select_tag("#{sanitized_object_name}[#{method.to_s}(1i)]", select_options, options)
  end

  def month_select(method, options = {}, html_options = {})
    default = 1
    select_options = options_for_select(
      [["January", 1], ["February", 2], ["March", 3], ["April", 4], ["May", 5], ["June", 6], ["July", 7], ["August", 8], ["September", 9], ["October", 10], ["November", 11], ["December", 12]],
      @object.send(method).month || default
    )
    field_name, label, options = field_settings(method, options)
    options[:id] += '_2i'
    sanitized_object_name = @object_name.to_s.gsub(/[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")
    select_tag("#{sanitized_object_name}[#{method.to_s}(2i)]", select_options, options)
  end

  def day_select(method, options = {}, html_options = {})
    default = 1
    select_options = options_for_select(0..31, @object.send(method).day || default)
    field_name, label, options = field_settings(method, options)
    options[:id] += '_3i'
    sanitized_object_name = @object_name.to_s.gsub(/[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")
    select_tag("#{sanitized_object_name}[#{method.to_s}(3i)]", select_options, options)
  end

  
  def radio_button(method, tag_value, options = {})
    add_class_name(options, 'm-form_radio')
    field_name, label, options = field_settings(method, options)
    wrapping("radio", field_name, label, super, options)
  end
    
  def check_box(method, options = {}, checked_value = "1", unchecked_value = "0")
    add_class_name(options, 'm-form_checkbox')
    field_name, label, options = field_settings(method, options)
    wrapping("check-box", field_name, label, super, options)
  end
  
  def select(method, choices, options = {}, html_options = {})
    add_class_name(html_options, 'm-form_select')
    field_name, label, options = field_settings(method, options)
    wrapping("select", field_name, label, super, options)
  end
  
  def password_field(method, options = {})
    add_class_name(options, 'm-form_password')
    field_name, label, options = field_settings(method, options)
    wrapping("password", field_name, label, super, options)
  end
 
  def text_area(method, options = {})
    options[:rows] = 5
    add_class_name(options, 'm-form_textarea')
    field_name, label, options = field_settings(method, options)
    wrapping("textarea", field_name, label, super, options)
  end
  
  def radio_button_group(method, values, options = {})
    add_class_name(options, 'm-form_radio')
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
    add_class_name(options, 'm-form_checkbox')
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
    add_class_name(options, 'm-form_submit')
    %Q{<li class="buttons">#{super}</li>}
  end
  
  def submit_and_back(submit_name, options = {})
    add_class_name(options, 'm-form_submit')
    submit_button = @template.submit_tag(submit_name, options)
    back_link = @template.link_to('Back', :back, :class => 'back')
    %Q{<li class="buttons">#{submit_button} #{back_link}</li>}
  end
  
  protected
  
  def add_class_name(options, class_name)
    classes = (options[:class]) ? options[:class].split(' ') : []
    options[:class] = (classes << class_name).join(' ')
  end
  
end
