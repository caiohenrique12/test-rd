Rails.application.config.x.payment_link_base_url = ENV.fetch(
  "PAYMENT_LINK_BASE_URL",
  "https://pay.example.com"
)
