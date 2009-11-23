# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def separate list, options = {:with => " | "}
    list.compact.join(options[:with])
  end

  def link_to_or_nil(condition, name, options = {}, html_options = {}, &block)
    b = block || Proc.new{nil}
    link_to_if(condition, name, options, html_options, &b)
  end

  def title title
    content_for(:title){ title }
    content_tag :h1, title
  end
end
