# encoding: utf-8
require "extend_at/version"
require "extend_at/model_manager"
require "extend_at/models/all"

module ExtendModelAt
  def self.included(base)
    base.extend(ClassMethods)
  end

  # Errors
  class InvalidColumn < Exception
  end

  class ArgumentError < Exception
  end

  # The object how controll the data
  class Extention
    def initialize(options={})
      @static = options[:static] || false
      @model = options[:model]
      @column_name = options[:column_name].to_s
      @columns = options[:columns]
      @value = get_defaults_values options
      @model_manager = ::ExtendModelAt::ModelManager.new(@column_name, @model, @columns)

      raise ExtendModelAt::ArgumentError, "#{@column_name} should by text or string not #{options[:model].column_for_attribute(@column_name.to_sym).type}" if not [:text, :stiring].include? options[:model].column_for_attribute(@column_name.to_sym).type

      initialize_values
    end

    def [](key)
      @model_manager.get_value(key)
    end

    def []=(key, value)
      if not valid_type? value, @columns[key.to_sym].try(:[],:type)
        # Try to adapt the value
        adapter = get_adapter key, value
        raise ExtendModelAt::ArgumentError, "#{value.inspect} is not a valid type, expected #{@columns[key.to_sym][:type]}" if adapter.nil? # We can't adapt the value
        value = value.send adapter
      end
      @value[key.to_s] = value
      @model_manager.assign(key,value)
    end

    def self.respond_to?(symbol, include_private=false)
      true
    end

    def respond_to?(symbol, include_private=false)
      true
    end

    def all_values
      @model_manager.all_values
    end

    def all_names
      @model_manager.all_names
    end

    def all_hash
      @model_manager.all_hash
    end

    # Use the undefined method as a column
    def method_missing(m, *args, &block)
      column_name = m.to_s.gsub(/\=$/, '')
      raise ExtendModelAt::InvalidColumn, "#{column_name} not exist" if @static == true and not (@columns.try(:keys).try(:include?, column_name.to_sym) )
      # If the method don't finish with "=" is fore read
      if m !~ /\=$/
        self[m.to_s]
      # but if finish with "=" is for wirte
      else
        self[column_name.to_s] = args.first
      end
    end

    private

    def get_adapter(column, value)
      if @columns[column.to_sym][:type] == String
        return :to_s
      elsif @columns[column.to_sym][:type] == Fixnum
        return :to_i if value.respond_to? :to_i
      elsif @columns[column.to_sym][:type] == Float
        return :to_f if value.respond_to? :to_f
      elsif @columns[column.to_sym][:type] == Time
        return :to_time if value.respond_to? :to_time
      elsif @columns[column.to_sym][:type] == Date
        return :to_date if value.respond_to? :to_date
      end
      nil
    end

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

    def update_model_manager
      @model_manager.send :update
    end

    def valid_type?(value, type)
      @model.send :valid_type?, value, type
    end

    def search(column, method, value)
      @model_manager.send:search, column, method, value
    end
  end

  module ClassMethods
    def extend_at(column_name, options = {})
      assign_attributes_eval = "
      # Rewrite the mass assignment method because we need to accept write code like User.new :config_born => 10.years.ago
      def assign_attributes(attributes = nil, options = {})
        attributes.each_pair do |key, value|
          if key.to_s =~ /^#{column_name}_/
            rb = \"self.#{column_name}.\#\{key.to_s.gsub(/^#{column_name}_/,'')\} = value\"
            eval rb, binding
          end
        end
        attributes.delete_if do |key,value|
          key.to_s =~ /^#{column_name}_/
        end
        super attributes, options
      end

      # Return the value of <<attributes>> methods like <column name>_<extended column name>
      def [](column)
        if column.to_s =~ /^#{column_name}_[a-zA-Z_][a-zA-Z_0-9]*\=?$/
          rb = \"self.#{column_name}.\#\{column.to_s.gsub(/^#{column_name}_/,'').gsub(/\=$/, '')\}\"
          eval rb, binding
        else
          super
        end
      end

      # Write the value of <<attributes>> methods like <column name>_<extended column name>
      def []=(column, value)
        if column.to_s =~ /^#{column_name}_[a-zA-Z_][a-zA-Z_0-9]*\=?$/
          rb = \"self.#{column_name}.\#\{column.to_s.gsub(/^#{column_name}_/,'').gsub(/\=$/, '')\} = value\"
          eval rb, binding
        else
          super
        end
      end

      # Respond to ethod like <column name>_<extended column name> for read or write
      def self.respond_to?(symbol, include_private=false)
        if symbol.to_s =~ /^#{column_name}_[a-zA-Z_][a-zA-Z_0-9]*\=?$/
          return true
        else
          super
        end
      end

      # Respond to ethod like <column name>_<extended column name> for read or write
      def respond_to?(symbol, include_private=false)
        if symbol.to_s =~ /^#{column_name}_[a-zA-Z_][a-zA-Z_0-9]*\=?$/
          return true
        else
          super
        end
      end

      def self.method_missing(m, *args, &block)
        if m.to_s =~ /^#{column_name}_[a-zA-Z_][a-zA-Z_0-9]+_(#\{VALID_COMPARATIONS.join('|')})$/
          method = m[/(#\{VALID_COMPARATIONS.join('|')})$/]
          column = m.to_s.gsub(/^#{column_name}_/, '').gsub(/_(#\{VALID_COMPARATIONS.join('|')})$/, '')

          code = (self.last || self.new).send :search_in_extention, column, method, args.first

          value = args.first

          return eval code, binding
        else
          super
        end
      end

      # Accept method like <column name>_<extended column name> for read or write
      def method_missing(m, *args, &block)
        if m.to_s =~ /^#{column_name}_[a-zA-Z_][a-zA-Z_0-9]+_(#\{VALID_COMPARATIONS.join('|')})$/
          method = m[/(#\{VALID_COMPARATIONS.join('|')})$/]
          column = m.to_s.gsub(/^#{column_name}_/, '').gsub(/(#\{VALID_COMPARATIONS.join('|')})/, '')
          return search_in_extention column, method, args.first
        elsif m.to_s =~ /^#{column_name}_[a-zA-Z_][a-zA-Z_0-9]*\=$/
          rb = \"self.#{column_name}.\#\{m.to_s.gsub(/^#{column_name}_/, '').gsub(/\=$/, '')} = args.first\"
          return eval rb, binding
        elsif m.to_s =~ /^#{column_name}_[a-zA-Z_][a-zA-Z_0-9]*$/
          rb = \"self.#{column_name}.\#\{m.to_s.gsub(/^#{column_name}_/, '')}\"
          return eval rb, binding
        else
          super
        end
      end

      protected
      VALID_COMPARATIONS = ['gt', 'gt_eq', 'lt', 'lt_eq', 'eq', 'in', 'match']

      def search_in_extention(column, method, value)
        #{column_name.to_s}.send :search, column, method, value
      end
      "

      self.class_eval <<-EOS
        eval assign_attributes_eval
      EOS
      
      class_eval do
      public
        validate :extend_at_validations
        after_save :update_model_manager, :on => :create

        define_method(column_name.to_s) do
          if not @extend_at_configuration.kind_of? ExtendModelAt::Extention
            opts = initialize_options(options)
            options = {
                :extensible => true    # If is false, only the columns defined in :columns can be used
              }.merge!(opts)
            columns = initialize_columns expand_options(options, { :not_call_symbol => [:boolean], :not_expand => [:validate, :default] }) if options.kind_of? Hash
            @extend_at_configuration ||= ExtendModelAt::Extention.new({:model => self, :column_name => column_name.to_sym, :columns => columns, :static => options[:static]})
          end
          @extend_at_configuration
        end

      protected
      
        def extend_at_validations
#           @extend_at_configuration.valid?
          @extend_at_validation ||= {} if not @extend_at_validation.kind_of? Hash
          @extend_at_validation.each do |column, validation|
            if validation.kind_of? Symbol
              self.send validation, eval("@extend_at_configuration.\#\{column.to_s\}", binding)
            elsif validation.kind_of? Proc
              instance_exec @extend_at_configuration[column.to_sym], &validation
#               validation.call @extend_at_configuration[column.to_sym]
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
            raise ExtendModelAt::ArgumentError, "Invalid columns configuration" if not hash.kind_of? Hash
            columns = initialize_columns :columns => hash
          elsif options[:columns].kind_of? Proc
            hash = options[:columns].call
            raise ExtendModelAt::ArgumentError, "Invalid columns configuration" if not hash.kind_of? Hash
            columns = initialize_columns :columns => hash
          end
          columns
        end

        def initialize_column(column,config={})
          raise ExtendModelAt::ArgumentError, "The column \#\{column\} have an invalid configuration (\#\{config.class\} => \#\{config\})" if not config.kind_of? Hash
          
          @VALID_SYMBOLS ||= [:any, :binary, :boolean, :date, :datetime, :decimal, :float, :integer, :string, :text, :time, :timestamp]
          
          column = column.to_sym
          column_config = {}

          # Stablish the type
          if config[:type].class == Class
            # If exist :type, is a static column
            column_config[:type] = get_type_for_class config[:type]
          elsif config[:type].class == Symbol and @VALID_SYMBOLS.include? config[:type]
            column_config[:type] = config[:type]
          elsif [Symbol, Proc].include? config[:type]
            column_config[:type] = get_value_of config[:type]
          else
            raise ExtendModelAt::ArgumentError, "\#\{config[:type]\} is not a valid column type"
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
              if not valid_type?(config[:default], column_config[:type])
                  raise ExtendModelAt::ArgumentError, "The column \#\{column\} has an invalid default value. Expected \#\{column_config[:type]}, not \#\{config[:default].class}"
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
          elsif not config[:validate].nil?
            raise ExtendModelAt::ArgumentError, "The validation of \#\{column\} is invalid"
          end


          column_config
        end

        def get_type_from_symbol(type)
          type = type.to_s
          return nil if type == 'any' or type == ''
          return :boolean if type == 'boolean'
          return Float if type == 'float'
          return Fixnum if type == 'integer'
          return String if type == 'string' or type == 'text'
          return Time if type == 'time' or type == 'timestamp'
          return Date if type == 'date' or type == 'datetime'
          return eval type.classify
        end

        def create_validation_for(column, validation)
          column = column.to_sym
          @extend_at_validation ||= {}
          @extend_at_validation[column] = validation
        end

        def expand_options(options={}, opts={})
          options = get_value_of options
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

        def update_model_manager
          @extend_at_configuration.send :update_model_manager
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

        def compatible_type(value,type)
          return true if value.class == String and [:string, :text, :binary].include? type
          return true if value.class == Fixnum and [:integer, :float].include? type
          return true if [Fixnum, Float].include? value.class and [:integer, :float].include? type
          return true if [true.class, false.class].include? value.class and [:boolean].include? type
          return true if value.class == BigDecimal and [:decimal].include? type
          return true if [Date, Time].include? value.class and [:date, :time].include? type
          return true if value.class == BigDecimal and [:decimal].include? type
          return true if [Date, Time, ActiveSupport::TimeWithZone].include? value.class and [:datetime, :timestamp].include? type
          false
        end

        def valid_type?(value, type)
        type = type.to_s.to_sym
        [:"", :any].include? type or
          value.nil? or
          (type == :boolean and ([true.class, false.class].include? value.class)) or
          ((not [:boolean, nil].include?(type)) and not value.nil? and compatible_type(value, type))
        end
      end
    end
  end
end

ActiveRecord::Base.class_eval { include ExtendModelAt }