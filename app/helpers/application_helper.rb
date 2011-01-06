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
    navleft = [
      {
        :navleft_header_name => "我的帐号",
        :navleft_header_logo => "/images/icons/application_home.png",
        :navleft => [
            { :name => "我的首页", :path => "/dashboard", :id => "dashboard", :logo => "/images/icons/user_suit.png"},
            { :name => "修改密码", :path => "/users/change_password_form", :id => "users_change_password", :logo => "/images/icons/key.png"}
          ]
      }
    ]
    if current_user.has_role?("admin")
      admin_manager = [
        {
        :navleft_header_name => "仓库管理",
        :navleft_header_logo => "/images/icons/package_green.png",
        :navleft => [
            { :name => "总仓库", :path => "/inventories?is_central=1", :id => "inventories_1", :logo => "/images/icons/package.png"},
            { :name => "其他仓库", :path => "/inventories?is_central=0", :id => "inventories_0", :logo => "/images/icons/package_go.png"},
          ]
        },
        {
        :navleft_header_name => "订单管理",
        :navleft_header_logo => "/images/icons/cart_edit.png",
        :navleft => [
            { :name => "所有订单", :path => "/orders", :id => "orders", :logo => "/images/icons/cart.png"},
          ]
        },
        {
        :navleft_header_name => "活动管理",
        :navleft_header_logo => "/images/icons/date_edit.png",
        :navleft => [
            { :name => "发起活动", :path => "/campaigns/new", :id => "campaigns_new", :logo => "/images/icons/date_add.png"},
            { :name => "所有活动", :path => "/campaigns", :id => "campaigns", :logo => "/images/icons/date.png"}
          ]
        },
        {
        :navleft_header_name => "物料管理",
        :navleft_header_logo => "/images/icons/brick_edit.png",
        :navleft => [
            { :name => "添加物料", :path => "/materials/new", :id => "materials_new", :logo => "/images/icons/brick_add.png"},
            { :name => "所有物料", :path => "/materials", :id => "materials", :logo => "/images/icons/brick.png"}
          ]
        },
        {
        :navleft_header_name => "大区管理",
        :navleft_header_logo => "/images/icons/world_edit.png",
        :navleft => [
            { :name => "所有大区", :path => "/regions", :id => "regions", :logo => "/images/icons/world.png"}
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
      navleft.concat(admin_manager)
    elsif current_user.has_role?("mm")
    elsif current_user.has_role?("pm")
      pm_manager = [
        {
        :navleft_header_name => "仓库管理",
        :navleft_header_logo => "/images/icons/package_green.png",
        :navleft => [
            { :name => "总仓库", :path => "/inventories?is_central=1", :id => "inventories_1", :logo => "/images/icons/package.png"},
            { :name => "其他仓库", :path => "/inventories?is_central=0", :id => "inventories_0", :logo => "/images/icons/package_go.png"},
          ]
        },
        {
        :navleft_header_name => "订单管理",
        :navleft_header_logo => "/images/icons/cart_edit.png",
        :navleft => [
            { :name => "所有订单", :path => "/orders", :id => "orders", :logo => "/images/icons/cart.png"},
          ]
        },
        {
        :navleft_header_name => "活动管理",
        :navleft_header_logo => "/images/icons/date_edit.png",
        :navleft => [
            { :name => "发起活动", :path => "/campaigns/new", :id => "campaigns_new", :logo => "/images/icons/date_add.png"},
            { :name => "所有活动", :path => "/campaigns", :id => "campaigns", :logo => "/images/icons/date.png"}
          ]
        },
        {
        :navleft_header_name => "物料管理",
        :navleft_header_logo => "/images/icons/brick_edit.png",
        :navleft => [
            { :name => "添加物料", :path => "/materials/new", :id => "materials_new", :logo => "/images/icons/brick_add.png"},
            { :name => "所有物料", :path => "/materials", :id => "materials", :logo => "/images/icons/brick.png"}
          ]
        },
        {
        :navleft_header_name => "大区管理",
        :navleft_header_logo => "/images/icons/world_edit.png",
        :navleft => [
            { :name => "所有大区", :path => "/regions", :id => "regions", :logo => "/images/icons/world.png"}
          ]
        }
      ]
      navleft.concat(pm_manager)
    elsif current_user.has_role?("wa")
      wa_manager = [
        {
        :navleft_header_name => "仓库管理",
        :navleft_header_logo => "/images/icons/package_green.png",
        :navleft => [
            { :name => "物料入库", :path => "/transfers/new?type=1", :id => "transfers_new", :logo => "/images/icons/package_add.png"},
            { :name => "总仓库", :path => "/inventories?is_central=1", :id => "inventories_1", :logo => "/images/icons/package.png"},
            { :name => "其他仓库", :path => "/inventories?is_central=0", :id => "inventories_0", :logo => "/images/icons/package_go.png"},
          ]
        },
        {
        :navleft_header_name => "物料发放",
        :navleft_header_logo => "/images/icons/basket_edit.png",
        :navleft => [
            { :name => "等待发放", :path => "/order_line_item_raws", :id => "order_line_item_raws", :logo => "/images/icons/basket.png"},
          ]
        }
      ]
      navleft.concat(wa_manager)
    elsif current_user.has_role?("rm")
      rm_manager = [
        {
        :navleft_header_name => "订单管理",
        :navleft_header_logo => "/images/icons/cart_edit.png",
        :navleft => [
            { :name => "审核订单", :path => "/orders", :id => "orders", :logo => "/images/icons/cart.png"},
          ]
        },
        {
        :navleft_header_name => "申领管理",
        :navleft_header_logo => "/images/icons/basket_edit.png",
        :navleft => [
            { :name => "审核申领", :path => "/order_line_item_raws", :id => "order_line_item_raws", :logo => "/images/icons/basket.png"},
          ]
        }
      ]
      navleft.concat(rm_manager)
    elsif current_user.has_role?("rc")
      rc_manager = [
        {
        :navleft_header_name => "我要预定",
        :navleft_header_logo => "/images/icons/cart_edit.png",
        :navleft => [
            { :name => "物料预定", :path => "/campaigns", :id => "campaigns", :logo => "/images/icons/cart.png"},
          ]
        },
        {
        :navleft_header_name => "我要申领",
        :navleft_header_logo => "/images/icons/basket_edit.png",
        :navleft => [
            { :name => "物料申领", :path => "/order_line_item_raws", :id => "order_line_item_raws", :logo => "/images/icons/basket.png"},
          ]
        },
        {
        :navleft_header_name => "销售代表",
        :navleft_header_logo => "/images/icons/user_edit.png",
        :navleft => [
            { :name => "添加销售", :path => "/salesreps/new", :id => "salesreps_new", :logo => "/images/icons/user_add.png"},
            { :name => "所有销售", :path => "/salesreps", :id => "salesreps", :logo => "/images/icons/user.png"},
          ]
        }
      ]
      navleft.concat(rc_manager)
    end
    navleft
  end
end
