class IntegerValue < ActiveRecord::Base
  set_table_name "extend_at_integers"
  belongs_to :extend_at, :class_name => 'ExtendAt'
end
