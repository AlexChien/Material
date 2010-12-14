class CatalogsMaterial < ActiveRecord::Base
  belongs_to :catalog
  belongs_to :material
  
  named_scope :in_catalog, lambda {|catalog_id|
        {:conditions => ["catalogs_materials.catalog_id in (?)", catalog_id]}
  }
  
  named_scope :in_material, lambda {|material_id|
        {:conditions => ["catalogs_materials.material_id in (?)", material_id]}
  }
  
end
