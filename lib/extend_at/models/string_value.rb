class StringValue < ActiveRecord::Base
  set_table_name "extend_at_strings"
  belongs_to :extend_at, :class_name => 'ExtendAt'
end
 