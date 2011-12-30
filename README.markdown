# Acts as configuration

This *acts_as* extension provides the capabilities for transform a *string* or *text* column to a configuration variable.

## Installation

<code>gem install acts_as_configuration</code>

### Rails 3
Add in your Gemfile:
<code>gem 'acts_as_configuration', :git => 'git://github.com/anga/acts_as_configuration.git'</code>

## Usage

Only you need to add the next line in your model.

<code>acts_as_configuration :configuration</code>

For example:

    class User < ActiveRecord::Base
      acts_as_configuration :config
    end

Now you can write your configuration like:

    user.config.private_photos = true
    user.config.subscribe_to_news = false
    user.config.perfil_description = ''
    user.save

### Columns configuration

You can configurate each column.

#### Set column type

You can set the type of the colum.

    class User < ActiveRecord::Base
      acts_as_configuration :config, :columns => {
        :private_photos => {
          :type => :boolean
        }, :age => {
          :type => :get_type
        }, :perfil_description => {
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
      acts_as_configuration :config, :columns => {
        :private_photos => {
          :type => :boolean,
          :default => true
        }, :age => {
          :type => :get_type,
          :default => 1
        }, :perfil_description => {
          :type => lambda {
            String
          },
          :default => :get_default_perfil_description
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

      def get_default_perfil_description
        Description.where(:user_id => self.id).default
      end
    end

#### Set validation
    class User < ActiveRecord::Base
      acts_as_configuration :config, :columns => {
        :private_photos => {
          :type => :boolean,
          :default => true
        }, :age => {
          :type => :get_type,
          :default => 1,
          :validate => lambda {
            |age|
            errors.add :config_age, "You are Matusalén?" if age > 150
            errors.add :config_age, "You're a fetus?" if age <= 0
          }
        }, :perfil_description => {
          :type => lambda {
            String
          },
          :default => :get_default_perfil_description,
          :lambda => :must_not_have_strong_language
        }, :last_loggin => {
          :type => Time.now.class,
          :default => lambda {
            self.created_at.time
          },
          :validate => lambda {
            |time|
            errors.add :config_last_loggin, "You can't loggin in the future" if time > Time.now
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

      def get_default_perfil_description
        Description.where(:user_id => self.id).default
      end

      def must_not_have_strong_language(desc)
        errors.add :cofig_perfil_description, "You must not have strong language" if desc =~ /(#{STRONG_WORD.join('|')})/
      end
    end
