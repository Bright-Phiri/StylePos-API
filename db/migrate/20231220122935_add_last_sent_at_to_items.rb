class AddLastSentAtToItems < ActiveRecord::Migration[7.0]
  def change
    add_column :items, :last_sent_at, :datetime, default: nil
  end
end
