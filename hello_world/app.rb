require "bundler/setup"
Bundler.require

require './amagift.rb'

SLACK_INCOMING_WEBHOOK_URL = ENV['SLACK_INCOMING_WEBHOOK_URL']

def lambda_handler(event:, context:)
  amagift = Amagift.new
  amagift.scrape!
  amagift.set_attributes!
  text = amagift.formatted_text
  to_slack(text)
end

def to_slack(formatted_text)
  notifier = Slack::Notifier.new(SLACK_INCOMING_WEBHOOK_URL)
  attachments = {
    fallback: 'This is article notifier attachment',
    title: "#{Time.current.to_s(:db)} 時点の最安レート",
    title_link: Amagift::BASE_URL,
    text: formatted_text,
    color: '#036635'
  }
  notifier.post(attachments: attachments)
end
