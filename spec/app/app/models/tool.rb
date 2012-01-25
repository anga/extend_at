class Tool < ActiveRecord::Base
  extend_at :extra, :columns => {}, :belongs_to => :toolbox
end
