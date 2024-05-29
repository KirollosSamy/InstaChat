# frozen_string_literal: true

class CreateChatConsumer < ApplicationConsumer

  def consume
    messages.each do |message|
      job = message.payload
      job = job.deep_symbolize_keys
      
      begin
        @body = job[:request][:body]
        @app_token = job[:request][:vars][:app_token]

        Chat.create!(chat_params)

      rescue ActiveRecord::InvalidForeignKey => e
        Karafka.logger.error "Application [#{@app_token}] not found: #{e.message}"
      rescue ActiveRecord::RecordInvalid => e
        Karafka.logger.error "Invalid chat params: #{e.message}"
      rescue StandardError => e
        Karafka.logger.error "An unexpected error occurred: #{e.message}"
      end
    end
  end

  def chat_params
    @body[:chat].merge!(app_token: @app_token)
    params = ActionController::Parameters.new(@body)
    params.require(:chat).permit(:name, :chat_num, :app_token)
  end

  # Run anything upon partition being revoked
  # def revoked
  # end

  # Define here any teardown things you want when Karafka server stops
  # def shutdown
  # end
end
