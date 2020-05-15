class GithubSearchService
  API_URL = 'https://api.github.com/search/repositories'.freeze
  TIMEOUT = 10

  class GithubError < StandardError; end
  class RateLimitExceededError < GithubError; end
  class NetworkError < GithubError; end
  class ServerError < GithubError; end
  class ExecutionExpired < GithubError; end
  class ParsingError < GithubError; end
  class UnexpectedError < GithubError; end

  def self.search(query, sort: 'stars', order: 'desc')
    raw_response = HTTParty.get(API_URL, timeout: TIMEOUT, query: { q: query, sort: sort, order: order })

    check_responce_code(raw_response.code)

    transform_data(JSON.parse(raw_response.body, symbolize_names: true))
  rescue SocketError, Errno::ECONNREFUSED => e
    raise NetworkError.new, "Could not connect to the server: #{e.message}"
  rescue Net::OpenTimeout => e
    raise ExecutionExpired.new, "API server didn't respond on time: #{e.message}"
  rescue JSON::ParserError, KeyError
    raise ParsingError.new, 'API server responded with wrong data'
  end

  def self.check_responce_code(code)
    raise RateLimitExceededError.new, 'Too many search requests. Please wait 30 seconds' if code == 403
    raise ServerError.new, "API server error: #{code}" if code != 200
  end

  def self.transform_data(response)
    response.fetch(:items).map do |item|
      OpenStruct.new(
        item
          .slice(:name, :html_url, :stargazers_count)
          .merge(owner: item.dig(:owner, :login))
      )
    end
  end
end
