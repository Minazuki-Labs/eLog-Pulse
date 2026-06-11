class CreateOtpCodes < ActiveRecord::Migration[8.1]
  def change
    create_table :otp_codes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token
      t.datetime :expires_at

      t.timestamps
    end
  end
end
