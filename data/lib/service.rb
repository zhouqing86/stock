require 'mechanize'
require 'stock'
require 'mysql2'
require 'active_record'
require 'hanzi_code'
require 'transaction'

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
      persist_sh_stocks
      persist_sz_stocks
    end

    def persist_sh_stocks
      persist_stocks 'http://www.shdjt.com/sh.htm',"sh"
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

    def persist_stocks_info
      agent = Mechanize.new
      base ="http://hq.sinajs.cn/list="

      Stock.all.each { |stock|
        begin
          url = "#{base}#{stock.market}#{stock.id}"
          page = agent.get(url)
          stock_info = page.body.gsub("\"","").split(",")
          transaction = stock_from_array stock.id,stock_info
          puts "#{stock.id} to db"
          transaction.save
        rescue Exception => e
          puts e.inspect
          next
        end
      }
    end

    # ["var hq_str_sh601006=\xB4\xF3\xC7\xD8\xCC\xFA\xC2\xB7", "10.49", "10.49", "10.46",
    #  "10.58", "10.36", "10.46", "10.47", "70313829", "735753293",
    #  "7700", "10.46", "108100", "10.45", "12300", "10.44", "41400", "10.43",
    #  "142600", "10.42", "249194", "10.47", "112905", "10.48", "339800", "10.49",
    #  "477702", "10.50", "67300", "10.51", "2015-02-13", "15:03:03", "00;\n"]

    def stock_from_array id,arr
      today = DateTime.parse(Time.now.to_s).strftime('%Y-%m-%d').to_s
      transaction = Transaction.find_or_initialize_by(date:today,stock_id:id)
      transaction.stock_id = id
      transaction.open =  arr[1]
      transaction.closeprev = arr[2]
      transaction.close = arr[3]
      transaction.High = arr[4]
      transaction.Low = arr[5]
      transaction.amount = arr[8]
      transaction.volume = arr[9]
      transaction.buy1amount = arr[10]
      transaction.buy1price = arr[11]
      transaction.buy2amount = arr[12]
      transaction.buy2price = arr[13]
      transaction.buy3amount = arr[14]
      transaction.buy3price = arr[15]
      transaction.buy4amount = arr[16]
      transaction.buy4price = arr[17]
      transaction.buy5amount = arr[18]
      transaction.buy5price = arr[19]
      transaction.sell1amount = arr[20]
      transaction.sell1price = arr[21]
      transaction.sell2amount = arr[22]
      transaction.sell2price = arr[23]
      transaction.sell3amount = arr[24]
      transaction.sell3price = arr[25]
      transaction.sell4amount = arr[26]
      transaction.sell4price = arr[27]
      transaction.sell5amount = arr[28]
      transaction.sell5price = arr[29]
      transaction.enter_date = arr[30]
      transaction.date = today
      transaction
    end

    def persist_sz_stocks
      persist_stocks 'http://www.shdjt.com/sz.htm',"sz"
    end
  end
end