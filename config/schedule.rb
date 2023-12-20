# frozen_string_literal: true

every 1.day, at: '5:00 pm' do
  rake 'custom_tasks:send_reorder_emails'
end
