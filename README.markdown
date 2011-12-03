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
      acts_as_configuration :configuration
    end

Now you can write your configuration like:

    user.configuration.private_photos = true
    user.configuration.subscribe_to_news = false
    user.configuration.perfil_description = ''
    user.save

### Defaults values

You can add defaults values easily doing this:

    class User < ActiveRecord::Base
      acts_as_configuration :configuration, :defaults => { :private_photos => true, :subscribe_to_news => false, :perfil_description => ''}
    end

But if you like to put the defaults values in a yaml file, you can do this:

    class User < ActiveRecord::Base
      acts_as_configuration :configuration, :file => File.join(Rails.root, 'config', 'user_defaults.yaml')
    end

And in config/user_defaults.yaml:

    ---
    private_photos: true
    subscribe_to_news: false
    perfil_description: ''
