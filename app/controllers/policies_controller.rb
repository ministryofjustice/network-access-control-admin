class PoliciesController < ApplicationController
  def new
    @policy = Policy.new
  end
end
