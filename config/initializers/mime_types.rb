# frozen_string_literal: true

# Register the JSON:API mime type and parse it as JSON.
#
# By default, Rails parses the `application/json` content type via the JSON
# parser, but bodies sent with `application/vnd.api+json` (the official
# JSON:API content type — used by Ember Data, Orbit.js, and any spec-
# compliant client) arrive unparsed. We register the mime type and tell
# `ActionDispatch` to parse those bodies with the JSON parser too.

Mime::Type.register "application/vnd.api+json", :jsonapi
Mime::Type.register "text/csv", :csv unless Mime::Type.lookup_by_extension(:csv)

# Use the JSON parser for JSON:API requests (Rails 7-style)
ActionDispatch::Request.parameter_parsers[:jsonapi] = lambda do |body|
  JSON.parse(body)
end
