# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, [Policy, Site]

    if user.editor?
      can :manage, [Policy, Site]
    end
  end
end
