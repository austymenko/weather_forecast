# frozen_string_literal: true

# The BasePresenter class is an abstract base class that provides common functionality
# for presenter objects in the application, such as error processing.
class BasePresenter < ActiveInteraction::Base
  # A hash that maps OpenWeatherMap weather icon codes to corresponding weather condition names.
  WEATHER_STATUS_MAPPING = {
    '01d' => 'clear',
    '02d' => 'partly_cloudy',
    '03d' => 'cloudy',
    '04d' => 'cloudy',
    '09d' => 'rainy',
    '10d' => 'rainy',
    '11d' => 'stormy',
    '13d' => 'snowy',
    '50d' => 'foggy',
    '01n' => 'clear',
    '02n' => 'partly_cloudy',
    '03n' => 'cloudy',
    '04n' => 'cloudy',
    '09n' => 'rainy',
    '10n' => 'rainy',
    '11n' => 'stormy',
    '13n' => 'snowy',
    '50n' => 'foggy'
  }.freeze

  # Adds an around callback to the `execute` method that handles any StandardError
  # exceptions and adds them to the `errors` attribute.
  def self.with_error_processing
    set_callback :execute, :around, lambda { |_interaction, block|
      begin
        block.call
      rescue StandardError => e
        errors.add(:presenter_error, e.message)
      end
    }
  end
end
