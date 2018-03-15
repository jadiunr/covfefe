require "net/http"
require "uri"

def slack_post(token, channel, tweet)
  uri = URI.parse("https://slack.com/api/chat.postMessage")
  request = Net::HTTP::Post.new(uri)
  request.set_form_data(
    "token" => token,
    "channel" => channel,
    "text" => tweet
  )

  req_options = {
    use_ssl: uri.scheme == "https",
  }

  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
  end
end
