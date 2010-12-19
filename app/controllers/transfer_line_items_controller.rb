class TransferLineItemsController < ApplicationController
  before_filter :login_required
  
  access_control do
    allow :wa
  end
  
end
