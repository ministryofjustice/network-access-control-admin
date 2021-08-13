class SitesController < ApplicationController
  before_action :set_site, only: %i[show edit update destroy policies attach_policies]

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

  def policies
    @policies = Policy.all
  end

  def attach_policies
    authorize! :attach_policies, @site

puts policies_params

    if policies_params.any?
      @site.policies.clear

      policies_params.each do |id|
        @site.policies << Policy.find(id)
      end
    else
      @site.policies.clear
    end

    if @site.save
      redirect_to site_path(@site), notice: "Successfully attached policies to the site. "
    else
      render :policies
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

  def policies_params
    params.require(:policy_ids).reject(&:empty?)
  end
end
