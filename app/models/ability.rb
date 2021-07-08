# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, [Policy, Site, Rule]

    if user.editor?
      can :manage, [Policy, Site, Rule]
    end
  end
end
