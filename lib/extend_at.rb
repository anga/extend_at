# encoding: utf-8
require "active_support"
require "extend_at/version"
# require "extend_at/configuration"
require "extend_at/model_manager"
require "extend_at/models/all"

# ExtendAt allow you to extend the columns of a model without make database migrations.
#
# For example, if you want to create an administration panel to add columns to a model, for example, you are working on
# a CMS, and you want to create a _"content type"_ and you need to set the _"columns"_ but you
# don't want to migrate the database, then, you can see [this](https://github.com/anga/extend_at#tips) little tutorial.
# 
# = Important
# This gem was only tested with Ruby on Rails 3
#
# = Installation
# [+gem install extend_at+]
# 
# == Rails 3
# Add in your Gemfile:
# 
# [+gem 'extend_at'+]
# 
# After that, you need execute:
# 
# [+rails generate extend_at:install+]
# 
# This will generate one migration with all necessary tables. Now you need migrate your database.
# 
# [+rake db:migrate+]
#
# = Usage
# You don't need an extra column in your model. Only you need is put next code in your model.
# 
# [+extend_at :extra+]
# 
# For example:
# 
#     class User < ActiveRecord::Base
#       extend_at :extra
#     end
# 
# Now you can create extra attributes:
# 
#     user.extra.private_photos = true
#     user.extra.subscribe_to_news = false
#     user.extra.profile_description = ''
#     user.save
# 
# This is the same:
# 
#     user.extra_private_photos = true
#     user.extra_subscribe_to_news = false
#     user.extra_profile_description = ''
#     user.save
# 
# Or:
# 
#     user[:extra_private_photos] = true
#     user[:extra_subscribe_to_news] = false
#     user[:extra_profile_description] = ''
#     user.save
#= Columns configuration
# 
# You can configure each column.
# 
# == Set column type
# 
# You can set the colum's type.
# 
#     class User < ActiveRecord::Base
#       extend_at :extra, :columns => {
#         :private_photos => {
#           :type => :boolean
#         }, :age => {
#           :type => :get_type
#         }, :profile_description => {
#           :type => lambda {
#             String
#           }
#         }, :last_loggin => {
#           :type => Time.now.class
#         }, :subscribe_to_rss => :get_rss_config
#       }
# 
#       protected
#       def get_type
#         Fixnum
#       end
# 
#       def get_rss_config
#         {
#           :type => :boolean
#         }
#       end
#     end
# 
# === Valid types
# 
# Valid symbols:
# 
# * <code>:any</code>
# * <code>:binary</code>
# * <code>:boolean</code>
# * <code>:date</code>
# * <code>:datetime</code>
# * <code>:decimal</code>
# * <code>:float</code>
# * <code>:integer</code>
# * <code>:string</code>
# * <code>:text</code>
# * <code>:time</code>
# * <code>:timestamp</code>
# 
# But you can use classes.
# 
# * Float: <code>:any</code>
# * Fixnum: <code>:integer</code>
# * String: <code>:text</code>
# * Time: <code>:timestamp</code>
# * Date: <code>:datetime</code>
# 
# Else, return <code>:any</code>
# 
# === Set default value
# 
#     class User < ActiveRecord::Base
#       extend_at :extra, :columns => {
#         :private_photos => {
#           :type => :boolean,
#           :default => true
#         }, :age => {
#           :type => :get_type,
#           :default => 1
#         }, :profile_description => {
#           :type => lambda {
#             String
#           },
#           :default => :get_default_profile_description
#         }, :last_loggin => {
#           :type => Time.now.class,
#           :default => lambda {
#             self.created_at.time
#           }
#         }, :subscribe_to_rss => :get_rss_config
#       }
# 
#       protected
#       def get_type
#         Fixnum
#       end
# 
#       def get_rss_config
#         {
#           :type => :boolean,
#           :default => true
#         }
#       end
# 
#       def get_default_profile_description
#         Description.where(:user_id => self.id).default
#       end
#     end
# 
# === Set validation
# 
#     class User < ActiveRecord::Base
#       extend_at :extra, :columns => {
#         :private_photos => {
#           :type => :boolean,
#           :default => true
#         }, :age => {
#           :type => :get_type,
#           :default => 1,
#           :validate => lambda {
#             |age|
#             errors.add :extra_age, "Are you Matusalen?" if age > 150
#             errors.add :extra_age, "Are you a fetus?" if age <= 0
#           }
#         }, :profile_description => {
#           :type => lambda {
#             String
#           },
#           :default => :get_default_profile_description,
#           :lambda => :must_not_use_strong_language
#         }, :last_loggin => {
#           :type => Time.now.class,
#           :default => lambda {
#             self.created_at.time
#           },
#           :validate => lambda {
#             |time|
#             errors.add :extra_last_loggin, "You can't loggin on the future" if time > Time.now
#           }
#         }, :subscribe_to_rss => :get_rss_config
#       }
# 
#       protected
#       STRONG_WORD = [
#         #...
#       ]
# 
#       def get_type
#         Fixnum
#       end
# 
#       def get_rss_config
#         {
#           :type => :boolean,
#           :default => true
#         }
#       end
# 
#       def get_default_profile_description
#         Description.where(:user_id => self.id).default
#       end
# 
#       def must_not_use_strong_language(desc)
#         errors.add :cofig_profile_description, "You must not use strong language" if desc =~ /(#{STRONG_WORD.join('|')})/
#       end
#     end
# 
# == Static columns
# 
# If you like to restrict the existent extended columns, you should use <code>:static => true</code>
# 
#     class User < ActiveRecord::Base
#       extend_at :extra, :columns => {
#         :private_photos => {
#           :type => :boolean,
#           :default => true
#         }
#       }, :static => true
#     end
# 
# Now, <code>User.extra</code> only accept <code>private_photos</code> column
# 
# == Scopes
# 
# You can use scope like:
# 
#     User.extra_last_loggin_gt_eq(1.week.ago).extra_age_gt_eq(18).where(:column => "value").all
# 
# Valid scopes:
# 
#     <extention>_<column_name>_<comparation>
# 
# Comparations:
# 
# * lt
# * lt_eq
# * eq
# * gt_eq
# * gt
# * match
# 
# == Belongs to
# 
# If you like to add a belongs_to relationship, you can do it in this way:
# 
#     # app/models/toolbox.rb
#     class Toolbox
#     end
# 
#     # app/model/tool.rb
#     class Tool
#       extend_at extra, columns => {}, :belongs_to => :toolbox
#     end
# 
# [+:belongs_to+] parametter accept
# 
# * One name
# 
#   [+:belongs_to => :toolbox+]
# 
# * Array of names
# 
#   [+:belongs_to => [:toolbox, :owner]+]
# 
# * Hash
# 
#   [+:belongs_to => {:onwer => {:class_name => "User"}}+]
# 
# For now, hash only accept
# 
# * class_name
# * polymorphic
# * foreign_key
# 
# _Note_, this new feature is under heavy development, use it under your own risk.
# 
# 
# == Integration in the views
# 
# If you like to use some configuration variable in your views you only need put the name of the input like <code>:extra_name</code>, for example:
# 
#     <% form_for(@user) do |f| %>
#       ...
#       <div class="field">
#         <%= f.label :extra_private_photos %><br />
#         <%= f.check_box :extra_private_photos %>
#       </div>
#       ...
#     <% end %>
# 
# == More
# 
# For more documentation go to [wiki](https://github.com/anga/extend_at/wiki "extend_at wiki").
# 
# == Tips
# 
# If you like to do something more dynamic, like create columns and validations depending of some model or configuration, then you can do something like this:
# 
#     class User < ActiveRecord::Base
#       extend_at :extra, :columns => :get_columns
#       serialize :columns_name
# 
#       protected
#       def get_columns
#         columns = {}
#         columns_name.each do |name|
#           config = ColumConfig.where(:user_id => self.id, :column => name).first
#           columns[name.to_sym] = {
#             :type => eval(config.class_type),
#             :default => config.default_value,
#             :validate => get_validation(config)
#           }
#         end
# 
#         columns
#       end
# 
#       # Accept a name of a validation and return the Proc with the validation code
#       def get_validation(validation_type)
#         # ...
#       end
#     end
# 
# How works?
# 
#     [+serialize :columns_name+]
# 
# This make <code>columns_name</code> column work like YAML serialized object. In this case, is used to sotore an array of names of each column name.
# (See [ActiveRecord::Base](http://api.rubyonrails.org/classes/ActiveRecord/Base.html))
# 
#     [+extend_at :extra, :columns => :get_columns+]
# 
# This line will use the function <code>get_columns</code> to get the information about each column dynamically.
# This function returns a hash with the information about each column.
# 
#     columns_name.each do |name|
#         #...
#     end
# 
# Iterate through each column stored in the column <code>columns_name</code>.
# 
#     config = ColumConfig.where(:user_id => self.id, :column => name).first
# 
# Search the column configuration stored in a separated model. By this way, we can configura each column easily, we can create a view to create columns and configure it easily.
# 
#     columns[name.to_sym] = {
#         :type => eval(config.class_type),
#         :default => config.default_value,
#         :validate => get_validation(config)
#       }
# 
# This lines configure the column.
# 
#     [+:type => eval(config.class_type),+]
# 
# The model <code>ColumConfig</code> have a string column named <code>class_type</code>, can be <code>":integer"</code> or <code>"Fixnum"</code>.
# 
#     [+:default => config.default_value,+]
# 
# The model <code>ColumConfig</code> have a serialized column named <code>default_valuee</code>, in this way we can sotre integer values, boolean, strings or datetime and time values without problems.
# 
#     [+:validate => get_validation(config.validation)+]
# 
# This line execute the function <code>get_validation</code> to get a <code>Proc</code> with the validation code.
# This function can use a case/when for select the correct function or use the data of the model <code>config</code> to create a function.
# 
#     [+columns+]
# 
# Finally we return the colums configuration.
module ExtendModelAt
  # [Module::included](http://ruby-doc.org/core-1.9.3/Module.html#method-i-included)
  def self.included(base)
    base.extend(ClassMethods)
  end

  class InvalidColumn < Exception # :nodoc:
  end

  class ArgumentError < Exception # :nodoc:
  end

  # The object who control the data
  class Extention
    # Initizlize the configuration and the model mannager
    def initialize(options={})
      @configuration = ExtendModelAt::Configuration.new.run options, options[:model].clone
      @model_manager = ::ExtendModelAt::ModelManager.new(@configuration[:column_name].to_s, options[:model], @configuration)

      @static = @configuration[:static] || false
      @model = @configuration[:model].clone
      @column_name = @configuration[:column_name].to_s
      @columns = @configuration[:columns]
      @value = get_defaults_values @configuration

      define_associations

      initialize_values
    end

    # Get the value of the extended colum called [+key+]
    def [](key)
      @model_manager.get_value(key)
    end

    # Set the value of the extended colum called [+key+] with the value [+value+]
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

    # This class(+Extention+) respond to all methods, unknown methos are used to access to the extended colums
    def self.respond_to?(symbol, include_private=false)
      true
    end

    # This class(+Extention+) respond to all methods, unknown methos are used to access to the extended colums
    def respond_to?(symbol, include_private=false)
      true
    end

    # Return an array with all values
    #   User.extend.all_values # => [23, "Bob", "bob@mysite.com"]
    def all_values
      @model_manager.all_values
    end
    
    # Return an array with all column names
    #   User.extend.all_names # => ["age", "name", "email"]
    def all_names
      @model_manager.all_names
    end

    # Return a hash with all column names and values
    #   User.extend.all_hash # => {:age => 23, :name => "Bob", :email => "bob@mysite.com"}
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

    # Return the configuration like a hash
    def configuration
      @configuration
    end

    # Set the configuration
    def configuration=(value)
      @configuration = value
    end

    # Create all model relationships with the user configuration (has_many, has_one and belongs_to)
    def define_associations   
      [:has_one, :has_many, :belongs_to].each do |relation|
        if @configuration.keys.include? :"#{relation}"
          raise "Invalid #{relation} value" if not [Hash, Array, Symbol].include? @configuration[:"#{relation}"].class
          # We nee an array of models, then, we 
          if @configuration[:"#{relation}"].kind_of? Hash
            list_models = @configuration[:"#{relation}"].keys
          elsif @configuration[:"#{relation}"].kind_of? Array
            list_models = @configuration[:"#{relation}"]
          else
            list_models = [@configuration[:"#{relation}"]]
          end
          list_models.each do |model|
              meta_def model.to_s do |force_reload=false|
                if @configuration[:"#{relation}"].kind_of? Hash
                  config = @configuration[:"#{relation}"][model]
                else
                  config = {}
                end
                eval "@model_manager.read_#{relation} model, config, force_reload"
              end

            if "#{relation}" != "has_many"
              meta_def "#{model.to_s}=" do |associate|
                if @configuration[:"#{relation}"].kind_of? Hash
                  config = @configuration[:"#{relation}"][model]
                else
                  config = {}
                end
                eval "@model_manager.write_#{relation} model, @configuration[:#{relation}][model], associate"
                true
              end

              meta_def "build_#{model.to_s}" do |attributes={}|
                if @configuration[:"#{relation}"].kind_of? Hash
                  config = @configuration[:"#{relation}"][model]
                else
                  config = {}
                end
                eval "@model_manager.build_#{relation} model, config, attributes"
                true
              end

              meta_def "create_#{model.to_s}" do |attributes={}|
                if @configuration[:"#{relation}"].kind_of? Hash
                  config = @configuration[:"#{relation}"][model]
                else
                  config = {}
                end
                eval "@model_manager.create_#{relation} model, config, attributes"
                true
              end
            end
          end
        end
      end
    end

    ##########
    # Meta functions
    
    def metaclass # :nodoc:
      class << self; self; end;
    end
    
    def meta_eval(&blk) # :nodoc:
      metaclass.instance_eval &blk
    end

    def meta_def(name, &blk) # :nodoc:
      meta_eval { define_method name, &blk }
    end

    def class_def name, &blk # :nodoc:
      class_eval { define_method name, &blk }
    end

    ##### Meta functions #####

    # Return the correct method used to transform the column value the correct Ruby class
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

    # Initialize all columns with +nil+
    #--
    # NOTE: Maybe depercated
    #++
    def initialize_values
      if not @value.kind_of? Hash
        @model.attributes[@column_name] = {}.to_yaml
        @model.save
      end
    end

    # Get all default values
    def get_defaults_values(options = {})
      defaults_ = {}
      options[:columns].each do |column, config|
        defaults_[column.to_s] = @columns[column.to_sym][:default] || nil
      end
      defaults_
    end

    # Update the model manager
    def update_model_manager
      @model_manager.send :update
    end

    # Return true if the value is valid for the type
    def valid_type?(value, type)
      @model.send :valid_type?, value, type
    end

    # Used to use scopes
    def search(column, method, value)
      @model_manager.send:search, column, method, value
    end
  end

  # This class will extend the Ruby on Rails model.
  # = Rewrite
  # * +assign_attributes+
  # * +[]+
  # * +[]=+
  # * +self.respond_to?+
  # * +respond_to?+
  # * +self.method_missing+
  # * +method_missing+
  # = New methos
  # * +search_in_extention+
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

      # Main extention
      self.class_eval <<-EOS
        eval assign_attributes_eval
      EOS

      # More extentions.
      # Add the ExtendAt validation process and define the method to extend the columns.
      class_eval do
      public
        validate :extend_at_validations
        after_save :update_model_manager, :on => :create

        define_method(column_name.to_s) do
          if not @extend_at_configuration.kind_of? ExtendModelAt::Extention
            options[:model] = self.clone
            @extend_at_configuration = ExtendModelAt::Extention.new(options )
            initialize_columns @extend_at_configuration.send(:configuration)[:columns] || {}
          end
          @extend_at_configuration
        end

      protected

        # ExtendAt validation process
        def extend_at_validations
