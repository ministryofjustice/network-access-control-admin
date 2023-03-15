# Always interact with our own Audit model rather than
# using Audited's internal model
class Audit < Audited::Audit
  paginates_per 50

  delegate :email,
           to: :user,
           allow_nil: true

  def self.ransackable_attributes(auth_object = nil)
    ["action", "associated_id", "associated_type", "auditable_id", "auditable_type", "audited_changes", "comment", "created_at", "id", "remote_address", "request_uuid", "user_id", "user_type", "username", "version"]
  end

end
