class IntegerValue < ActiveRecord::Base
  self.table_name = "extend_at_integers"
  belongs_to :extend_at_column, :class_name => 'Column', :foreign_key => 'extend_at_column_id'
end
