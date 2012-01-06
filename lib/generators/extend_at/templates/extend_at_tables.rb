class ExtendAtTables < ActiveRecord::Migration
  def up
    create_table :extend_ats do |t|
      t.references :model, :polymorphic => true
    end
    
    create_table :extend_at_integers do |t|
      t.belongs_to :extend_at_column
      t.string :column
      t.integer :value
    end

    create_table :extend_at_floats do |t|
      t.belongs_to :extend_at_column
      t.string :column
      t.text :value
    end

    create_table :extend_at_strings do |t|
      t.belongs_to :extend_at_column
      t.string :column
      t.string :value
    end

    create_table :extend_at_texts do |t|
      t.belongs_to :extend_at_column
      t.string :column
      t.string :value
    end

    create_table :extend_at_anies do |t|
      t.belongs_to :extend_at_column
      t.string :column
      t.text :value
    end

    create_table :extend_at_columns do |t|
      t.belongs_to :extend_at
      t.belongs_to :column, :polymorphic => true
    end
  end

  def down
    drop_table :extend_at
    drop_table :extend_at_integers
    drop_table :extend_at_floats
    drop_table :extend_at_strings
    drop_table :extend_at_texts
    drop_table :extend_at_anies
  end
end
