class CreateDocTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :doc_types do |t|
      t.string :name

      t.timestamps
    end

    remove_table :doc_types
  end
end
