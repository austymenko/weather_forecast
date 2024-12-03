# frozen_string_literal: true

module Api
  module V1
    # The ForecastsController class is responsible for handling requests related to
    # current weather and weather forecasts.
    class ForecastsController < ApplicationController
      include Controllers::WeatherStreamable

      # Renders the Turbo streams for the current weather data.
      def current_weather
        render_weather_data(fetch_weather_data(current_weather: true))
      end

      # Renders the Turbo streams for the weather forecast data.
      def forecast
        render_weather_data(fetch_weather_data(current_weather: false))
      end

      private

      # Fetches the weather data from the WeatherService based on the provided parameters.
      # @param current_weather [Boolean] Whether to fetch current weather data or weather forecast data.
      # @return [ActiveInteraction::Outcome] The outcome of the WeatherService execution.
      def fetch_weather_data(current_weather:)
        WeatherService.run(
          country: forecast_params[:country],
          postcode: forecast_params[:postcode],
          lat: forecast_params[:latitude].to_f,
          lon: forecast_params[:longitude].to_f,
          current_weather: current_weather
        )
      end

      # Renders the Turbo streams for the weather data, including the cache age information.
      # @param outcome [ActiveInteraction::Outcome] The outcome of the WeatherService execution.
      def render_weather_data(outcome)
        weather_data = outcome.result[:weather_data]
        cache_age = outcome.result[:cache_age]

        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: success_streams(weather_data, cache_age)
          end
        end
      end

      # Retrieves the forecast parameters from the request.
      # @return [ActionController::Parameters] The forecast parameters.
      def forecast_params
        params.permit(:address, :latitude, :longitude, :country, :postcode)
      end
    end
  end
end
