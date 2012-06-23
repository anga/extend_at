require File.expand_path('../environment', __FILE__)

module ExtendModelAt
  # Main class configuration
  # This class is the core of extend_at
  class Configuration
    # 
    def run(env=nil,model=nil)
      if env.kind_of? Hash
        hash = expand_options env, { :not_call_symbol => [:boolean], :not_expand => [:validate, :default] }, model.clone
        hash[:columns] = init_columns hash[:columns]
        @config = hash
        read_associations_configuration
        return @config
      end
      
      if not env.kind_of? Proc
        return {}
      else
        Environment.new.run env, model
      end
    end

    protected
    # Read all model relationships like belongs_to and has_many
    def read_associations_configuration
      [:has_one, :has_many, :belongs_to].each do |relation|
        if @config.keys.include? :"#{relation}"
          raise "Invalid #{relation} value" if not [Hash, Array, Symbol].include? @config[:"#{relation}"].class

          # We change the user format (Hash, Array or only one element) to Array
          if @config[:"#{relation}"].kind_of? Hash
            list_models = @config[:"#{relation}"].keys
          elsif @config[:"#{relation}"].kind_of? Array
            list_models = @config[:"#{relation}"]
            # Transform the array of model in a hash with his configuraion (empty, default values)
            @config[:"#{relation}"] = {}
            list_models.each do |model|
              @config[:"#{relation}"][model.to_sym] = {}
            end
          else
            list_models = [@config[:"#{relation}"]]
            # Transform the array of model in a hash with his configuraion (empty, default values)
            @config[:"#{relation}"] = {}
            list_models.each do |model|
              @config[:"#{relation}"][model.to_sym] = {}
            end
          end

          # Iterate inside the array and get and create the configuration to that relationship
          list_models.each do |model|
            # If the user set some configuration (:class_name for example), we use it
            if @config[:"#{relation}"][model.to_sym].kind_of? Hash
              config = @config[:"#{relation}"][model.to_sym]
            # If not, we create it
            else
              # Change sybol of the class name to hash configuration
              @config[:"#{relation}"][model.to_sym] = {}
              config = {}
            end

            # We set the default class_name if is not seted
            if config[:class_name].nil?
              @config[:"#{relation}"][model.to_sym][:class_name] = model.to_s.classify
            else
              @config[:"#{relation}"][model.to_sym][:class_name] = config[:class_name]
            end

            # If the association is belongs_to, we need to define the columns
            if relation.to_s == "belongs_to"
              if config[:polymorphic] == true
                @config[:columns][ :"#{model}_id" ] = { :type => :integer }
                @config[:columns][ :"#{model}_type" ] = { :type => :string }
              else
                @config[:columns][ config[:foreign_key] || :"#{model}_id" ] = { :type => :integer }
                @config[:"#{relation}"][model.to_sym][:foreign_key] = config[:foreign_key] || :"#{model}_id" if @config[:"#{relation}"][model.to_sym][:foreign_key].nil?
              end
            end
            # TODO: Continue adding rails features like:
            #       :autosave
            #       :class_name
            #       :conditions
            #       :counter_cache
            #       :dependent
            #       :foreign_key
            #       :include
            #       :polymorphic
            #       :readonly
            #       :select
            #       :touch
            #       :validate
          end
        end
      end
    end
    
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

    # Transform the user configuration to hash. For example, if the user use lambda to create the configuration, this function execute the lambda to get the result
    # and re-parse it (and so on) to get a full hash configuration
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

    # Return the value of the execute a function inside the model, for example:
    # :column => :function
    # this function execute the function _function_ to get the value and set it his return to column
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