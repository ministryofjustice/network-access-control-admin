class SitesController < ApplicationController
  before_action :set_site, only: %i[show edit update destroy policies attach_policies edit_policies update_policies]
  before_action :set_site_policies, only: %i[show edit_policies update_policies]
  before_action :set_crumbs, only: %i[show new edit destroy policies]

  def index
    @sites = if params[:policy]
               Site.page(params[:page]).joins(:policies).where(policies: { id: params[:policy] })
             else
               Site.page params[:page]
             end
  end

  def show; end

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
    @fallback_policies = Policy.where(fallback: true)

    @non_fallback_policies = Policy.where(fallback: false)
  end

  def attach_policies
    authorize! :attach_policies, @site

    @site.assign_attributes(policies: Policy.where(id: policies_params))

    if @site.save
      redirect_to site_path(@site), notice: "Successfully updated site policies."
    else
      render :policies
    end
  end

  def edit_policies
    authorize! :edit_policies, @site
  end

  def update_policies
    @site_policies.each do |site_policy|
      priority = site_policies_params.fetch(site_policy.id.to_s)
      site_policy.update(priority: priority)
    end

    redirect_to site_path(@site), notice: "Successfully updated the order of site policies."
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

  def set_site_policies
    @site_policies = SitePolicy.where(site_id: @site.id).includes(:policy).order(:priority).reject { |sp| sp.policy.fallback? }
  end

  def policies_params
    (params.require(:policy_ids).reject(&:empty?) << @site.fallback_policy.id).flatten
  end

  def site_policies_params
    params.fetch(:site_policy)
  end

  def set_crumbs
    @navigation_crumbs << ["Sites", sites_path]
  end
end
