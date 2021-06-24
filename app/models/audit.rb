# Always interact with our own Audit model rather than
# using Audited's internal model
class Audit < Audited::Audit
  paginates_per 50

  delegate :email,
    to: :user,
    allow_nil: true
end
