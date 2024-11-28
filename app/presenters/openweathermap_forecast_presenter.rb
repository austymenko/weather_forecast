# frozen_string_literal: true

class OpenweathermapForecastPresenter
  def self.group_forecast_data_by_date(list)
    # group the data by the date extracted from the 'dt' key
    grouped_forecasts = list.group_by { |data| Time.at(data['dt']).strftime('%Y-%m-%d') }

    # transform the grouped data into daily summaries
    grouped_forecasts.map do |date, entries|
      # mapping for specific attributes
      humidities = entries.map { |entry| entry.dig('main', 'humidity') }
      wind_speeds = entries.map { |entry| entry.dig('wind', 'speed') }
      max_temps = entries.map { |entry| entry.dig('main', 'temp_max') }
      min_temps = entries.map { |entry| entry.dig('main', 'temp_min') }

      # calculate daily metrics
      avg_humidity = humidities.inject(0.0) { |sum, h| sum + h } / humidities.size
      avg_wind_speed = wind_speeds.inject(0.0) { |sum, w| sum + w } / wind_speeds.size
      daily_max_temp = max_temps.max
      daily_min_temp = min_temps.min

      # collect weather icons and determine the most common one
      weather_icons = entries.flat_map { |entry| entry['weather'] }.compact
      most_common_icon = weather_icons.group_by { |icon_data| icon_data['icon'] }
                                      .max_by { |_, group| group.size }
                                      &.first

      {
        date: date,
        most_common_icon: most_common_icon,
        humidity: avg_humidity.round,
        wind_speed: avg_wind_speed.round,
        max_temp: daily_max_temp.round,
        min_temp: daily_min_temp.round
      }
    end
  end
end
