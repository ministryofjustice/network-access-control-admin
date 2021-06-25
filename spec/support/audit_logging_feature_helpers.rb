module AuditLoggingFeatureHelpers
  def expect_audit_log_entry_for(editor_string, action, object_type_changed)
    click_on "Audit log"

    expect(page).to have_content(editor_string)
    expect(page).to have_content(action)
    expect(page).to have_content(object_type_changed)
  end
end
