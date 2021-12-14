class PoliciesController < ApplicationController
  before_action :set_policy, only: %i[show edit update destroy policy_sites attach_policy_sites]
  before_action :set_crumbs
  before_action :set_policy_name_crumb, only: %i[edit policy_sites attach_policy_sites]
  before_action :set_site_id, only: :index

  def new
    @policy = Policy.new
    authorize! :create, @policy
  end

  def create
    @policy = Policy.new(policy_params)
    authorize! :create, @policy

    if @policy.save
      redirect_to policy_path(@policy), notice: "Successfully created policy. "
    else
      render :new
    end
  end

  def index
    @sites = Site.order(:name).pluck(:name, :id)

    @q = if @site_id.present?
           Policy.joins(:sites).where(sites: { id: @site_id }).ransack(params[:q])
         else
           Policy.ransack(params[:q])
         end

    @policies = @q.result.page(params.dig(:q, :page))
  end

  def show; end

  def destroy
    authorize! :destroy, @policy
    if confirmed?
      if @policy.destroy
        SitePolicy.where(policy_id: policy_id).delete_all
        redirect_to policies_path, notice: "Successfully deleted policy. "
      else
        redirect_to policy_path(@policy), error: "Failed to delete the policy"
      end
    else
      render "policies/destroy"
    end
  end

  def edit
    authorize! :update, @policy
  end

  def update
    authorize! :update, @policy
    @policy.assign_attributes(policy_params)

    if @policy.save
      redirect_to policy_path(@policy), notice: "Successfully updated policy. "
    else
      render :edit
    end
  end

  def policy_sites
    @q = Site.ransack(params[:q])
    @sites = @q.result
  end

  def attach_policy_sites
    @q = Site.ransack(params[:q])
    @sites = @q.result

    @policy.assign_attributes(sites: Site.where(id: sites_params))

    if @policy.save
      redirect_to policy_path(@policy), notice: "Successfully updated policy sites."
    else
      redirect_to policy_sites_path(@policy), alert: "Failed to attach policy to sites with error: #{@policy.errors.full_messages.join(', ')}."
    end
  end

private

  def policy_params
    params.require(:policy).permit(:name, :description, :fallback)
  end

  def sites_params
    protected_sites = @policy.sites.map { |s| s.id.to_s } - params.require(:filtered_site_ids).split
    (protected_sites + params.require(:site_ids).reject(&:empty?)).uniq
  end

  def policy_id
    params.fetch(:id)
  end

  def set_policy
    @policy = Policy.find(policy_id)
  end

  def set_crumbs
    @navigation_crumbs << ["Policies", policies_path]
  end

  def set_policy_name_crumb
    @navigation_crumbs << [@policy.name, policy_path(@policy)]
  end

  def set_site_id
    @site_id = params.dig(:q, :site_id) == "All" ? nil : params.dig(:q, :site_id)
  end
end
