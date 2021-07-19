class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, [Policy, Site, Rule, Response, Certificate, MacAuthenticationBypass]

    can :manage, [Policy, Site, Rule, Response, Certificate, MacAuthenticationBypass] if user.editor?
  end
end
