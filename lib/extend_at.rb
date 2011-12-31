# encoding: utf-8
require "extend_at/version"

module ExtendModelAt
  def self.included(base)
    base.extend(ClassMethods)
  end

  # The object how controll the data
  class Extention
    def initialize(options={})
      @model = options[:model]
      @column_name = options[:column_name].to_s
      @columns = expand_options options[:columns], { :not_call_symbol => [:boolean], :not_expand => [:validate, :default] }
      @value = get_defaults_values options

      raise "#{@column_name} should by text or string not #{options[:model].column_for_attribute(@column_name.to_sym).type}" if not [:text, :stiring].include? options[:model].column_for_attribute(@column_name.to_sym).type

      out = YAML.parse(@model[@column_name].to_s)
      if out == false
        db_value = nil
      else
        db_value = out.to_ruby
      end
      @value.merge! db_value if db_value.kind_of? Hash

      initialize_values

      # Raise or not if fail?...
      @model.attributes[@column_name] = @value
      @model.save(:validate => false)
    end

    def [](key)
      @value[key.to_s]
    end

    def []=(key, value)
      if @columns[key.to_sym].kind_of? Hash and ((@columns[key.to_sym][:type] == :boolean and (not [true.class, false.class].include? value.class)) or
          ((not [:boolean, nil].include?(@columns[key.to_sym][:type])) and @columns[key.to_sym][:type] != value.class ))
        raise "#{value.inspect} is not a valid type, expected #{@columns[key.to_sym][:type]}"
      end
      @value[key.to_s] = value
      @model.send :"#{@column_name}=", @value.to_yaml
    end

    # The "magic" happen here.
    # Use the undefined method as a column
    def method_missing(m, *args, &block)
      # If the method don't finish in "=" is fore read
      if m !~ /\=$/
        self[m.to_s]
      # but if finish with "=" is for wirte
      else
        column_name = m.to_s.gsub(/\=$/, '')
        self[column_name.to_s] = args.first
      end
    end

    private

    def initialize_values
      if not @value.kind_of? Hash
        @model.attributes[@column_name] = {}.to_yaml
        @model.save
      end
    end

    def get_defaults_values(options = {})
      defaults_ = {}
      options[:columns].each do |column, config|
        defaults_[column.to_s] = @columns[column.to_sym][:default] || nil
      end
      defaults_
    end

    # Only we accept strings as key
    def transform_defaults(hash)
      _hash = {}
      hash.each do |key, value|
        _hash[key.to_s] = value
      end
      _hash
    end

    def expand_options(options={}, opts={})
      config_opts = {
        :not_expand => [],
        :not_call_symbol => []
      }.merge! opts
      if options.kind_of? Hash
        opts = {}
        options.each do |column, config|
          if not config_opts[:not_expand].include? column.to_sym
            if not config_opts[:not_call_symbol].include? config
              opts[column.to_sym] = expand_options(get_value_of(config), config_opts)
            else
              opts[column.to_sym] = expand_options(config, config_opts)
            end
          else
            opts[column.to_sym] = config
          end
        end
        return opts
      else
        return get_value_of options
      end
    end

    def get_value_of(value)
      if value.kind_of? Symbol
        # If the function exist, we execute it
        if  @model.respond_to? value
          return @model.send value
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

  module ClassMethods
    def extend_at(column_name, options = {})
      assign_attributes_eval = "
      def assign_attributes(attributes = nil, options = {})
        attributes.each_pair do |key, value|
          if key.to_s =~ /^#{column_name}_/
            rb = \"#{column_name}.\#\{key.to_s.gsub(/^#{column_name}_/,'')\} = value\"
            eval rb, binding
          end
        end
        attributes.delete_if do |key,value|
          key.to_s =~ /^#{column_name}_/
        end
        super attributes, options
      end

      def method_missing(m, *args, &block)
        if m !~ /^#{column_name}_[a-zA-Z_][a-zA-Z_0-9]*\=$/
          rb = \"self.#{column_name}.\#\{m.to_s.gsub(/^#{column_name}_/, '')} = args.first\"
          puts \"Evaluando #\{rb}\"
          eval rb, binding
        else
          super
        end
      end
      "

      self.class_eval <<-EOS
        eval assign_attributes_eval
      EOS
      
      class_eval <<-EOV
      public
        validate :extend_at_validations
        
        def #{column_name.to_s}
          if not @#{column_name.to_s}_configuration.kind_of? ExtendModelAt::Extention
            opts = initialize_options(#{options})
            options = {
                :extensible => true    # If is false, only the columns defined in :columns can be used
              }.merge! opts
            columns = initialize_columns expand_options(options, { :not_call_symbol => [:boolean], :not_expand => [:validate, :default] })
            @#{column_name.to_s}_configuration ||= ExtendModelAt::Extention.new({:model => self, :column_name => :#{column_name.to_s}, :columns => columns})
          end
          @#{column_name.to_s}_configuration
        end

      protected
        def extend_at_validations
          @extend_at_validation ||= {} if not @extend_at_validation.kind_of? Hash
          @extend_at_validation.each do |column, validation|
            if validation.kind_of? Symbol
              self.send validation, eval("@#{column_name.to_s}_configuration.\#\{column.to_s\}")
            elsif validation.kind_of? Proc
              validation.call @#{column_name.to_s}_configuration[column.to_sym]
            end
          end
        end

        def initialize_options(options={})
          opts = expand_options options, { :not_call_symbol => [:boolean], :not_expand => [:validate, :default] }
        end

        # Initialize each column configuration
        def initialize_columns(options = {})
          columns = {}
          if options[:columns].kind_of? Hash
            options[:columns].each do |column, config|
              columns[column] = initialize_column column, config
            end
          elsif options[:columns].kind_of? Symbol
            hash =  self.send options[:columns]
            raise "Invalid columns configuration" if not hash.kind_of? Hash
            columns = initialize_columns :columns => hash
          elsif options[:columns].kind_of? Proc
            hash = options[:columns].call
            raise "Invalid columns configuration" if not hash.kind_of? Hash
            columns = initialize_columns :columns => hash
          end
          columns
        end

        def initialize_column(column,config={})
          raise "The column \#\{column\} have an invalid configuration (\#\{config.class\} => \#\{config\})" if not config.kind_of? Hash
          column = column.to_sym
          column_config = {}

          # Stablish the type
          if config[:type].class == Class
            # If exist :type, is a static column
            column_config[:type] = config[:type]
          else
            # if not, is a dynamic column
            if config[:type].to_sym == :any
              column_config[:type] = nil
            elsif config[:type].to_sym == :boolean
              column_config[:type] = :boolean
            else
              raise "\#\{config[:type]\} is not a valid column type"
            end
          end

          # Stablish the default value
          # if is a symbol, we execute the function from the model
          if config[:default].kind_of? Symbol
            column_config[:default] = self.send(:config[:default])
          elsif config[:default].kind_of? Proc
            column_config[:default] = config[:default].call
          else
            # If the column have a type, we verify the type
            if not column_config[:type].nil?
              if  (column_config[:type] == :boolean and (not [true.class, false.class].include? config[:default].class)) or
                  ((not [:boolean, nil].include?(column_config[:type])) and column_config[:type] != config[:default].class )
                  raise "The column \#\{column\} has an invalid default value. Expected \#\{column_config[:type]}, not \#\{config[:default].class}"
              end
              column_config[:default] = config[:default]
            else
              # If is dynamic, only we set the default value
              column_config[:default] = config[:default]
            end
          end

          # Set the validation
          if [Symbol, Proc].include? config[:validate].class
            column_config[:validate] = config[:validate]
            create_validation_for column, config[:validate]
          else
            raise "The validation of \#\{column\} is invalid"
          end


          column_config
        end

        def create_validation_for(column, validation)
          column = column.to_sym
          @extend_at_validation ||= {}
          @extend_at_validation[column] = validation
        end

        def expand_options(options={}, opts={})
          config_opts = {
            :not_expand => [],
            :not_call_symbol => []
          }.merge! opts
          if options.kind_of? Hash
            opts = {}
            options.each do |column, config|
              if not config_opts[:not_expand].include? column.to_sym
                if not config_opts[:not_call_symbol].include? config
                  opts[column.to_sym] = expand_options(get_value_of(config), config_opts)
                else
                  opts[column.to_sym] = expand_options(config, config_opts)
                end
              else
                opts[column.to_sym] = config
              end
            end
            return opts
          else
            return get_value_of options
          end
        end

        def get_value_of(value)
          if value.kind_of? Symbol
            # If the function exist, we execute it
            if  self.respond_to? value
              return self.send value
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
      EOV
      
    end

    

    protected


  end
end

ActiveRecord::Base.class_eval { include ExtendModelAt }