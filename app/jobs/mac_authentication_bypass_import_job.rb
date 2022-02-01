class MacAuthenticationBypassImportJob < ActiveJob::Base
  def perform
    return "noop"
  end
end
