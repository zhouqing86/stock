require 'mechanize'
require 'stock'
require 'mysql2'
require 'active_record'
require 'hanzi_code'

module Stock
  class Service
    include HanziCode

    def initialize
      ActiveRecord::Base.establish_connection(
          :adapter=>"mysql2",
          :host=>"localhost",
          :database=>"stocks")
    end

    def persist_stocks
      persist_ss_stocks
      persist_sz_stocks
    end

    def persist_ss_stocks
      persist_stocks 'http://www.shdjt.com/sh.htm',"ss"
    end

    def persist_stocks url,market
      agent = Mechanize.new
      page = agent.get(url)
      trs = page.search('#senfe').search('tr')
      trs.each { |tr|
        tds = tr.search("td")
        no =  tds.first.inner_text.to_i
        next if no==0
        id = tds[1].inner_text
        stock = Stock.find_or_initialize_by(id:id)
        stock.market = market
        stock.id, stock.name, stock.business = id, tds[2].search('a').first.inner_text, tds[3].inner_text
        stock.code = code(stock.name)
        puts "persist:#{id},#{stock.name},#{stock.business},#{stock.code}"
        stock.save
      }
    end

    def persist_sz_stocks
      persist_stocks 'http://www.shdjt.com/sz.htm',"sz"
    end
  end
end