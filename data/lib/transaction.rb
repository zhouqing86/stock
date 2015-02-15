require "active_record"
module Stock
  class Transaction < ActiveRecord::Base
    self.table_name = "transaction"
  end
end