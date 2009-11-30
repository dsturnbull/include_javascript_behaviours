module IncludeJavascriptBehaviours
  def self.included(base)
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods
    def include_javascript_behaviours(*args)
      scripts = []
      if args.first == :global
        scripts << 'global'
      else
        args = [controller_name, action_name] if args.empty?
        # controller_action.js or controller.js
        [[*args], [args.first]].map do |options|
          js = options.join('_')
          scripts << js
        end
      end

      # include js behaviour for any partials rendered
      if partials_rendered = response.template.instance_variable_get('@_memoized__pick_partial_template')
        if partials_rendered.respond_to?(:keys)
          partials_rendered.keys.each do |partial|
            js = "_#{partial.first.gsub('/', '_')}"
            scripts << js
          end
        end
      end

      scripts.map { |js|
        if File.exists?(Rails.root + "public/javascripts/#{js}.js")
          javascript_include_tag js, :charset => 'utf-8'
        end
      }.reject { |js|
        js.nil?
      }.join("\n")
    end
  end
end

