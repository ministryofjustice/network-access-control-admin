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
      UseCases::CSVImport::MacAuthenticationBypasses,
      UseCases::CSVImport::SitesWithClients,
      UseCases::CSVExport::SitesWithClients,
      UseCases::CSVImport::Policies,
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
        UseCases::CSVImport::MacAuthenticationBypasses,
        UseCases::CSVImport::SitesWithClients,
        UseCases::CSVExport::SitesWithClients,
        UseCases::CSVImport::Policies,
        Client,
      ]
    end
  end
end
