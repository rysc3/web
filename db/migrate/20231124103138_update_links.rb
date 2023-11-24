class UpdateLinks < ActiveRecord::Migration[6.1]
  def change
    add_column :links, :pic, :string
    add_column :links, :blob, :string
  end
end
