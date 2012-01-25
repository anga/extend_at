class CreateToolboxes < ActiveRecord::Migration
  def change
    create_table :toolboxes do |t|
      t.string :name

      t.timestamps
    end
  end
end
