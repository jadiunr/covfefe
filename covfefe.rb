require "twitter"
require "redis"
require_relative "lib/slack_api"
require "yaml"
require "json"

yaml = YAML.load_file("config/setting.yml")
redis = Redis.new(yaml["redis"])
slack = SlackAPI.new(token: yaml["slack"]["token"],
                     channel: yaml["slack"]["channel"])
client = Twitter::Streaming::Client.new do |config|
  config.consumer_key        = yaml["twitter_auth"]["consumer_key"]
  config.consumer_secret     = yaml["twitter_auth"]["consumer_secret"]
  config.access_token        = yaml["twitter_auth"]["access_token"]
  config.access_token_secret = yaml["twitter_auth"]["access_token_secret"]
end

begin
  client.filter(follow: yaml["target_id"]) do |tweet|
    case tweet
    when Twitter::Tweet then
      imgs_uri = tweet.media.map { |m| m.media_uri } unless tweet.media.empty?
      redis.set tweet.id, { name: tweet.user.name,
                            text: tweet.full_text,
                            date: tweet.created_at,
                            imgs_uri: imgs_uri || nil }.to_json
    when Twitter::Streaming::DeletedTweet then
      t = redis.get(tweet.id)
      unless t.nil?
        deleted_tweet = JSON.parse(t)
        slack.post "#{deleted_tweet["name"]}\n#{deleted_tweet["text"]}\n#{deleted_tweet["date"]}"
        slack.upload deleted_tweet["imgs_uri"] unless deleted_tweet["imgs_uri"].nil?
      end
    else
      # no-op
    end
  end
rescue EOFError => e
  puts "は？"
  puts "#{e.class} #{e.message}"
  retry
end