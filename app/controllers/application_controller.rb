class ApplicationController < ActionController::Base
  def index
    @q = params[:q]

    return unless @q.present?

    begin
      @results = GithubSearchService.search(@q)
    rescue StandardError => e
      @error = if e.is_a?(GithubSearchService::GithubError) && e.message.present?
                 e.message
               else
                 'Unexpected error'
               end
    end
  end
end
