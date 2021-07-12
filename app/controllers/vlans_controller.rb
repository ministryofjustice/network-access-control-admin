class VlansController < ApplicationController
  before_action :set_vlan, only: [:show]

  def show; end

  def index
    @vlans = Vlan.all
  end

private

  def set_vlan
    @vlan = Vlan.find(vlan_id)
  end

  def vlan_id
    params.fetch(:id)
  end
end
