require File.expand_path('../environment', __FILE__)

module ExtendModelAt
  class Configuration
    def self.run(env=nil,model=nil)
      return expand_options env, { :not_call_symbol => [:boolean], :not_expand => [:validate, :default] }, model if env.kind_of? Hash
      
      if not env.kind_of? Proc
        return {}
      else
        Environment.new.run env, model
      end
    end

    protected
    def self.expand_options(options={}, opts={}, model=nil)
      options = get_value_of options, model
      config_opts = {
        :not_expand => [],
        :not_call_symbol => []
      }.merge! opts
      if options.kind_of? Hash
        opts = {}
        options.each do |column, config|
          if not config_opts[:not_expand].include? column.to_sym
            if not config_opts[:not_call_symbol].include? config
              opts[column.to_sym] = expand_options(get_value_of(config, model), config_opts, model)
            else
              opts[column.to_sym] = expand_options(config, config_opts, model)
            end
          else
            opts[column.to_sym] = config
          end
        end
        return opts
      else
        return get_value_of options, model
      end
    end

    def self.get_value_of(value, model=nil)
      if value.kind_of? Symbol
        # If the function exist, we execute it
        if  model.respond_to? value
          return model.send value
        # if the the function not exist, whe set te symbol as a value
        else
          return value
        end
      elsif value.kind_of? Proc
        return value.call
      else
        return value
      end
    end
  end
end