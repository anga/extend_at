class Article < ActiveRecord::Base
  scope :scpe, lambda {
    where(:title => "Pedro")
  }
  
  extend_at :extra, :columns => {
    :int1 => {
      :type => :get_int1_type,
      :default => 1,
      :validate => lambda do |value|
        self.errors.add :extra_int1, "Most by greater than 0" if value <= 0
      end
    },
    :int2 => :get_int2_config
  }

  protected
  def get_int1_type
    :integer
  end

  def get_int2_config
    {
      :type => lambda {
        :integer
      }
    }
  end
end
