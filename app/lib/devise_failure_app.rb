# frozen_string_literal: true

# Custom Warden failure app for API-only mode.
# Returns JSON:API-compliant 401 errors instead of redirecting to HTML login pages.
#
# Referenced in config/initializers/devise.rb:
#   config.warden do |manager|
#     manager.failure_app = DeviseFailureApp
#   end

class DeviseFailureApp < Devise::FailureApp
  def respond
    json_api_error_response
  end

  def json_api_error_response
    self.status = 401
    self.content_type = "application/vnd.api+json"
    self.response_body = {
      errors: [
        {
          status: "401",
          title: "Unauthorized",
          detail: i18n_message
        }
      ]
    }.to_json
  end
end
