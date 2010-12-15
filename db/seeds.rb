# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)
user = User.create(:login=>"test_mm",:name=>"test_mm",:email=>"test_mm@gmail.com",:password=>"111111",:password_confirmation=>"111111",:region_id=>2)
user.roles << Role.find_by_name("MM")

user = User.create(:login=>"test_pm",:name=>"test_pm",:email=>"test_pm@gmail.com",:password=>"111111",:password_confirmation=>"111111",:region_id=>2)
user.roles << Role.find_by_name("PM")

user = User.create(:login=>"test_wa",:name=>"test_wa",:email=>"test_wa@gmail.com",:password=>"111111",:password_confirmation=>"111111",:region_id=>2)
user.roles << Role.find_by_name("WA")

user = User.create(:login=>"test_rm",:name=>"test_rm",:email=>"test_rm@gmail.com",:password=>"111111",:password_confirmation=>"111111",:region_id=>2)
user.roles << Role.find_by_name("RM")

user = User.create(:login=>"test_rc",:name=>"test_rc",:email=>"test_rc@gmail.com",:password=>"111111",:password_confirmation=>"111111",:region_id=>2)
user.roles << Role.find_by_name("RC")


user = User.create(:login=>"test_mm3",:name=>"test_mm3",:email=>"test_mm3@gmail.com",:password=>"111111",:password_confirmation=>"111111",:region_id=>3)
user.roles << Role.find_by_name("MM")

user = User.create(:login=>"test_pm3",:name=>"test_pm3",:email=>"test_pm3@gmail.com",:password=>"111111",:password_confirmation=>"111111",:region_id=>3)
user.roles << Role.find_by_name("PM")

user = User.create(:login=>"test_wa3",:name=>"test_wa3",:email=>"test_wa3@gmail.com",:password=>"111111",:password_confirmation=>"111111",:region_id=>3)
user.roles << Role.find_by_name("WA")

user = User.create(:login=>"test_rm3",:name=>"test_rm3",:email=>"test_rm3@gmail.com",:password=>"111111",:password_confirmation=>"111111",:region_id=>3)
user.roles << Role.find_by_name("RM")

user = User.create(:login=>"test_rc3",:name=>"test_rc3",:email=>"test_rc3@gmail.com",:password=>"111111",:password_confirmation=>"111111",:region_id=>3)
user.roles << Role.find_by_name("RC")


user = User.create(:login=>"test_mm4",:name=>"test_mm4",:email=>"test_mm4@gmail.com",:password=>"111111",:password_confirmation=>"111111",:region_id=>4)
user.roles << Role.find_by_name("MM")

user = User.create(:login=>"test_pm4",:name=>"test_pm4",:email=>"test_pm4@gmail.com",:password=>"111111",:password_confirmation=>"111111",:region_id=>4)
user.roles << Role.find_by_name("PM")

user = User.create(:login=>"test_wa4",:name=>"test_wa4",:email=>"test_wa4@gmail.com",:password=>"111111",:password_confirmation=>"111111",:region_id=>4)
user.roles << Role.find_by_name("WA")

user = User.create(:login=>"test_rm4",:name=>"test_rm4",:email=>"test_rm4@gmail.com",:password=>"111111",:password_confirmation=>"111111",:region_id=>4)
user.roles << Role.find_by_name("RM")

user = User.create(:login=>"test_rc4",:name=>"test_rc4",:email=>"test_rc4@gmail.com",:password=>"111111",:password_confirmation=>"111111",:region_id=>4)
user.roles << Role.find_by_name("RC")