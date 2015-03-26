$LOAD_PATH << File.expand_path('../lib', __FILE__)
require 'mysql2'
require 'active_record'
require 'stock'
require 'mechanize'
require 'nokogiri'
require 'hpricot'
require 'open-uri'
require 'csv'
require 'yahoo_record_ss'
require 'yahoo_record_sz'
require 'shdjt_sz'
require 'shdjt_sh'
require 'date'

puts "test"
ActiveRecord::Base.establish_connection(
    :adapter=>"mysql2",
    :host=>"localhost",
    :database=>"stocks")
# ActiveRecord::Base.logger = ActiveSupport::Logger.new(STDOUT)
# stock = Stock.find(600000)
# puts stock.name

# agent = Mechanize.new
# page = agent.get('http://www.shdjt.com/sh.htm')
# trs = page.search('#senfe').search('tr')
# trs.each { |tr|
#   tds = tr.search("td")
#   no =  tds.first.inner_text.to_i
#   next if no==0
#   id, name, business = tds[1].inner_text, tds[2].search('a').first.inner_text, tds[3].inner_text
#   puts "#{tds[1].inner_text},#{tds[2].search('a').first.inner_text},#{tds[3].inner_text}"
# }
# page.search('#senfe').search('tr')[5].search("td").first.inner_text
# puts "#{page.methods}"
# text = table.methods
# puts table.object_id
# puts table.length

# url = "http://www.shdjt.com/sh.htm"
# doc = Hpricot(open(url))
# puts "#{doc.inspect}"
# table = doc.search("#senfe")
# puts "#{table.inspect}"

# agent = Mechanize.new
# page = agent.get('http://hq.sinajs.cn/list=sh601006')
# puts page.body.gsub("\"","").split(",")
#
# Stock.all.each{ |stock|
#   puts stock.id
# }

# def persist_record id, market, record
#   cdate, open, high, low, close, volume = record[0], record[1], record[2], record[3], record[4], record[5]
#   sql = "replace into yahoo_records_#{market}(stock_id,cdate,open,high,low,close,volume) values('#{id}','#{cdate}',#{open},#{high},#{low},#{close},#{volume})"
#   if market == "ss"
#     Stock::YahooRecordSS.connection.execute sql
#   else
#     Stock::YahooRecordSZ.connection.execute sql
#   end
# end

# agent = Mechanize.new
# file = File.new("fail_ids.txt")
# file.each_line{ |line|
#   begin
#     data = line.split(" ")
#     puts "#{data[0]} #{data[1]}"
#     page = agent.get(data[1])
#     if(data[0].to_i > 500000 || data[0] == "000001")
#       market = "ss"
#     else
#       market = "sz"
#     end
#     trading = CSV.parse(page.body, {:headers => TRUE})
#
#     current_time = Time.now
#     puts "start"
#     ActiveRecord::Base.transaction do
#       trading.each { |t|
#         persist_record data[0],market,t
#       }
#     end
#     puts "end #{Time.now - current_time}"
#     sleep(1)
#   rescue Exception => e
#     puts e.inspect
#   end
# }

# agent = Mechanize.new
# page = agent.get("http://ichart.finance.yahoo.com/table.csv?s=000001.sz&a=1&b=1&c=2000&d=2&e=16&f=2015&g=d&q=q&y=0&z=000001.sz&x=.csv")
# trading = CSV.parse(page.body, {:headers => TRUE})
# ActiveRecord::Base.transaction do
#       trading.each { |t|
#         persist_record "000001","sz",t
#       }
# end

# stock = Stock::Stock.new
# stock.id = "000001"
# stock.name = "上海证券"
# stock.code = "SSEC"
# stock.market = "ss"
# stock.


# agent = Mechanize.new
# url = "http://www.shdjt.com/gpdm.asp?gpdm=600007&page=1"
# page = agent.get(url)
# trs = page.search('#senfe').search('tr')
# trs.each { |tr|
#         tds = tr.search("td")
#         no = tds.first.inner_text.to_i
#         next if no==0
#         id = tds[2].inner_text
#         # stock.code = code(stock.name)
#         puts "persist:#{id}"
#         # stock.save
# }

stocks = Stock::ShdjtSH.find_by_sql("select stock_id,cdate from shdjt_sh where stock_id=600000 order by cdate desc limit 1")
p stocks.size
p stocks[0].stock_id
p stocks[0].cdate.strftime("%Y-%m-%d")
# ShdjtSH.select("stock_id,cdate").find_by(stock_id:"600016").order("end_date DESC")