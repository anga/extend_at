require File.expand_path('../environment', __FILE__)

module ExtendModelAt
  class Configuration
    def run(env=nil,model=nil)
      if env.kind_of? Hash
        hash = expand_options env, { :not_call_symbol => [:boolean], :not_expand => [:validate, :default] }, model.clone
        hash[:columns] = init_columns hash[:columns]
        return hash
      end
      
      if not env.kind_of? Proc
        return {}
      else
        Environment.new.run env, model
      end
    end

    protected
    def init_columns(columns={})
      new = {}
      columns.each do |column, config|
        new[column] = config
        # Stablish the type
          if config[:type].class == Class
            # If exist :type, is a static column
            new[column][:type] = get_type_for_class config[:type]
          end
      end
      new
    end

    def get_type_for_class(type)
      type = type.name
      return :any if type == 'NilClass'
      return :float if type == 'Float'
      return :integer if type == 'Fixnum'
      return :text if type == 'String '
      return :timestamp if type == 'Time'
      return :datetime if type == 'Date'
      return :any
    end
    
    def expand_options(options={}, opts={}, model=nil)
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

    def get_value_of(value, model=nil)
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