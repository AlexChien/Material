class Material < ActiveRecord::Base
  has_many :catalogs_materials
  has_many :catalogs, :through => :catalogs_materials
  has_many :order_line_item_raws
  has_many :order_line_item_adjusteds
  has_many :order_line_item_applies
  has_many :production_line_items
  has_many :inventories
  has_many :transfer_line_items
  belongs_to :category, :counter_cache => true

  validates_presence_of :name,:category_id,:min_num,:max_num
  validates_uniqueness_of :name
  validates_numericality_of :cost,:greater_than_or_equal_to=>0
  validates_numericality_of :min_num,:greater_than=>0
  validates_numericality_of :max_num,:greater_than=>0
  validate :min_num,:check_min_num

  has_attached_file :uploaded_data,
                    :default_url => "/images/powerposm/missing.jpg",
                    :styles => {:thumb => '100x75>'},
                    :url => "/images/assets/:attachment/:id/:style/:filename",
                    :path => ":rails_root/public/images/assets/:attachment/:id/:style/:filename"
  # validates_attachment_presence :uploaded_data,:message => "请选择上传文件"
  validates_attachment_content_type :uploaded_data,
    :content_type => ['image/jpg', 'image/jpeg', 'image/pjpeg', 'image/gif', 'image/png', 'image/x-png'],
    :message => "上传格式不符"
  validates_attachment_size :uploaded_data,
    :less_than => 5.megabyte, #another option is :greater_than
    :message => "上传文件小于5M"

  # after_create :generate_item_no
  before_create :generate_sku

  named_scope :in_state, lambda {|state|
        {:conditions => ["materials.state = ?", state]}
  }

  state_machine :initial => :activated do
    event :delete_material  do transition all => :deleted end
  end

protected
  def generate_sku
    self.sku = "#{self.category.cid}#{self.category.next_sku}"
  end

  def check_min_num
    if !self.min_num.nil? and !self.max_num.nil?
      if self.min_num > self.max_num
        errors.add(:min_num, '不能大于最大订货量')
      end
    end
  end

  def generate_item_no(prefix="powerposm")
    time = Time.now.to_i.to_s
    self.update_attribute(:itemno,prefix + "_" + time + "_" + self.id.to_s)
  end

end
