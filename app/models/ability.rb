class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, [Policy, Site, Rule, Response, Certificate, MacAuthenticationBypass, CSVImport::MacAuthenticationBypasses, Client]

    can :manage, [Policy, Site, Rule, Response, Certificate, MacAuthenticationBypass, CSVImport::MacAuthenticationBypasses, Client] if user.editor?
  end
end
