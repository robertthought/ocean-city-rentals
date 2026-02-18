require "net/http"
require "json"

class RecaptchaVerifier
  VERIFY_URL = "https://www.google.com/recaptcha/api/siteverify"
  MINIMUM_SCORE = 0.5

  def self.verify(token, remote_ip = nil)
    # Skip verification if reCAPTCHA is not configured
    return { success: true, score: 1.0 } if skip_verification?
    # Allow submissions without token (forms without JS reCAPTCHA integration)
    return { success: true, score: 0.5 } if token.blank?

    secret_key = ENV["RECAPTCHA_SECRET_KEY"]

    uri = URI(VERIFY_URL)
    response = Net::HTTP.post_form(uri, {
      secret: secret_key,
      response: token,
      remoteip: remote_ip
    })

    result = JSON.parse(response.body)

    if result["success"] && result["score"].to_f >= MINIMUM_SCORE
      { success: true, score: result["score"] }
    else
      Rails.logger.warn "[reCAPTCHA] Failed: score=#{result['score']}, errors=#{result['error-codes']}"
      { success: false, score: result["score"], errors: result["error-codes"] }
    end
  rescue StandardError => e
    Rails.logger.error "[reCAPTCHA] Error: #{e.message}"
    # Fail open in case of network issues - don't block legitimate users
    { success: true, score: 0, error: e.message }
  end

  def self.skip_verification?
    # Skip if no keys configured (allows forms to work without reCAPTCHA)
    ENV["RECAPTCHA_SECRET_KEY"].blank?
  end
end
