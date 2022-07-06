class PagesController < ApplicationController
  def home
    redirect_to properties_path
  end

  def index
    @apartments = Apartment.includes(:city, :borough)
    @houses = House.includes(:city, :borough)

    filter_by_checkbox_criterias
    filter_by_radio_criterias
    filter_by_rooms
    filter_by_surface
    filter_by_locations
    filter_by_apartment_type
    filter_by_project

    if params[:locations].present? && params[:locations].split(",").count == 1
      insee_code = params[:locations].split(",").first
      borough = Borough.find_by(insee_code: insee_code)
      city = City.find_by(insee_code: insee_code)
      @location = borough || city
      @there = "à #{@location.name}"
    end

    @what = params[:types].split(",").first if params[:types].present? && params[:types].split(",").count == 1

    @properties = @apartments + @houses
    if params[:sort].present? && params[:sort] == "price"
      @properties = @properties.sort_by(&:price)
    end

    respond_to do |format|
      format.html
      format.text { render partial: 'locations', locals: { locations: @results }, formats: :html }
    end
  end

  private

  def filter_by_project
    return unless params[:project].present?

    @apartments = @apartments.where(project: params[:project])
    @houses = @houses.where(project: params[:project])
  end

  def filter_by_checkbox_criterias
    ## balcon
    if params[:balcony].present?
      @apartments = @apartments.where(balcony: true)
      @houses = @houses.where(balcony: true)
    end
    ## cheminée
    if params[:chimney].present?
      @apartments = @apartments.where(chimney: true)
      @houses = @houses.where(chimney: true)
    end
    ## ascenseur
    @apartments = @apartments.where(elevator: true) if params[:elevator].present?
    ## cellier
    if params[:cellar].present?
      @apartments = @apartments.where(cellar: true)
      @houses = @houses.where(cellar: true)
    end
    ## garage
    if params[:garage].present?
      @apartments = @apartments.where(garage: true)
      @houses = @houses.where(garage: true)
    end
    ## terrasse
    if params[:terrace].present?
      @apartments = @apartments.where(terrace: true)
      @houses = @houses.where(terrace: true)
    end
    ## jardin
    @houses = @houses.where(garden: true) if params[:garden].present?
  end

  def filter_by_radio_criterias
    # meublé / non meublé
    @apartments = @apartments.where("status ILIKE ? ", params[:status]) if params[:status].present?
  end

  def filter_by_rooms
    if params[:rooms_min].present? && params[:rooms_max].present? && params[:rooms_max].to_i >= params[:rooms_min].to_i
      @apartments = @apartments.where(rooms: params[:rooms_min].to_i..params[:rooms_max].to_i)
      @houses = @houses.where(rooms: params[:rooms_min].to_i..params[:rooms_max].to_i)
    elsif params[:rooms_min].present?
      @apartments = @apartments.where("rooms >= ? ", params[:rooms_min].to_i)
      @houses = @houses.where("rooms >= ? ", params[:rooms_min].to_i)
    elsif params[:rooms_max].present?
      @apartments = @apartments.where("rooms <= ? ", params[:rooms_max].to_i)
      @houses = @houses.where("rooms <= ? ", params[:rooms_max].to_i)
    end
  end

  def filter_by_surface
    if params[:surface_min].present? && params[:surface_max].present? && params[:surface_max].to_i >= params[:surface_min].to_i
      @apartments = @apartments.where(surface: params[:surface_min].to_i..params[:surface_max].to_i)
      @houses = @houses.where(surface: params[:surface_min].to_i..params[:surface_max].to_i)
    elsif params[:surface_min].present?
      @apartments = @apartments.where("surface >= ? ", params[:surface_min].to_i)
      @houses = @houses.where("surface >= ? ", params[:surface_min].to_i)
    elsif params[:surface_max].present?
      @apartments = @apartments.where("surface <= ? ", params[:surface_max].to_i)
      @houses = @houses.where("surface <= ? ", params[:surface_max].to_i)
    end
  end

  def filter_by_apartment_type
    @apartment_types = params[:types].split(",") if params[:types].present?
    if @apartment_types.present? && !@apartment_types.include?("house")
      @houses = House.where(name: "toto")
    elsif @apartment_types.present? && !@apartment_types.include?("flat")
      @apartments = Apartment.where(name: "toto")
    end
  end

  def filter_by_locations
    @locations_insees = params[:locations].split(",") if params[:locations].present?

    find_location_tags if @locations_insees.present?

    filter_the_apartment

    ## les resultats affichés
    return unless params[:search].present?

    find_results
  end

  def find_location_tags
    @cities = City.where(insee_code: @locations_insees)
    @boroughs = Borough.where(insee_code: @locations_insees)
    @locations_tags = @cities + @boroughs
  end

  def filter_the_apartment
    if @cities.present? && @boroughs.present?
      @apartments = @apartments.where(city: @cities).or(@apartments.where(borough: @boroughs)).uniq
      @houses = @houses.where(city: @cities).or(@houses.where(borough: @boroughs)).uniq
    elsif @cities.present?
      @apartments = @apartments.where(city: @cities)
      @houses = @houses.where(city: @cities)
    elsif @boroughs.present?
      @apartments = @apartments.where(borough: @boroughs)
      @houses = @houses.where(borough: @boroughs)
    end
  end

  def find_results
    @city_results = City.where("name ILIKE ? ", "%#{params[:search]}%")
    if @locations_insees.present? && @city_results.present?
      @city_results = @city_results.where.not(insee_code: @locations_insees)
    end
    @borough_results = Borough.where("name ILIKE ? ", "%#{params[:search]}%")
    if @locations_insees.present? && @borough_results.present?
      @borough_results = @borough_results.where.not(insee_code: @locations_insees)
    end
    @results = @city_results + @borough_results if @city_results.present? || @borough_results.present?
  end
end
