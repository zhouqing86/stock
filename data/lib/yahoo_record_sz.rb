require "active_record"
module Stock
  class YahooRecordSZ < ActiveRecord::Base
    self.table_name = "yahoo_records_sz"
  end
end