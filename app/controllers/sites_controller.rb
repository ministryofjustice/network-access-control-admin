class SitesController < ApplicationController
  before_action :set_site, only: %i[show edit update destroy]

  def index
    @sites = Site.all
    @navigation_crumbs = [["Home", root_path]]
  end

  def show
    @navigation_crumbs = [["Home", root_path], ["Sites", sites_path]]
  end

  def new
    @site = Site.new
    authorize! :create, @site
  end

  def create
    @site = Site.new(site_params)
    authorize! :create, @site

    if @site.save
      redirect_to site_path(@site), notice: "Successfully created site. #{CONFIG_UPDATE_DELAY_NOTICE}"
    else
      render :new
    end
  end

  def edit
    authorize! :update, @site
  end

  def update
    authorize! :update, @site
    @site.assign_attributes(site_params)

    if @site.save
      redirect_to site_path(@site), notice: "Successfully updated site. #{CONFIG_UPDATE_DELAY_NOTICE}"
    else
      render :edit
    end
  end

  def destroy
    authorize! :destroy, @site
    if confirmed?
      if @site.destroy
        redirect_to sites_path, notice: "Successfully deleted site. #{CONFIG_UPDATE_DELAY_NOTICE}"
      else
        redirect_to site_path(@site), error: "Failed to delete the site"
      end
    else
      render "sites/destroy"
    end
  end

private

  def site_params
    params.require(:site).permit(:name)
  end

  def site_id
    params.fetch(:id)
  end

  def set_site
    @site = Site.find(site_id)
  end
end
