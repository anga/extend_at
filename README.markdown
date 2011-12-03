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

<pre>
  class User < ActiveRecord::Base
    acts_as_configuration :configuration
  end
</pre>

Now you can write your configuration like:

<pre>
  user.configuration.private_photos = true
  user.configuration.subscribe_to_news = false
  user.configuration.perfil_description = ''
  user.save
</pre>

### Defaults values

You can add defaults values easily doing this:

<pre>
  class User < ActiveRecord::Base
    acts_as_configuration :configuration, :defaults => { :private_photos => true, :subscribe_to_news => false, :perfil_description => ''}
  end
</pre>

But if you like to put the defaults values in a yaml file, you can do this:

<pre>
  class User < ActiveRecord::Base
    acts_as_configuration :configuration, :file => File.join(Rails.root, 'config', 'user_defaults.yaml')
  end
</pre>

And in config/user_defaults.yaml:
<pre>
  ---
  private_photos: true
  subscribe_to_news: false
  perfil_description: ''
</pre>
