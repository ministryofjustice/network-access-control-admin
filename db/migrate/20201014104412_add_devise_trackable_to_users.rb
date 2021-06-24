# frozen_string_literal: true

class AddDeviseTrackableToUsers < ActiveRecord::Migration[6.0]
  def change
    ## Devise Trackable columns
    add_column :users, :sign_in_count, :integer, default: 0, null: false
    add_column :users, :current_sign_in_at, :datetime
    add_column :users, :last_sign_in_at, :datetime
    add_column :users, :current_sign_in_ip, :string
    add_column :users, :last_sign_in_ip, :string
    add_column :users, :email, :string
  end
end
