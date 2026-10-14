class LimitPaymentLinksDescriptionLength < ActiveRecord::Migration[8.1]
  def up
    change_column :payment_links, :description, :string, limit: 140, null: false
  end

  def down
    change_column :payment_links, :description, :string, limit: nil, null: false
  end
end
