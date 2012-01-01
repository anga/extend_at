# Extend at

This gem allows you to extend models without migrations: This way you can, i.e., develop your own content types, like in Drupal.

## Installation

<code>gem install extend_at</code>

### Rails 3
Add in your Gemfile:
<code>gem 'extend_at'</code>

## Usage

You only need to add the next line in your model.

<code>extend_at :extra</code>

The column <code>extra</code> must be string or text.

For example:

    class User < ActiveRecord::Base
      extend_at :extra
    end

Now you can create extra attributes:

    user.extra.private_photos = true
    user.extra.subscribe_to_news = false
    user.extra.profile_description = ''
    user.save

This is the same:

    user.extra_private_photos = true
    user.extra_subscribe_to_news = false
    user.extra_profile_description = ''
    user.save

Or:

    user[:extra_private_photos] = true
    user[:extra_subscribe_to_news] = false
    user[:extra_profile_description] = ''
    user.save

### Columns configuration

You can configure each column.

#### Set column type

You can set the colum's type.

    class User < ActiveRecord::Base
      extend_at :extra, :columns => {
        :private_photos => {
          :type => :boolean
        }, :age => {
          :type => :get_type
        }, :profile_description => {
          :type => lambda {
            String
          }
        }, :last_loggin => {
          :type => Time.now.class
        }, :subscribe_to_rss => :get_rss_config
      }

      protected
      def get_type
        Fixnum
      end

      def get_rss_config
        {
          :type => :boolean
        }
      end
    end

You can use any class, but if you need use boolean values, you must use :boolean.

#### Set default value

    class User < ActiveRecord::Base
      extend_at :extra, :columns => {
        :private_photos => {
          :type => :boolean,
          :default => true
        }, :age => {
          :type => :get_type,
          :default => 1
        }, :profile_description => {
          :type => lambda {
            String
          },
          :default => :get_default_profile_description
        }, :last_loggin => {
          :type => Time.now.class,
          :default => lambda {
            self.created_at.time
          }
        }, :subscribe_to_rss => :get_rss_config
      }

      protected
      def get_type
        Fixnum
      end

      def get_rss_config
        {
          :type => :boolean,
          :default => true
        }
      end

      def get_default_profile_description
        Description.where(:user_id => self.id).default
      end
    end

#### Set validation
    class User < ActiveRecord::Base
      extend_at :extra, :columns => {
        :private_photos => {
          :type => :boolean,
          :default => true
        }, :age => {
          :type => :get_type,
          :default => 1,
          :validate => lambda {
            |age|
            errors.add :extra_age, "Are you Matusalen?" if age > 150
            errors.add :extra_age, "Are you a fetus?" if age <= 0
          }
        }, :profile_description => {
          :type => lambda {
            String
          },
          :default => :get_default_profile_description,
          :lambda => :must_not_use_strong_language
        }, :last_loggin => {
          :type => Time.now.class,
          :default => lambda {
            self.created_at.time
          },
          :validate => lambda {
            |time|
            errors.add :extra_last_loggin, "You can't loggin on the future" if time > Time.now
          }
        }, :subscribe_to_rss => :get_rss_config
      }

      protected
      STRONG_WORD = [
        #...
      ]
      
      def get_type
        Fixnum
      end

      def get_rss_config
        {
          :type => :boolean,
          :default => true
        }
      end

      def get_default_profile_description
        Description.where(:user_id => self.id).default
      end

      def must_not_use_strong_language(desc)
        errors.add :cofig_profile_description, "You must not use strong language" if desc =~ /(#{STRONG_WORD.join('|')})/
      end
    end

### Integration in the views

If you like to use some configuration variable in your views you only need put the name of the input like <code>:extra_name</code>, for example:

    <% form_for(@user) do |f| %>
      ...
      <div class="field">
        <%= f.label :extra_private_photos %><br />
        <%= f.check_box :extra_private_photos %>
      </div>
      ...
    <% end %>

### Tips

If you like to do something more dynamic, like create columns and validations depending of some model or configuration, then you can do something like this:

    class User < ActiveRecord::Base
      extend_at :extra, :columns => :get_columns
      serialize :columns_name

      protected
      def get_columns
        columns = {}
        columns_name.each do |name|
          config = ColumConfig.where(:user_id => self.id, :column => name).first
          columns[name.to_sym] = {
            :type => eval(config.class_type),
            :default => config.default_value,
            :validate => get_validation(config.validation)
          }
        end
        
        columns
      end

      # Accept a name of a validation and return the Proc with the validation code
      def get_validation(validation_type)
        # ...
      end
    end

This code read the configuration of the columns when you access to the extra column.

## Bugs, recomendation, etc

If you found a bug, create an issue. If you have a recomendation, idea, etc., create a request or fork the project.

## License

This gem is under MIT license.