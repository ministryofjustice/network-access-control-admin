class SitePolicy < ApplicationRecord
  belongs_to :site
  belongs_to :policy

  audited
end
