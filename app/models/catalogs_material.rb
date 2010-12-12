class CatalogsMaterial < ActiveRecord::Base
  belongs_to :catalog
  belongs_to :material
end
