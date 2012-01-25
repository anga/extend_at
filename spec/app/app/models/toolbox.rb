class Toolbox < ActiveRecord::Base
  extend_at :extra, :columns => { :name => { :type => :string }}, :has_many => :tools
end
