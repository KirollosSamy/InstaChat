# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# db/seeds.rb

# Regenerate seeds
2.times do |index|
  application = Application.create(
    name: Faker::App.name,
    app_token: SecureRandom.urlsafe_base64(10)
  )

  3.times do |chat_index|
    chat = Chat.create(
      app_token: application.app_token,
      chat_num: chat_index + 1, 
      name: Faker::Lorem.words(number: 2).join(' ')
    )

    10.times do |message_index|
      Message.create(
        app_token: application.app_token,
        chat_num: chat.chat_num,
        message_num: message_index + 1,
        messaged_at: Faker::Time.between(from: DateTime.now - 1, to: DateTime.now),
        content: Faker::Lorem.sentence,
        messaged_by: Faker::Name.name
      )
    end
  end
end