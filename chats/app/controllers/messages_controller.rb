class MessagesController < ApplicationController
  include QueryHandler

  rescue_from  ArgumentError do |e|
    render json: { error: e.message }, status: :bad_request
  end

  before_action :prepare_params
  before_action :validate_search_params, only: :index
  before_action :validate_update_params, only: :update
  before_action :validate_query_params, only: :search

  def index
    @messages, @next_page_token = Message.paginate(@app_token, @chat_num, @page_token, @limit)
    @next_page_token = Base64.strict_encode64(@next_page_token.to_json).strip if @next_page_token

    render json: {
      messages: ActiveModelSerializers::SerializableResource.new(@messages),
      pagination: {
        next_page_token: @next_page_token,
        total_count: @messages.size
      }
    }, status: :ok
  end

  def update
    begin
      # @message = Message.where(app_token: @app_token, chat_num: @chat_num, message_num: @message_num)
      #                   .update_all(message_params)
      # update_all issues a single update query without making a select query, thus it's more efficient
      # however, it doesn't return the updated record, if this is acceptable, we can use it for better performance
      
      @message = Message.find_by!(app_token: @app_token, chat_num: @chat_num, message_num: @message_num)
      @message.update!(message_params)
      render json: @message, status: :ok

    rescue ActiveRecord::RecordNotFound 
      render json: { error: 'Message not found' }, status: :not_found
    rescue ActiveRecord::RecordInvalid  
      render json: { error: 'Update failed' }, status: :unprocessable_entity
    end
  end

  def search
    query = Message.build_query(query_params)
    @messages = Message.search(query)
    render json: @messages
  end

  private

  def query_params 
    {
      chat_num: @chat_num,
      app_token: @app_token,
      q: @q,
      sort_by: @sort_by,
      page: @page,
      limit: @limit
    }
  end

  def message_params
    params.require(:message).permit(:content, :messaged_by)
  end

  def prepare_params
    @app_token = params[:app_token]
    @chat_num = Integer(params[:chat_num])
  end

  def validate_update_params
    @message_num = Integer(params[:message_num])
    raise ArgumentError, 'message_num must be a positive number' if @message_num <= 0
  end

  def validate_search_params
    begin
      @page_token = @page_token ? JSON.parse(@page_token, symbolize_names: true) : { messaged_at: Time.at(0), message_num: 1 }
      @page_token[:messaged_at] = Time.parse(@page_token[:messaged_at]) if @page_token[:messaged_at].is_a?(String)
      raise ArgumentError if Integer(@page_token[:message_num]) <= 0
    rescue JSON::ParserError
      render json: { error: 'Invalid page token' }, status: :bad_request
    end
  end

  def validate_query_params
    @page = params[:page] ? Integer(params[:page]) : 1
    raise ArgumentError, 'page must be a positive number' if @page <= 0

    @limit = params[:limit] ? Integer(params[:limit]) : 10
    raise ArgumentError, 'limit must be a positive number' if @limit <= 0 

    @sort_by = params[:sort_by] || "messaged_at"
    raise ArgumentError, 'invalid sort params ' unless Message::VALID_SORT_BY.include?(@sort_by)

    @q = params[:q]
    raise ArgumentError, 'q must not be empty' if @q.blank?
  end
end


