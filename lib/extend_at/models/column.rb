class Column < ActiveRecord::Base
  self.table_name = "extend_at_columns"
  belongs_to :column, :polymorphic => true
  belongs_to :extend_at, :class_name => 'ExtendAt'
  scope :for_model, lambda { |model|
    where(:model_id => model.try(:id) || model.to_i)
  }
end
 
