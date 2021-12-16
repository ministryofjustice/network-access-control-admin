class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, [Policy, Site, Rule, Response, Certificate, MacAuthenticationBypass, MacAuthenticationBypassesImport, Client]

    can :manage, [Policy, Site, Rule, Response, Certificate, MacAuthenticationBypass, MacAuthenticationBypassesImport, Client] if user.editor?
  end
end
