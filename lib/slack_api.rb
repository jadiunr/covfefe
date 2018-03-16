require "slack"
require "faraday"
require "open-uri"

class SlackAPI
  def initialize(token: :token, channel: :channel)
    Slack.configure do |config|
      config.token = token
    end
    @channel = channel
  end

  def post(tweet)
    Slack.chat_postMessage(
      channel: @channel,
      text: tweet
    )
  end

  def upload(imgs_uri)
    imgs_uri.each do |img_uri|
      file = open(img_uri)
      Slack.files_upload(
        file: Faraday::UploadIO.new(file, file.content_type),
        channels: @channel
      )
    end
  end
end