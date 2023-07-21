class AddBlobAndPhotosToDocs < ActiveRecord::Migration[7.0]
  def change
    add_column :docs, :blob, :string 
    create_table :photos do |t| 
      t.references :doc, foreign_key: true 
      t.string :filename 
      t.timestamps
    end
  end
end
