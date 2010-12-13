# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)
user = User.create(:login=>"test_mm",:name=>"test_mm",:email=>"test_mm@gmail.com",:password=>"111111",:password_confirmation=>"111111")
user.roles << Role.find_by_name("MM")

user = User.create(:login=>"test_pm",:name=>"test_pm",:email=>"test_pm@gmail.com",:password=>"111111",:password_confirmation=>"111111")
user.roles << Role.find_by_name("PM")

user = User.create(:login=>"test_wa",:name=>"test_wa",:email=>"test_wa@gmail.com",:password=>"111111",:password_confirmation=>"111111")
user.roles << Role.find_by_name("WA")

user = User.create(:login=>"test_rm",:name=>"test_rm",:email=>"test_rm@gmail.com",:password=>"111111",:password_confirmation=>"111111")
user.roles << Role.find_by_name("RM")

user = User.create(:login=>"test_rc",:name=>"test_rc",:email=>"test_rc@gmail.com",:password=>"111111",:password_confirmation=>"111111")
user.roles << Role.find_by_name("RC")