#           @extend_at_configuration.valid?
          @extend_at_validation ||= {} if not @extend_at_validation.kind_of? Hash
          @extend_at_validation.each do |column, validation|
            if validation.kind_of? Symbol
              self.send validation, eval("@extend_at_configuration.\#\{column.to_s\}", binding)
            elsif validation.kind_of? Proc
              instance_exec @extend_at_configuration[column.to_sym], &validation
            end
          end
        end

        def set_extend_at_validation(value={}) # :nodoc:
          @extend_at_validation # NOTE FIXME ????
        end

        def update_model_manager # :nodoc:
          @extend_at_configuration.send :update_model_manager if @extend_at_configuration.respond_to? :update_model_manager
        end

        # Initialize each column configuration
        def initialize_columns(columns = {})
            colunms_config = {}
            columns.each do |column, config|
              colunms_config[column.to_sym] = initialize_column column, config
            end
            colunms_config
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
          else
            raise ExtendModelAt::ArgumentError, "\#\{config[:type]\} is not a valid column type"
          end

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
          @extend_at_validation ||= {}
          @extend_at_validation[column] = validation
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
        ((not [:boolean, nil].include?(type)) and not value.nil? and compatible_type value, type )
    end
      end
    end
  end
end

ActiveRecord::Base.class_eval { include ExtendModelAt }