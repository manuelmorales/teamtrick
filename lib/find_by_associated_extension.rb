# Adds to ActiveRecord associations the
# possibility to find items associated 
# with has_many and has_many :trough just using find.
# Example: @user.roles.with_project @project
module FindByAssociatedExtension
  def method_missing method_id, *args
    if match = /with_([_a-zA-Z]\w*)/.match(method_id.to_s)

      desired_model = match[1]
      middleman = (proxy_reflection.source_reflection && proxy_reflection.source_reflection.active_record) || proxy_reflection.klass

      if middleman.instance_methods.include? desired_model
        find(:all, :conditions => ["#{desired_model}_id = ?", args.first.id])
      else
        super
      end

    else 
      super
    end
  end
end
