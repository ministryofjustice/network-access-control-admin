# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, Site

    if user.editor?
      can :manage, Site
    end
  end
end
