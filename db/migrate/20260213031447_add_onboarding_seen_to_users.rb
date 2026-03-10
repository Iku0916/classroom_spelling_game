# frozen_string_literal: true

class AddOnboardingSeenToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :onboarding_seen, :boolean
  end
end
