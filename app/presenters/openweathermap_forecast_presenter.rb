# frozen_string_literal: true

# The OpenweathermapForecastPresenter class is responsible for processing the raw weather forecast data
# from the OpenWeatherMap API and formatting it into a standardized array of hashes.
class OpenweathermapForecastPresenter < BasePresenter
  # @param weather_data [Array<Hash>] The raw weather forecast data from the OpenWeatherMap API.
  array :weather_data, default: []

  with_error_processing

  # Executes the weather forecast data processing logic and returns the formatted forecast data.
  # @return [Array<Hash>] An array of hashes containing the formatted weather forecast data.
  def execute
    grouped_forecasts.map do |date, entries|
      build_daily_summary(date, entries)
    end
  end

  private

  # Groups the weather forecast data by date.
  # @return [Hash] A hash where the keys are dates and the values are arrays of weather data entries for that date.
  def grouped_forecasts
    weather_data.group_by do |data|
      Time.at(data['dt']).strftime('%Y-%m-%d')
    end
  end

  # Builds a daily weather summary for a given date and set of weather data entries.
  # @param date [String] The date for the weather summary.
  # @param entries [Array<Hash>] The weather data entries for the given date.
  # @return [Hash] A hash containing the daily weather summary.
  def build_daily_summary(date, entries)
    {
      date: format_date(date),
      **weather_metrics(entries),
      **weather_conditions(entries)
    }
  end

  # Formats the date as a string in the format 'MMM DD, YYYY'.
  # @param date [String] The date to be formatted.
  # @return [String] The formatted date string.
  def format_date(date)
    Date.parse(date).strftime('%b %d, %Y')
  end

  # Extracts the weather metrics (temperature, humidity, wind speed) from the weather data entries.
  # @param entries [Array<Hash>] The weather data entries.
  # @return [Hash] A hash containing the weather metrics.
  def weather_metrics(entries)
    {
      max_temp: extract_max_value(entries, %w[main temp_max]),
      min_temp: extract_min_value(entries, %w[main temp_min]),
      humidity: calculate_average(entries, %w[main humidity]),
      wind_speed: calculate_average(entries, %w[wind speed])
    }
  end

  # Extracts the weather conditions (most common icon and title) from the weather data entries.
  # @param entries [Array<Hash>] The weather data entries.
  # @return [Hash] A hash containing the weather conditions.
  def weather_conditions(entries)
    icon = find_most_common_icon(entries)

    {
      most_common_icon: icon,
      title: WEATHER_STATUS_MAPPING[icon]
    }
  end

  # Calculates the average value for the specified keys across the weather data entries.
  # @param entries [Array<Hash>] The weather data entries.
  # @param keys [Array<String>] The keys to use to retrieve the values.
  # @return [Integer] The calculated average value.
  def calculate_average(entries, keys)
    values = entries.map { |entry| entry.dig(*keys) }
    (values.sum / values.size).round
  end

  # Extracts the maximum value for the specified keys across the weather data entries.
  # @param entries [Array<Hash>] The weather data entries.
  # @param keys [Array<String>] The keys to use to retrieve the values.
  # @return [Integer] The extracted maximum value.
  def extract_max_value(entries, keys)
    entries.map { |entry| entry.dig(*keys) }.max.round
  end

  # Extracts the minimum value for the specified keys across the weather data entries.
  # @param entries [Array<Hash>] The weather data entries.
  # @param keys [Array<String>] The keys to use to retrieve the values.
  # @return [Integer] The extracted minimum value.
  def extract_min_value(entries, keys)
    entries.map { |entry| entry.dig(*keys) }.min.round
  end

  # Finds the most common weather icon code across the weather data entries.
  # @param entries [Array<Hash>] The weather data entries.
  # @return [String, nil] The most common weather icon code, or nil if no icon codes are found.
  def find_most_common_icon(entries)
    weather_icons = entries.flat_map { |entry| entry['weather'] }.compact

    weather_icons.group_by { |icon_data| icon_data['icon'] }
                 .max_by { |_, group| group.size }
                 &.first
  end
end
