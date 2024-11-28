# frozen_string_literal: true

require 'faraday'
require 'faraday/retry'

class MapboxClient < BaseHttpClient
  string :access_token, default: ENV['MAPBOX_ACCESS_TOKEN']
  string :query

  with_error_processing

  def execute
    return unless query.present?

    fetch_places
  end

  private

  def url
    'https://api.mapbox.com/'
  end

  def forward_path
    '/search/geocode/v6/forward'
  end

  def get
    faraday.get(forward_path, {
                  q: query,
                  types: 'address',
                  language: 'en',
                  access_token: access_token
                })
  end

  def fetch_places
    get.body
  end
end
