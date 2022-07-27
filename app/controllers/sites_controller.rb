class SitesController < ApplicationController
  before_action :set_site, only: %i[show edit update destroy site_policies attach_site_policies edit_site_policies update_site_policies]
  before_action :set_site_policies, only: %i[show edit_site_policies update_site_policies]
  before_action :set_top_level_crumb
  before_action :set_site_name_crumb, only: %i[edit site_policies attach_site_policies edit_site_policies update_site_policies]
  before_action :set_policy_id, only: :index
  before_action :set_policy, only: :index

  def index
    @q = if @policy_id.present?
           Site.joins(:policies).where(policies: { id: @policy_id }).ransack(params[:q])
         else
           Site.ransack(params[:q])
         end

    @q.sorts = params.dig(:q, :s) || "created_at desc"
    @sites = @q.result(distinct: true).page(params.dig(:q, :page))
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
      publish_authorised_clients
      deploy_service
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

  def site_policies
    @q = Policy.where(fallback: false).ransack(params[:q])
    @policies = @q.result
  end

  def attach_site_policies
    @q = Policy.where(fallback: false).ransack(params[:q])
    @policies = @q.result

    authorize! :attach_policies, @site

    @site.assign_attributes(policies: Policy.where(id: policies_params))

    if @site.save
      redirect_to site_path(@site), notice: "Successfully updated site policies."
    else
      redirect_to site_policies_path(@site), alert: "Failed to update site policies with error: #{@site.errors.full_messages.join(', ')}."
    end
  end

  def edit_site_policies
    authorize! :edit_policies, @site
  end

  def update_site_policies
    if site_policies_params.values == site_policies_params.values.uniq
      @site_policies.each do |site_policy|
        priority = site_policies_params.fetch(site_policy.id.to_s)
        site_policy.update(priority:)
      end

      redirect_to site_path(@site), notice: "Successfully updated the order of site policies."
    else
      redirect_to edit_site_policies_path(@site), alert: "Duplicate values entered for order priority."
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

  def set_site_policies
    @site_policies = SitePolicy.where(site_id: @site.id).includes(:policy).order(:priority).reject { |sp| sp.policy.fallback? }
  end

  def policies_params
    protected_policies = @site.policies.map { |s| s.id.to_s } - params.require(:filtered_policy_ids).split
    (protected_policies + params.require(:policy_ids).reject(&:empty?)).uniq
  end

  def site_policies_params
    params.fetch(:site_policy)
  end

  def set_top_level_crumb
    @navigation_crumbs << ["Sites", sites_path]
  end

  def set_site_name_crumb
    @navigation_crumbs << [@site.name, site_path(@site)]
  end

  def set_policy_id
    @policy_id = params.dig(:q, :policy_id)
  end

  def set_policy
    @policy = Policy.find_by(id: @policy_id)
  end
end
