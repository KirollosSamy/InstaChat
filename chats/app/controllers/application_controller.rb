class ApplicationController < ActionController::Base
    # I should probably revise this later
    skip_before_action :verify_authenticity_token
end
