require "active_record"
module Stock
  class YahooRecordSS < ActiveRecord::Base
    self.table_name = "yahoo_records_ss"
  end
end