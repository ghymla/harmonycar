require "open-uri"
require "nokogiri"
require "csv"


class GaragesController < ApplicationController

  def index

    # @services = Service.all

    @services = []
    @services_name = []

    Service.all.each do |service|
      @services_name << Service.find(params[:query]).name if params[:query].present?

      unless @services_name.include?(service.name)
        @services << service
        @services_name << service.name
      end
    end



    if params[:query].present?
      service = Service.find(params[:query]).name
      sql_query = " \
        garages.name ILIKE :query \
        OR services.name ILIKE :query \
      "
      @garages = Garage.joins(:services).where(sql_query, query: "%#{service}%")
    else
      @garages = Garage.all
    end

    @markers = @garages.geocoded.map do |garage|
      {
        lat: garage.latitude,
        lng: garage.longitude,
        info_window: render_to_string(partial: "info_window", locals: { garage: garage })
      }
    end

  end

end
