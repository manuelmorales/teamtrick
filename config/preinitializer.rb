require "#{File.dirname(__FILE__)}/../vendor/bundler_gems/environment"
 
module Rails
  class Boot
    def run
      load_initializer
      extend_environment
      Rails::Initializer.run(:set_load_path)
    end

    def extend_environment
      Rails::Initializer.class_eval do
        old_load = instance_method(:load_gems)
        define_method(:load_gems) do
          old_load.bind(self).call
          Bundler.require_env RAILS_ENV
        end
      end
    end
  end
end
