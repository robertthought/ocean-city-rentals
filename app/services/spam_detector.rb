class SpamDetector
  # Non-Latin Unicode: Cyrillic, Arabic, CJK, Devanagari, Georgian, Armenian, etc.
  NON_LATIN_PATTERN = /[\u0400-\u04FF\u0600-\u06FF\u4E00-\u9FFF\u0900-\u097F\u10A0-\u10FF\u0531-\u058F]/

  # Random-string pattern: 10+ chars, all letters, no spaces (not a real name/word)
  RANDOM_STRING_PATTERN = /\A[A-Za-z]{10,}\z/

  def self.detect(name:, email:, phone: nil, message: nil, recaptcha_score: nil, honeypot: nil)
    reasons = []

    # Honeypot filled — definitely a bot
    reasons << "honeypot" if honeypot.present?

    # Random-string name (no spaces, 10+ letters only — bots generate these)
    if name.present? && RANDOM_STRING_PATTERN.match?(name.strip) && name.strip != "Quick Inquiry"
      reasons << "random string name"
    end

    # Random-string message (no spaces, 8+ letters only)
    if message.present? && /\A[A-Za-z]{8,}\z/.match?(message.strip)
      reasons << "random string message"
    end

    # Non-Latin characters in name or message
    if NON_LATIN_PATTERN.match?(name.to_s) || NON_LATIN_PATTERN.match?(message.to_s)
      reasons << "non-latin characters"
    end

    # Email with 3+ dots in local part (bot pattern like w.at.t.ru.ler@gmail.com)
    if email.present? && email.split("@").first.to_s.count(".") >= 3
      reasons << "suspicious email format"
    end

    # Disposable/known spam email domains
    if email.present? && email.match?(/@(mailnull|spam4|trashmail|guerrillamail|tempmail)/i)
      reasons << "disposable email"
    end

    # Phone looks like a non-US international bot number (11+ digits, no US format)
    if phone.present?
      digits = phone.gsub(/\D/, "")
      if digits.length > 10 && !phone.match?(/^\+?1[\s\-.]?\(?\d{3}\)?/)
        reasons << "suspicious phone (#{phone})"
      end
    end

    # Very low reCAPTCHA score
    if recaptcha_score.present? && recaptcha_score.to_f < 0.4
      reasons << "low recaptcha score (#{recaptcha_score})"
    end

    reasons
  end
end
