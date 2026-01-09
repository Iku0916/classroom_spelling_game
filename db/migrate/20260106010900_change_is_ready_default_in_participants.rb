class ChangeIsReadyDefaultInParticipants < ActiveRecord::Migration[7.1]
  def change
    change_column_default :participants, :is_ready, from: nil, to: false
    change_column_null :participants, :is_ready, false, false
  end
end
