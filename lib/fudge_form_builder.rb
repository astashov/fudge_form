class FudgeFormBuilder < ActionView::Helpers::FormBuilder
  include FudgeFormHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormTagHelper

  
  def field_settings(method, options = {}, tag_value = nil)
    field_name = "#{sanitized_object_name}_#{method.to_s}"
    default_label = tag_value.nil? ? "#{method.to_s.humanize.titleize}" : "#{tag_value.to_s.humanize.titleize}"
    label = options[:label] ? options.delete(:label) : default_label
    options[:class] ||= ""
    options[:class] += options[:required] ? "m-form_required" : ""
    # Customize id for uniqueness of many forms on one page
    # (by default, if you have many forms of the same model on one page, form elements of these
    # forms will have the same id, and page will be not valid (by XHTML specification).
    # This is fix for it.
    if @object && !@object.new_record?
      options[:id] = "#{field_name}_#{@object.id}" 
    else
      # Just assign some unique id if the record is new. Add 'f' letter to avoid collisions
      # with record's names
      @@id_counter ||= 0
      options[:id] = "#{field_name}_f#{@@id_counter}"
      @@id_counter += 1
    end
    label += '<em>*</em>' if options[:required]
    options.delete(:required)
    [field_name, label, options]
  end

  def sanitized_object_name
    @object_name.to_s.gsub(/[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")
  end
  
  def text_field(method, options = {})
    add_class_name(options, 'm-form_text')
    field_name, label, options = field_settings(method, options)
    wrapping("text", field_name, label, super, method, options)
  end

  def hidden_field(method, options = {})
    field_name, label, options = field_settings(method, options)
    options.merge!(:id => "#{field_name}_#{@object.id}") if @object && !@object.new_record?
    super(method, options)
  end
  
  def file_field(method, options = {})
    add_class_name(options, 'm-form_file')
    field_name, label, options = field_settings(method, options)
    wrapping("file", field_name, label, super, method, options)
  end
  
  def datetime_select(method, options = {}, html_options = {})
    options[:order] = [:day, :month, :year]
    add_class_name(html_options, 'm-form_select')
    field_name, label, options = field_settings(method, options)
    wrapping("datetime", field_name, label, super, method, options)
  end

  def time_select(method, options = {}, html_options = {})
    add_class_name(options, 'm-form_select')
    field_name, label, options = field_settings(method, options)
    elements = ""
    elements += hour_select(method, options.dup, html_options)
    elements += minute_select(method, options.dup, html_options)
    wrapping("time", field_name, label, elements, method, options)
  end
 
  def sign_select(method, options = {}, html_options = {})
    add_class_name(html_options, 'm-form_select')
    field_name, label, options = field_settings(method, options)
    element = select_tag("#{sanitized_object_name}[#{method.to_s}]", signs_select_options(@object[method]), options)
    wrapping("select", field_name, label, element, method, options)
  end

  def date_select(method, options = {}, html_options = {})
    add_class_name(options, 'm-form_select')
    field_name, label, options = field_settings(method, options)
    elements = ""
    elements += day_select(method, options.dup, html_options)
    elements += month_select(method, options.dup, html_options)
    elements += year_select(method, options.dup, html_options)
    wrapping("date", field_name, label, elements, method, options)
  end

  def hour_select(method, options = {}, html_options = {})
    default = Time.now.hour
    selected_value = (@object.send(method) && @object.send(method).hour) || default 
    select_options = hour_select_options(selected_value)
    add_class_name(options, 'hour')
    field_name, label, options = field_settings(method, options)
    options[:id] += '_4i'
    select_tag("#{sanitized_object_name}[#{method.to_s}(4i)]", select_options, options)
  end

  def minute_select(method, options = {}, html_options = {})
    default = Time.now.min
    selected_value = (@object.send(method) && @object.send(method).min) || default 
    select_options = minute_select_options(selected_value)
    add_class_name(options, 'minute')
    field_name, label, options = field_settings(method, options)
    options[:id] += '_5i'
    select_tag("#{sanitized_object_name}[#{method.to_s}(5i)]", select_options, options)
  end


  def year_select(method, options = {}, html_options = {})
    start_year = options.delete(:start_year) || 1970
    end_year = options.delete(:end_year) || 2030
    default = Date.today.year
    selected_value = (@object.send(method) && @object.send(method).year) || default 
    # Building array of options takes pretty much time,
    # so this function cache it.
    select_options = year_select_options(start_year, end_year, selected_value)
    add_class_name(options, 'year')
    field_name, label, options = field_settings(method, options)
    options[:id] += '_1i'
    select_tag("#{sanitized_object_name}[#{method.to_s}(1i)]", select_options, options)
  end

  def month_select(method, options = {}, html_options = {})
    default = 1
    selected_value = (@object.send(method) && @object.send(method).month) || default
    # Building array of options takes pretty much time,
    # so this function cache it.
    select_options = month_select_options(selected_value)
    add_class_name(options, 'month')
    field_name, label, options = field_settings(method, options)
    options[:id] += '_2i'
    select_tag("#{sanitized_object_name}[#{method.to_s}(2i)]", select_options, options)
  end

  def day_select(method, options = {}, html_options = {})
    default = 1
    selected_value = (@object.send(method) && @object.send(method).day) || default
    # Building array of options takes pretty much time,
    # so this function cache it.
    select_options = day_select_options(selected_value)
    add_class_name(options, 'day')
    field_name, label, options = field_settings(method, options)
    options[:id] += '_3i'
    select_tag("#{sanitized_object_name}[#{method.to_s}(3i)]", select_options, options)
  end

  
  def radio_button(method, tag_value, options = {})
    add_class_name(options, 'm-form_radio')
    field_name, label, options = field_settings(method, options)
    wrapping("radio", field_name, label, super, method, options)
  end
    
  def check_box(method, options = {}, checked_value = "1", unchecked_value = "0")
    add_class_name(options, 'm-form_checkbox')
    field_name, label, options = field_settings(method, options)
    wrapping("check-box", field_name, label, super, method, options)
  end

  def gender_select(method, options = {}, html_options = {})
    select(method, [['Male', 'm'], ['Female', 'f'], ['Other', 'o']], options, html_options)
  end
  
  def select(method, choices, options = {}, html_options = {})
    add_class_name(html_options, 'm-form_select')
    field_name, label, options = field_settings(method, options)
    html_options[:id] = options[:id]
    wrapping("select", field_name, label, super, method, options)
  end
  
  def password_field(method, options = {})
    add_class_name(options, 'm-form_password')
    field_name, label, options = field_settings(method, options)
    wrapping("password", field_name, label, super, method, options)
  end
 
  def text_area(method, options = {})
    options[:rows] = 5
    add_class_name(options, 'm-form_textarea')
    field_name, label, options = field_settings(method, options)
    wrapping("textarea", field_name, label, super, method, options)
  end

  def body_text_area(method, options = {})
    options[:rows] = 5
    add_class_name(options, 'm-form_textarea')
    field_name, label, options = field_settings(method, options)
    textarea = "<div class='m-form_field'>"
    textarea += text_area_tag("#{sanitized_object_name}[#{method.to_s}]", @object[method], options)
    textarea += "<p class='b-char-counter_text'>#{body_length_text(@object)}</p>"
    textarea += "</div>"
    wrapping("textarea", field_name, label, textarea, method, options)
  end
  
  def body_length_text(item)
    content_type = item.content_type
    min = content_type.min_characters_count
    max = content_type.max_characters_count
    length = item.body.to_s.mb_chars.length.to_s
    if !min.blank? && !max.blank?
      "<em class='length'>#{length}</em> characters (<em class='min'>#{min}</em> - <em class='max'>#{max}</em> allowed)"
    elsif !min.blank?
      "<em class='length'>#{length}</em> characters (<em class='min'>#{min}</em> minimum)"
    elsif !max.blank?
      "<em class='length'>#{length}</em> characters (<em class='max'>#{max}</em> maximum)"
    else
      "<em class='length'>#{length}</em> characters"
    end
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

  # Build array of signs - options for select tag, then cache it. 
  def signs_select_options(selected_value)
    unless @signs_select_options
      output = "<option></option>\n" 
      output += "<optgroup label=\"Western\">\n"
      index = 0
      output += AppConfig['western_signs'].map do |sign| 
        option = "<option value='#{index}'>#{sign.capitalize}</option>"
        index += 1
        option
      end.join("") 
      output += "</optgroup>\n<optgroup label=\"Chinese\">\n"
      output += AppConfig['chinese_signs'].map do |sign| 
        option = "<option value='#{index}'>#{sign.capitalize}</option>"
        index += 1
        option
      end.join("") 
      output += "</optgroup>\n"
      @signs_select_options = output
    end
    set_selected_option(@signs_select_options, selected_value)
  end

  # Build array of years - options for select tag, then cache it. 
  def hour_select_options(selected_value)
    unless @hour_select_options
      @hour_select_options = (0..23).map do |h| 
        "<option value='#{"%.2i" % h}'>#{"%.2i" % h}</option>"
      end.join("") 
    end
    set_selected_option(@hour_select_options, "%.2i" % selected_value)
  end

  # Build array of years - options for select tag, then cache it. 
  def minute_select_options(selected_value)
    unless @minute_select_options
      @minute_select_options = (0..59).map do |m| 
        "<option value='#{"%.2i" % m}'>#{"%.2i" % m}</option>"
      end.join("") 
    end
    set_selected_option(@minute_select_options, "%.2i" % selected_value)
  end

  # Build array of years - options for select tag, then cache it. 
  def year_select_options(start_year, end_year, selected_value)
    if !@year_select_options || !@year_select_options["#{start_year}_#{end_year}"]
      @year_select_options ||= {}
      @year_select_options["#{start_year}_#{end_year}"] = (start_year..end_year).map do |y| 
        "<option value='#{y}'>#{y}</option>"
      end.join("") 
    end
    set_selected_option(@year_select_options["#{start_year}_#{end_year}"], selected_value)
  end

  # Build array of months - options for select tag, then cache it. 
  def month_select_options(selected_value)
    unless @month_select_options
      months = {
        "January" => 1,
        "February" => 2, 
        "March" => 3, 
        "April" => 4,
        "May" => 5,
        "June" => 6, 
        "July" => 7, 
        "August" => 8, 
        "September" => 9,
        "October" => 10, 
        "November" => 11, 
        "December" => 12,
      }
      @month_select_options = months.map do |key, value| 
        "<option value='#{value}'>#{key}</option>"
      end.join("") 
    end
    set_selected_option(@month_select_options, selected_value)
  end

  # Build array of days - options for select tag, then cache it. 
  def day_select_options(selected_value)
    unless @day_select_options
      @day_select_options = (1..31).map do |d| 
          "<option value='#{d}'>#{d}</option>"
      end.join("") 
    end
    set_selected_option(@day_select_options, selected_value)
  end

  # Stupid, but fast way to add selected value to options :)
  def set_selected_option(options, selected_value)
    options.gsub(/ value='#{selected_value}'/, " value='#{selected_value}' selected='selected'")
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
