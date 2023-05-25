class CreateCalculatorApps < ActiveRecord::Migration[7.0]
  def change
    create_table :calculator_apps do |t|

      t.timestamps
    end
  end
end
