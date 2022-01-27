class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, [
      Policy,
      Site,
      Rule,
      Response,
      Certificate,
      MacAuthenticationBypass,
      CSVImport::MacAuthenticationBypasses,
      CSVImport::SitesWithClients,
      Client,
    ]

    if user.editor?
      can :manage, [
        Policy,
        Site,
        Rule,
        Response,
        Certificate,
        MacAuthenticationBypass,
        CSVImport::MacAuthenticationBypasses,
        CSVImport::SitesWithClients,
        Client,
      ]
    end
  end
end
