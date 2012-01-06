class TextValue < ActiveRecord::Base
  set_table_name "extend_at_texts"
  belongs_to :extend_at, :class_name => 'ExtendAt'
end
 
