require "active_record"
module Stock
  class Stock < ActiveRecord::Base
    self.table_name = "stock"
  end
end