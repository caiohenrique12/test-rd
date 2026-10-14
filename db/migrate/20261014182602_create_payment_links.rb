class CreatePaymentLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :payment_links do |t|
      t.references :account, type: :string, null: false, foreign_key: true, index: true
      t.string :public_id, null: false
      t.string :url_token, null: false
      t.string :status, null: false, default: "active"
      t.string :description, null: false
      t.integer :amount_cents, null: false
      t.string :currency, null: false

      t.timestamps

      t.index :public_id, unique: true
      t.index :url_token, unique: true
    end
  end
end
