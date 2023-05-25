class CreateDataSorts < ActiveRecord::Migration[7.0]
  def change
    create_table :data_sorts do |t|

      t.timestamps
    end
  end
end
