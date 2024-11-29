# frozen_string_literal: true

module Api
  module V1
    class ForecastsController < ApplicationController
      def create
        # forecast_params
        # call Forecast service and return turbo stream with relevant data
      end

      private

      def forecast_params
        params.require(:forecast).permit(:address, :latitude, :longitude)
      end
    end
  end
end
