class UpdateSiteIdInMacAuthenticationBypass < ActiveRecord::Migration[7.0]
  def change
    change_column_null :mac_authentication_bypasses, :site_id, false
  end
end
