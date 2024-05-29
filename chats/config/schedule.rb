# Define the cron job schedule to update chats_count and messages_count

every 1.minutes do
    runner "UpdateCountsJob.perform_now"
end
