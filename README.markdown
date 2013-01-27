# Extend at

This gem allows you to extend models without migrations: This way you can, i.e., develop your own content types, like in Drupal.

For example, if you want to create an administration panel to add columns to a model, for example, you are working on
a CMS, and you want to create a _"content type"_ and you need to set the _"columns"_ but you
don't want to migrate the database, then, you can see [this](https://github.com/anga/extend_at#tips) little tutorial.

## Status:

[![Build Status](https://secure.travis-ci.org/anga/extend_at.png)](http://travis-ci.org/anga/extend_at)

## Installation

<code>gem install extend_at</code>

### Rails 3
Add in your Gemfile:

<code>gem 'extend_at'</code>

After that, you need execute:

<code>rails generate extend_at:install</code>

This will generate one migration with all necessary tables. Now you need migrate your database.

<code>rake db:migrate</code>

## Usage

You don't need an extra column in your model. Only you need is put next code in your model.

<code>extend_at :extra</code>

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

##### Valid types

Valid symbols:

* <code>:any</code>
* <code>:binary</code>
* <code>:boolean</code>
* <code>:date</code>
* <code>:datetime</code>
* <code>:decimal</code>
* <code>:float</code>
* <code>:integer</code>
* <code>:string</code>
* <code>:text</code>
* <code>:time</code>
* <code>:timestamp</code>

But you can use classes.

* Float: <code>:any</code>
* Fixnum: <code>:integer</code>
* String: <code>:text</code>
* Time: <code>:timestamp</code>
* Date: <code>:datetime</code>

Else, return <code>:any</code>

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

### Static columns

If you like to restrict the existent extended columns, you should use <code>:static => true</code>

    class User < ActiveRecord::Base
      extend_at :extra, :columns => {
        :private_photos => {
          :type => :boolean,
          :default => true
        }
      }, :static => true
    end

Now, <code>User.extra</code> only accept <code>private_photos</code> column

### Scopes

You can use scope like:

    User.extra_last_loggin_gt_eq(1.week.ago).extra_age_gt_eq(18).where(:column => "value").all

Valid scopes:

    <extention>_<column_name>_<comparation>

Comparations:

* lt
* lt_eq
* eq
* gt_eq
* gt
* match

### Belongs to

If you like to add a belongs_to relationship, you can do it in this way:

    # app/models/toolbox.rb
    class Toolbox
    end

    # app/model/tool.rb
    class Tool
      extend_at extra, columns => {}, :belongs_to => :toolbox
    end

<code>:belongs_to</code> parametter accept

* One name

  :belongs_to => :toolbox
  
* Array of names

  :belongs_to => [:toolbox, :owner]

* Hash

  :belongs_to => {:onwer => {:class_name => "User"}}

For now, hash only accept

* class_name
* polymorphic
* foreign_key

_Note_, this new feature is under heavy development, use it under your own risk.
  

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

### More

For more documentation go to [wiki](https://github.com/anga/extend_at/wiki "extend_at wiki").

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
            :validate => get_validation(config)
          }
        end
        
        columns
      end

      # Accept a name of a validation and return the Proc with the validation code
      def get_validation(validation_type)
        # ...
      end
    end

How works?
    
    serialize :columns_name
    
This make <code>columns_name</code> column work like YAML serialized object. In this case, is used to sotore an array of names of each column name. 
(See [ActiveRecord::Base](http://api.rubyonrails.org/classes/ActiveRecord/Base.html))

    extend_at :extra, :columns => :get_columns
    
This line will use the function <code>get_columns</code> to get the information about each column dynamically.
This function returns a hash with the information about each column.

    columns_name.each do |name|
        #...
    end
    
Iterate through each column stored in the column <code>columns_name</code>.

    config = ColumConfig.where(:user_id => self.id, :column => name).first

Search the column configuration stored in a separated model. By this way, we can configura each column easily, we can create a view to create columns and configure it easily.

    columns[name.to_sym] = {
        :type => eval(config.class_type),
        :default => config.default_value,
        :validate => get_validation(config)
      }

This lines configure the column.

    :type => eval(config.class_type),
    
The model <code>ColumConfig</code> have a string column named <code>class_type</code>, can be <code>":integer"</code> or <code>"Fixnum"</code>.

    :default => config.default_value,
    
The model <code>ColumConfig</code> have a serialized column named <code>default_valuee</code>, in this way we can sotre integer values, boolean, strings or datetime and time values without problems.

    :validate => get_validation(config.validation)
    
This line execute the function <code>get_validation</code> to get a <code>Proc</code> with the validation code.
This function can use a case/when for select the correct function or use the data of the model <code>config</code> to create a function.

    columns
    
Finally we return the colums configuration.

## Bugs, recomendation, etc

If you found a bug, create an issue. If you have a recomendation, idea, etc., create a request or fork the project.

## License

This gem is under MIT license.
