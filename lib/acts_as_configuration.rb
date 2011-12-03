require "acts_as_configuration/version"

module ActsAsConfiguration
  def self.included(base)
    base.extend(ClassMethods)
  end

  class Configuration
    def initialize(options={})
      @model = options[:model]
      @column_name = options[:column_name]
      @value = get_defaults_values options
      
      raise "#{@column_name} should by text or string" if [:text, :stiring].include? u.column_for_attribute(@column_name.to_sym).type

      db_value = YAML.parse(@model[@column_name]).to_ruby
      @value.merge! db_value if db_value.kind_of? Hash

      initialize_values
      
      # Raise or not if fail?...
      @model.uppdate_attributes({@column_name => {}.to_yaml })
    end

    def []=(key, value)
      @value[key.to_s.to_sym] = value
      model[@column_name] = value.to_yaml
    end

    def method_missing(m, *args, &block)
      super if m !~ /\=$/
      column_name = m.to_s.gsub(/\=$/, '')
      self[column_name.to_sym] = args
    end

    private
    
    def initialize_values
      if not @value.kind_of? Hash
        @model.uppdate_attributes({@column_name => {}.to_yaml})
#         @value = {}
      end
    end

    def get_defaults_values(options = {})
      defaults_ = {}
      if options[:file].kind_of? String
        defaults_ = YAML.parse_file(options[:file]).to_ruby
        defaults_ = {} if not defaults_.kind_of? Hash
      elsif options[:defaults].kind_of? Hash
        defaults_ = options[:defaults]
      end
      defaults_
    end
  end

  module ClassMethods
    def acts_as_configuration(column_name, options = {})
      options = {
          :defaults => {}
        }.merge! options

      class_eval <<-EOV
        def #{column_name}
          @#{column_name}_configuration ||= ActsAsConfiguration::Configuration.new {:model => self, :column_name => :#{column_name}, :defaults => #{options[:defaults]}} if @#{column_name}_configuration.kind_of? ActsAsConfiguration::Configuration
          @#{column_name}_configuration
        end
      EOV
    end
  end
end

ActiveRecord::Base.class_eval { include ActsAsConfiguration }