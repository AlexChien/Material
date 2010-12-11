# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def flash_message
    messages = ""
    [:notice, :info, :warning, :error].each do|type|
      if flash[type]
        messages= "<div id=\"#{type}\">#{flash[type]}</div>"
      end
    end
    messages
  end
  
  def yield_title(title)
    default = "达能物料管理系统"
    title.nil? ? default : default + " - " + title
  end
  
  def nav_bar
    [
      {
        :navleft_header_name => "我的帐号",
        :navleft_header_logo => "/images/icons/application_home.png",
        :navleft => [
            { :name => "我的首页", :path => "/dashboard", :id => "dashboard", :logo => "/images/icons/user_suit.png"},
            { :name => "修改密码", :path => "/users/change_password_form", :id => "users_change_password", :logo => "/images/icons/key.png"}
          ]
      },
      {
        :navleft_header_name => "用户管理",
        :navleft_header_logo => "/images/icons/user_edit.png",
        :navleft => [
            { :name => "添加用户", :path => "/users/new", :id => "users_new", :logo => "/images/icons/user_add.png"},
            { :name => "所有用户", :path => "/users", :id => "users", :logo => "/images/icons/user.png"}
          ]
      }
    ]
  end
end
