class AddPhotosToDocs < ActiveRecord::Migration[5.2]
  def change 
    create_table :photos do |t|
      t.string :caption 
      t.references :doc, foreign_key: true 

      t.timestamps
    end
  end
end