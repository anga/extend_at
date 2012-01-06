class AnyValue < ActiveRecord::Base
  set_table_name "extend_at_anies"
  belongs_to :extend_at, :class_name => 'ExtendAt'
end
 
