class CreatePortfolioTrackers < ActiveRecord::Migration[7.0]
  def change
    create_table :portfolio_trackers do |t|

      t.timestamps
    end
  end
end
