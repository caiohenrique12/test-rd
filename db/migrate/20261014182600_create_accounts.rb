class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts, id: :string do |t|
      t.boolean :credentialed, null: false, default: false
    end
  end
end
