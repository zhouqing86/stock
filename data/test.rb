$LOAD_PATH << File.expand_path('../lib', __FILE__)
require 'mysql2'
require 'active_record'
require 'stock'
require 'mechanize'
require 'nokogiri'
require 'hpricot'
require 'open-uri'

puts "test"
ActiveRecord::Base.establish_connection(
    :adapter=>"mysql2",
    :host=>"localhost",
    :database=>"stocks")
# ActiveRecord::Base.logger = ActiveSupport::Logger.new(STDOUT)
# stock = Stock.find(600000)
# puts stock.name

agent = Mechanize.new
page = agent.get('http://www.shdjt.com/sh.htm')
trs = page.search('#senfe').search('tr')
trs.each { |tr|
  tds = tr.search("td")
  no =  tds.first.inner_text.to_i
  next if no==0
  id, name, business = tds[1].inner_text, tds[2].search('a').first.inner_text, tds[3].inner_text
  puts "#{tds[1].inner_text},#{tds[2].search('a').first.inner_text},#{tds[3].inner_text}"
}
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