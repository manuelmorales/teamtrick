module StoriesHelper
  def hours_left_column r
    if r.hours_left
      h "#{r.hours_left.to_s}h"
    else
      "Not estimated yet."
    end
  end

  def list_row_class story
    if params[:mode] == "planning"
      factible_stories.include?(story) ? "factible" : "non-factible"
    end
  end

  # This will add :project_id, :mode and :sprint to in_place_editor_options
  # so that those get propagated too
  def importance_column record
    column = active_scaffold_config.columns[:importance]
    if record.authorized_for?(:action => :update, :column => column.name)
      id_options = {:id => record.id.to_s, :action => 'update_column', :name => column.name.to_s}
      tag_options = {:tag => "span", :id => element_cell_id(id_options), :class => "in_place_editor_field"}
      in_place_editor_options = {
        :url => {:controller => params_for[:controller], :action => "update_column", :column => column.name, :id => record.id.to_s},
        :with => params[:eid] ? "Form.serialize(form) + '&eid=#{params[:eid]}'" : nil,
        :click_to_edit_text => as_(:click_to_edit),
        :cancel_text => as_(:cancel),
        :loading_text => as_(:loading),
        :save_text => as_(:update),
        :saving_text => as_(:saving),
        :options => "{method: 'post'}",
        :script => true}.merge(column.options)

        # this is the key
        in_place_editor_options[:url].merge!({:mode => params[:mode], :project_id => params[:project_id], :sprint => params[:sprint]})

        content_tag(:span, record.importance.to_s, tag_options) + in_place_editor(tag_options[:id], in_place_editor_options)
    else
      record.importance.to_s
    end
  end
end
