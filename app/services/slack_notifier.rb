require "net/http"
require "json"

# Service to send notifications to Slack
class SlackNotifier
  def self.notify_new_lead(lead)
    return unless webhook_url.present?

    property = lead.property

    payload = {
      blocks: [
        {
          type: "header",
          text: {
            type: "plain_text",
            text: "New Lead!"
          }
        },
        {
          type: "section",
          fields: [
            { type: "mrkdwn", text: "*Property:*\n#{property.address}" },
            { type: "mrkdwn", text: "*Name:*\n#{lead.name}" },
            { type: "mrkdwn", text: "*Email:*\n#{lead.email}" },
            { type: "mrkdwn", text: "*Phone:*\n#{lead.phone || 'Not provided'}" }
          ]
        },
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: "*Message:*\n#{lead.message.presence || '_No message_'}"
          }
        },
        {
          type: "actions",
          elements: [
            {
              type: "button",
              text: { type: "plain_text", text: "View Property" },
              url: "https://ocnjweeklyrentals.com/properties/#{property.slug}"
            }
          ]
        }
      ]
    }

    send_webhook(payload)
  rescue StandardError => e
    Rails.logger.error "[Slack] Failed to send notification: #{e.message}"
  end

  def self.notify_rental_request(rental_request)
    return unless webhook_url.present?

    payload = {
      blocks: [
        {
          type: "header",
          text: {
            type: "plain_text",
            text: "New Concierge Rental Request!"
          }
        },
        {
          type: "section",
          fields: [
            { type: "mrkdwn", text: "*Name:*\n#{rental_request.name}" },
            { type: "mrkdwn", text: "*Email:*\n#{rental_request.email}" },
            { type: "mrkdwn", text: "*Phone:*\n#{rental_request.phone || 'Not provided'}" },
            { type: "mrkdwn", text: "*Bedrooms:*\n#{rental_request.bedrooms || 'Any'}" },
            { type: "mrkdwn", text: "*Sleeps:*\n#{rental_request.sleeps || 'Any'}" },
            { type: "mrkdwn", text: "*Dates:*\n#{rental_request.check_in_date&.strftime('%m/%d') || '?'} - #{rental_request.check_out_date&.strftime('%m/%d') || '?'}" }
          ]
        },
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: "*Budget:* $#{rental_request.budget_min || 0} - $#{rental_request.budget_max || 'unlimited'}/week\n*Location:* #{rental_request.location_preferences.presence || 'No preference'}"
          }
        }
      ]
    }

    send_webhook(payload)
  rescue StandardError => e
    Rails.logger.error "[Slack] Failed to send rental request notification: #{e.message}"
  end

  def self.webhook_url
    ENV["SLACK_WEBHOOK_URL"]
  end

  def self.send_webhook(payload)
    uri = URI(webhook_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path)
    request["Content-Type"] = "application/json"
    request.body = payload.to_json

    http.request(request)
  end
end
