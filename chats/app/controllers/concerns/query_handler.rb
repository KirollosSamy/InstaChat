module QueryHandler
  extend ActiveSupport::Concern

  included do
    before_action :set_pagination, only: [:index]
    # before_action :apply_filters, only: [:index]
    # before_action :apply_sorting, only: [:index]
  end

  private

  def set_pagination
    @page_token = params[:next_page_token].present? ? Base64.decode64(params[:next_page_token]) : nil
    @limit = params[:limit] || '10'
    @limit = Integer(@limit)
    raise ArgumentError, 'limit must be a positive number' if @limit <= 0
  end

  # def apply_filters
  #   @filters = {}
  #   Application::FILTER_PARAMS.each do |filter_param|
  #     if params[filter_param]
  #       @filters[filter_param] = params[filter_param]
  #     end
  # end

  # def apply_sorting
  #   if params[:sort_by]
  #     @sort_by = params[:sort_by]
  #     params[:sort_by].split(',').all? { |sort_param| Application::SORT_PARAMS.include?(sort_param.strip.to_sym) }
  #   end
  # end
end
