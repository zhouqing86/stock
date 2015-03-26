require 'mechanize'
require 'stock'
require 'mysql2'
require 'active_record'
require 'hanzi_code'
require 'transaction'
require 'yahoo_record_ss'
require 'yahoo_record_sz'
require 'shdjt_sz'
require 'shdjt_sh'
require 'csv'
require 'date'

module Stock
  class Service
    include HanziCode

    def initialize
      ActiveRecord::Base.establish_connection(
          :adapter => "mysql2",
          :host => "localhost",
          :database => "stocks")
    end

    def persist_stocks
      persist_sh_stocks
      persist_sz_stocks
    end

    def persist_sh_stocks
      persist_stocks 'http://www.shdjt.com/sh.htm', "sh"
    end

    def persist_stocks url, market
      agent = Mechanize.new
      page = agent.get(url)
      trs = page.search('#senfe').search('tr')
      trs.each { |tr|
        tds = tr.search("td")
        no = tds.first.inner_text.to_i
        next if no==0
        id = tds[1].inner_text
        stock = Stock.find_or_initialize_by(id: id)
        stock.market = market
        stock.id, stock.name, stock.business = id, tds[2].search('a').first.inner_text, tds[3].inner_text
        stock.code = code(stock.name)
        puts "persist:#{id},#{stock.name},#{stock.business},#{stock.code}"
        stock.save
      }
    end

    def persit_shdjt options
      puts "persit_shdjt"
      options["end_date"] ||= Date.today.strftime("%Y-%m-%d")
      options["start_date"] ||= (Date.today - 60*7).strftime("%Y-%m-%d")
      persist_shdjt_stocks "sh", options["start_date"], options["end_date"]
      persist_shdjt_stocks "sz", options["start_date"], options["end_date"]
    end

    def page start_date, end_date
      ( start_date .. end_date ).select {|d| (1..5).include?(d.wday) }.size / 20
    end

    def persist_shdjt_stocks market, start_date, end_date
      url = "http://www.shdjt.com/gpdm.asp?gpdm="
      Stock.where(:market=>"#{market}").each { |stock|
        begin
          current_time = Time.now
          puts "start"
          sql = "select stock_id,cdate from shdjt_#{market} where stock_id=#{stock.id} order by cdate desc limit 1"
          records = market == "sh" ? ShdjtSH.find_by_sql(sql) : ShdjtSZ.find_by_sql(sql)
          if records.size != 0 &&  records[0].cdate.strftime("%Y-%m-%d") >= end_date
            puts "skip #{stock.id}, end_date:#{end_date}" 
            next
          end
          # ActiveRecord::Base.transaction do
            (1..15).reverse_each{ |index|
                persist_shdjt_stock "#{url}#{stock.id}&page=#{index}",market,stock.id
                sleep 3
            }
          # end
          puts "end #{Time.now - current_time}"
        rescue Exception=>e
          puts e.inspect
          raise "Exception"
        end
      }
      # agent = Mechanize.new
      # page = agent.get(url)
      # trs = page.search('#senfe').search('tr')
    end

    def persist_shdjt_stock url, market, id
        puts url
        agent = Mechanize.new
        page = agent.get(url)
        trs = page.search('#senfe').search('tr')
        trs.each { |tr|
          tds = tr.search("td")
          no = tds.first.inner_text.to_i
          next if no==0
          # stock_id = tds[2].inner_text
          cdate = tds[0].inner_text
          s = market == "sh" ? ShdjtSH.find_by(stock_id:id,cdate:cdate) : ShdjtSZ.find_by(stock_id:id,cdate:cdate)
          next unless s.nil?

          s = market == "sh" ? ShdjtSH.new : ShdjtSZ.new
          s.stock_id = id
          s.cdate = cdate
          s.close = tds[4].inner_text.to_f
          s.rise = tds[5].inner_text.to_f
          s.ddx = tds[6].inner_text.to_f
          s.ddy = tds[7].inner_text.to_f
          s.ddz = tds[8].inner_text.to_f
          s.net_amount = tds[9].inner_text.to_f
          s.largest_residual_quantity = tds[10].inner_text.to_i
          s.large_residual_quantity = tds[11].inner_text.to_i
          s.mid_residual_quantity = tds[12].inner_text.to_i
          s.small_residual_quantity = tds[13].inner_text.to_i
          s.strength = tds[14].inner_text.to_f
          s.zhudonglv = tds[15].inner_text.to_f
          s.tongchilv = tds[16].inner_text.to_f
          s.largest_residual = tds[17].inner_text.to_f
          s.large_residual = tds[18].inner_text.to_f
          s.mid_residual = tds[19].inner_text.to_f
          s.small_residual = tds[20].inner_text.to_f
          s.activeness = tds[21].inner_text.to_f
          s.danshubi = tds[22].inner_text.to_f
          s.ddx_5 = tds[23].inner_text.to_f
          s.ddy_5 = tds[24].inner_text.to_f
          s.ddx_60 = tds[25].inner_text.to_f
          s.ddy_60 = tds[26].inner_text.to_f
          s.ci = tds[27].inner_text.to_i
          s.lian = tds[28].inner_text.to_i
          s.xiaodanchashou = tds[29].inner_text.to_i
          s.zijinqiangdu = tds[30].inner_text.to_i
          s.buy_amount = tds[31].inner_text.to_i
          s.sale_amount = tds[32].inner_text.to_i
          s.buy_per_average = tds[33].inner_text.to_f
          s.sale_per_average = tds[34].inner_text.to_f
          s.xiaodanleiji = tds[35].inner_text.to_i
          s.jingeleiji = tds[36].inner_text.to_i
          s.largest_buy = tds[37].inner_text.to_f
          s.largest_sale = tds[38].inner_text.to_f
          s.large_buy = tds[39].inner_text.to_f
          s.large_sale = tds[40].inner_text.to_f
          s.mid_buy = tds[41].inner_text.to_f
          s.mid_sale = tds[42].inner_text.to_f
          s.small_buy = tds[43].inner_text.to_f
          s.small_sale = tds[44].inner_text.to_f
          s.huanshoulv = tds[45].inner_text.to_f
          s.liangbi = tds[46].inner_text.to_f
          s.price_earning_rate = tds[47].inner_text.to_f
          s.earnings_per_share = tds[48].inner_text.to_f

          puts "persist:#{s.stock_id},#{s.cdate},#{s.ddx},#{s.ddy},#{s.ddz} persist to db"
          s.save
        }

    end

    def persist_stocks_info
      agent = Mechanize.new
      base ="http://hq.sinajs.cn/list="

      Stock.all.each { |stock|
        begin
          url = "#{base}#{stock.market}#{stock.id}"
          page = agent.get(url)
          stock_info = page.body.gsub("\"", "").split(",")
          transaction = stock_from_array stock.id, stock_info
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

    def stock_from_array id, arr
      today = DateTime.parse(Time.now.to_s).strftime('%Y-%m-%d').to_s
      transaction = Transaction.find_or_initialize_by(date: today, stock_id: id)
      transaction.stock_id = id
      transaction.open = arr[1]
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
      persist_stocks 'http://www.shdjt.com/sz.htm', "sz"
    end

    def persist_yahoo_history_stocks
      Stock.all.each { |stock|
        persist_one_stock_records stock
      }
    end

    def persist_one_stock_records stock
      agent = Mechanize.new
      base = "http://ichart.finance.yahoo.com/table.csv?"
      market = stock.market == "sh" ? "ss" : "sz"
      year, month, day = Time.now.year, Time.now.month, Time.now.day
      url = "#{base}s=#{stock.id}.#{market}&a=1&b=1&c=2015&d=#{month}&e=#{day}&f=#{year}&g=d&q=q&y=0&z=#{stock.id}.#{market}&x=.csv"
      puts url
      page = agent.get(url)
      trading = CSV.parse(page.body, {:headers => TRUE})

      current_time = Time.now
      puts "start"
      ActiveRecord::Base.transaction do
        trading.each { |t|
          persist_record stock.id,market,t
        }
      end
      puts "end #{Time.now - current_time}"
    rescue Exception => e
      puts e.inspect
    end

    def persist_record id, market, record
      cdate, open, high, low, close, volume = record[0], record[1], record[2], record[3], record[4], record[5]
      sql = "replace into yahoo_records_#{market}(stock_id,cdate,open,high,low,close,volume) values('#{id}','#{cdate}',#{open},#{high},#{low},#{close},#{volume})"
      if market == "ss"
        YahooRecordSS.connection.execute sql
      else
        YahooRecordSZ.connection.execute sql
      end
    end
  end
end