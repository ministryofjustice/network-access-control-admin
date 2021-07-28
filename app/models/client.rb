class Client < ApplicationRecord
  belongs_to :site

  validates_presence_of :tag, :ip_range, :shared_secret

  audited
end
