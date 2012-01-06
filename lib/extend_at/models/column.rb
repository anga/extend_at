class Column < ActiveRecord::Base
  set_table_name "extend_at_columns"
  belongs_to :extend_at
  belongs_to :column, :polymorphic => true
  belongs_to :extend_at, :class_name => 'ExtendAt'
end
 
