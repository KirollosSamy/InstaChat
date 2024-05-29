# frozen_string_literal: true


class CreateMessageConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      job = message.payload
      job = job.deep_symbolize_keys

      begin
        @body = job[:request][:body]
        @app_token = job[:request][:vars][:app_token]
        @chat_num = job[:request][:vars][:chat_num]

        # Enforcing referential integrity in the application layer (this should be done in the database layer)
        # It also add overhead to the query which hurts performance
        # Check the Message model for the rationale behind this
        Chat.find_by!(app_token: @app_token, chat_num: @chat_num)

        Message.create!(message_params)

      rescue ActiveSupport::RecordNotFound => e
        Karafka.logger.error "Chat [#{@chat_num}] in application [#{@app_token}] not found: #{e.message}"
      # rescue ActiveRecord::InvalidForeignKey => e
      #   Karafka.logger.error "Chat [#{@chat_num}] in application [#{@app_token}] not found: #{e.message}"
      rescue ActiveRecord::RecordInvalid => e
        Karafka.logger.error "Invalid chat params: #{e.message}"
      rescue StandardError => e
        Karafka.logger.error "An unexpected error occurred: #{e.message}"
      end
    end
  end

  def message_params
    @body[:message][:messaged_at] = Time.at(@body[:message][:messaged_at]).to_datetime
    @body[:message].merge!(app_token: @app_token, chat_num: @chat_num)

    params = ActionController::Parameters.new(@body)
    params.require(:message).permit(:app_token, :chat_num, :message_num, :content, :messaged_at, :messaged_by)
  end

  # Run anything upon partition being revoked
  # def revoked
  # end

  # Define here any teardown things you want when Karafka server stops
  # def shutdown
  # end
end
