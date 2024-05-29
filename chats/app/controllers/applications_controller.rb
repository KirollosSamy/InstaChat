class ApplicationsController < ApplicationController
  def index
    @applications = Application.select(Application.column_names - Application::DISALLOWED_COLUMNS).all
    render json: @applications, status: :ok
  end

  def create
    @app_token = generate_app_token
    @application = Application.new(application_params.merge(app_token: @app_token))

    if @application.save
      render json: @application, status: :created
    else
      remove_app_token(@app_token)
      render json: @application.errors, status: :unprocessable_entity
    end
  end

  def update
    @app_token = params[:app_token]
    begin
      @application = Application.find_by!(app_token: @app_token)
      @application.update!(application_params)
      render json: @application
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Application not found' }, status: :not_found
    rescue ActiveRecord::RecordInvalid
      render json: { error: 'Invalid update request' }, status: :unprocessable_entity
    end
  end

  private

  # The probability that two tokens are the same is extremely low and can be ignored,
  # also the number of tokens generated is not expected to be large (in contrast to the number of messages for example),
  # thus no need to check if the token already exists or handle potential race conditions here.
  # However, if we want to be extra cautious, we can use the code below
  # It keeps track of all generated tokens in a Redis set and atomically adds the token to the set if it doesn't exist.
  def generate_app_token
    loop do
      app_token = SecureRandom.urlsafe_base64(10)
      # Set the token in Redis if it doesn't exist to be used for checking that the app exists
      # When creating new chats from chat_dispatchers service
      if REDIS.hset(REDIS_APP_TOKENS_KEY, app_token, 0) == 1
        return app_token
      end
    end

    # REDIS.hset(REDIS_APP_TOKENS_KEY, app_token, 0)
    # SecureRandom.urlsafe_base64(10)
  end

  def remove_app_token(app_token)
    REDIS.hdel(REDIS_APP_TOKENS_KEY, app_token)
  end

  def application_params
    params.require(:application).permit(:name)
  end
end
