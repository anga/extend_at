class User < ActiveRecord::Base
  extend_at :private_info, :columns => (lambda do
    {
      :real_name => {
        :type => String,
        :default => 'Real name'
      },
      :real_last_name => {
        :type => :string
      },
      :born => {
        :type => Time
      }
    }
  end)
end
