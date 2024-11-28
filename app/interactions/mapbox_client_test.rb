# frozen_string_literal: true

class MapboxClientTest < ActiveInteraction::Base
  def execute
    # query = "q=5523%20cred&types=address&language=en&access_token=pk.eyJ1IjoiYXVzdHltZW5rbyIsImEiOiJjbTQwbnc5eGIwaGRlMnFwdHMybmtpNzNyIn0.WaymFGT3Vc-nMqui8m7oKA"

    # GET: https://api.mapbox.com/search/geocode/v6/forward?q=5523%20cred&types=address&language=en&access_token=pk.eyJ1IjoiYXVzdHltZW5rbyIsImEiOiJjbTQwbnc5eGIwaGRlMnFwdHMybmtpNzNyIn0.WaymFGT3Vc-nMqui8m7oKA
    query = '5524 creditrise'
    res = MapboxClient.run(query: query)

    # (ruby) res.errors
    # #<ActiveInteraction::Errors [#<ActiveModel::Error attribute=mapbox_client_error, type=the server responded with status 401, options={}>]>
    # (ruby) res.errors.messages
    # {:mapbox_client_error=>["the server responded with status 401"]}
    # debugger

    if res.valid?
      puts "\nres: #{res.result}"
    else
      puts "ERRORS: #{res.errors.full_messages.join(' ')}"
    end
  end
end
