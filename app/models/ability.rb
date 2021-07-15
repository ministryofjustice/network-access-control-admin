class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, [Policy, Site, Rule, Response, MacAuthenticationBypass]

    can :manage, [Policy, Site, Rule, Response, MacAuthenticationBypass] if user.editor?
  end
end
