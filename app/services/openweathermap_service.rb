# frozen_string_literal: true

# The OpenweathermapService class is responsible for fetching weather data from the OpenWeatherMap API,
# processing the data, and returning the processed weather information.
class OpenweathermapService < BaseService
  include CoordinateValidatable

  with_error_processing

  # @param lon [Float] The longitude of the location to fetch weather data for.
  # @param lat [Float] The latitude of the location to fetch weather data for.
  # @param current_weather [Boolean] Whether to fetch current weather data or forecast data. Default is true.
  float :lon
  float :lat
  boolean :current_weather, default: true

  validates_coordinates

  # Executes the weather data fetching and processing logic.
  # @return [Hash, Array<Hash>] The processed weather data, either a Hash (for current weather) or an Array of Hashes (for forecast data).
  # If there are any errors, it returns nil and the errors are added to the `errors` attribute.
  def execute
    weather_data = fetch_weather_data
    return if errors.any?

    process_weather_data(weather_data)
  end

  private

  # Fetches the weather data from the OpenWeatherMap API.
  # @return [Hash, nil] The raw weather data from the API, or nil if there are any errors.
  def fetch_weather_data
    outcome = OpenweathermapClient.run(
      lon: lon,
      lat: lat,
      current_weather: current_weather
    )

    merge_errors_and_return(outcome)
  end

  # Processes the raw weather data by passing it through a presenter.
  # @param weather_data [Hash, Array<Hash>] The raw weather data from the API.
  # @return [Hash, Array<Hash>] The processed weather data, either a Hash (for current weather) or an Array of Hashes (for forecast data).
  def process_weather_data(weather_data)
    presenter_outcome = weather_presenter.run(
      weather_data: prepare_weather_data(weather_data)
    )

    merge_errors_and_return(presenter_outcome)
  end

  # Determines the appropriate weather presenter based on the `current_weather` flag.
  # @return [OpenweathermapWeatherPresenter, OpenweathermapForecastPresenter] The weather presenter instance.
  def weather_presenter
    current_weather ? OpenweathermapWeatherPresenter : OpenweathermapForecastPresenter
  end

  # Prepares the weather data for processing by the presenter.
  # @param data [Hash, Array<Hash>] The raw weather data from the API.
  # @return [Hash, Array<Hash>] The prepared weather data, either a Hash (for current weather) or an Array of Hashes (for forecast data).
  def prepare_weather_data(data)
    current_weather ? data : data['list']
  end

  # Merges any errors from the provided outcome and returns the result.
  # @param outcome [ActiveInteraction::Base] The outcome from a service or presenter.
  # @return [Object, nil] The result from the outcome, or nil if there are any errors.
  def merge_errors_and_return(outcome)
    if outcome.valid?
      outcome.result
    else
      errors.merge!(outcome.errors)
      nil
    end
  end
end
