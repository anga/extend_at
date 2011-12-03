require "acts_as_configuration/version"

module ActsAsConfiguration
  def self.included(base)
    base.extend(ClassMethods)
  end

  class Configuration
    def initialize(options={})
      @model = options[:model]
      @column_name = options[:column_name].to_s
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
      @model.save
    end

    def [](key)
      @value[key.to_s]
    end

    def []=(key, value)
      @value[key.to_s] = value
      @model.update_column @column_name, @value.to_yaml
    end

    def method_missing(m, *args, &block)
      # r
      if m !~ /\=$/
        self[m.to_s]
      # w
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
      if options[:file].kind_of? String
        defaults_ = YAML.parse_file(options[:file]).to_ruby
        defaults_ = {} if not defaults_.kind_of? Hash
      elsif options[:defaults].kind_of? Hash
        defaults_ = transform_defaults options[:defaults]
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
  end

  module ClassMethods
    def acts_as_configuration(column_name, options = {})
      options = {
          :defaults => {}
        }.merge! options
      
      class_eval <<-EOV
      public
        def #{column_name.to_s}
          @#{column_name.to_s}_configuration ||= ActsAsConfiguration::Configuration.new({:model => self, :column_name => :#{column_name.to_s}, :defaults => #{options[:defaults]}}) if not @#{column_name.to_s}_configuration.kind_of? ActsAsConfiguration::Configuration
          @#{column_name.to_s}_configuration
        end
      EOV
    end
  end
end

ActiveRecord::Base.class_eval { include ActsAsConfiguration }