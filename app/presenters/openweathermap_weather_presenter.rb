# frozen_string_literal: true

# The OpenweathermapWeatherPresenter class is responsible for processing the raw weather data
# from the OpenWeatherMap API and formatting it into a standardized hash structure.
class OpenweathermapWeatherPresenter < BasePresenter
  with_error_processing

  # @param weather_data [Hash] The raw weather data from the OpenWeatherMap API.
  hash :weather_data, default: {}, strip: false

  # Executes the weather data processing logic and returns the formatted weather information.
  # @return [Hash] A hash containing the formatted weather data.
  def execute
    {
      date: formatted_date,
      **current_weather_conditions,
      **temperature_data,
      **atmospheric_conditions
    }
  end

  private

  # Formats the current date as a string in the format 'MMM DD, YYYY'.
  # @return [String] The formatted date string.
  def formatted_date
    Time.current.strftime('%b %d, %Y')
  end

  # Extracts the current weather conditions from the weather data.
  # @return [Hash] A hash containing the weather icon code and title.
  def current_weather_conditions
    {
      icon: weather_icon,
      title: WEATHER_STATUS_MAPPING[weather_icon]
    }
  end

  # Extracts the temperature data from the weather data.
  # @return [Hash] A hash containing the current temperature and feels-like temperature.
  def temperature_data
    {
      temp: extract_integer(%w[main temp]),
      feels_like: extract_integer(%w[main feels_like])
    }
  end

  # Extracts the atmospheric conditions from the weather data.
  # @return [Hash] A hash containing the humidity and wind speed.
  def atmospheric_conditions
    {
      humidity: extract_integer(%w[main humidity]),
      wind_speed: extract_integer(%w[wind speed])
    }
  end

  # Retrieves the weather icon code from the weather data.
  # @return [String] The weather icon code.
  def weather_icon
    weather_data.dig('weather', 0, 'icon')
  end

  # Extracts an integer value from the weather data using the specified keys.
  # @param keys [Array<String>] The keys to use to retrieve the value.
  # @return [Integer] The extracted integer value.
  def extract_integer(keys)
    weather_data.dig(*keys).to_i
  end
end
