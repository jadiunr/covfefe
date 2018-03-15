require "twitter"
require "redis"
require_relative "lib/slack_post"
require "yaml"

yaml = YAML.load_file("config/setting.yml")
redis = Redis.new(yaml["redis"])
client = Twitter::Streaming::Client.new do |config| 
  config.consumer_key        = yaml["twitter_auth"]["consumer_key"]
  config.consumer_secret     = yaml["twitter_auth"]["consumer_secret"]
  config.access_token        = yaml["twitter_auth"]["access_token"]
  config.access_token_secret = yaml["twitter_auth"]["access_token_secret"]
end

client.filter(follow: yaml["target_id"]) do |tweet|
  case tweet
  when Twitter::Tweet
    redis.set tweet.id, tweet.full_text
  when Twitter::Streaming::DeletedTweet
    slack_post yaml["slack"]["token"], yaml["slack"]["channel"], redis.get(tweet.id)
  end
end
