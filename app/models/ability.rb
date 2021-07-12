class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, [Policy, Site, Rule, Response]

    can :manage, [Policy, Site, Rule, Response] if user.editor?
  end
end
