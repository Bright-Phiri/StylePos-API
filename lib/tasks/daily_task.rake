# frozen_string_literal: true

# lib/tasks/daily_task.rake
namespace :custom_tasks do
  desc 'Check inventory levels and send reorder emails'
  task :send_reorder_emails => :environment do
    items_to_process = Item.joins(:inventory_level).where('inventory_levels.quantity <= inventory_levels.reorder_level').where(last_sent_at: nil).find_each(batch_size: 500)
    Rails.logger.info("Items : #{items_to_process.size}")
    items_to_process.each do |item|
      ItemMailer.with(item: item).reorder_email.deliver_later
      item.update(last_sent_at: Time.current)
    end
  end
end
