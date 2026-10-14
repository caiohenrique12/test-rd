class CreateAccessTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :access_tokens do |t|
      t.references :account, type: :string, null: false, foreign_key: true, index: true
      t.string :token_digest, null: false, limit: 64

      t.index :token_digest, unique: true
    end
  end
end
