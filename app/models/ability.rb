class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, [Policy, Site, Rule, Response, Certificate, MacAuthenticationBypass, Client]

    can :manage, [Policy, Site, Rule, Response, Certificate, MacAuthenticationBypass, Client] if user.editor?
  end
end
