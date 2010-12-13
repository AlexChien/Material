class AddAlexAdminAccount < ActiveRecord::Migration
  def self.up
     user = User.create(:login=>"alex",:name=>"Alex Chien",:email=>"alex.chien@koocaa.com",:password=>"alexgem",:password_confirmation=>"alexgem")
      user.roles << Role.find_by_name("admin")
  end

  def self.down
  end
end
