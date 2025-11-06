class HealthController < ApplicationController
    # index should occur without authentication
    skip_before_action :authenticate_user!, only:[:index]
    
    def index
        render json: {
        status: 'ok',
        timestamp: Time.current.iso8601
        }
    end
end
