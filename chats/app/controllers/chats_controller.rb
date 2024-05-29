class ChatsController < ApplicationController
  include QueryHandler

  rescue_from  ArgumentError do |e|
    render json: { error: e.message }, status: :bad_request
  end

  before_action :prepare_params
  before_action :validate_search_params, only: :index
  before_action :validate_update_params, only: :update

  def index
    @chats, @next_page_token = Chat.paginate(@app_token, @page_token, @limit)
    @next_page_token = Base64.encode64(@next_page_token.to_s).strip if @next_page_token

    render json: {
      chats: ActiveModelSerializers::SerializableResource.new(@chats),
      pagination: {
        next_page_token: @next_page_token,
        total_count: @chats.size
      }
    }, status: :ok
  end

  def update
    begin
      # @chat = Chat.where(app_token: @app_token, chat_num: @chat_num).update_all(chat_params)
      # update_all issues a single update query without making a select query, thus it's more efficient
      # however, it doesn't return the updated record, if this is acceptable, we can use it for better performance
      
      @chat = Chat.find_by!(app_token: @app_token, chat_num: @chat_num)
      @chat.update!(chat_params)
      render json: @chat, status: :ok

    rescue ActiveRecord::RecordNotFound 
      render json: { error: 'Chat not found' }, status: :not_found
    rescue ActiveRecord::RecordInvalid  
      render json: { error: 'Update failed' }, status: :unprocessable_entity
    end
  end

  private

  def chat_params
    params.require(:chat).permit(:name)
  end

  def prepare_params
    @app_token = params[:app_token]
  end

  def validate_update_params
    @chat_num = Integer(params[:chat_num])
    raise ArgumentError, 'chat number must be a positive number' if @chat_num <= 0
    raise ArgumentError, 'chat name is required' unless params[:chat][:name].present?
  end

  def validate_search_params
    @page_token = @page_token ? Integer(@page_token) : 1
    raise ArgumentError, 'Invalid page token' if @page_token <= 0
  end
end