library(TTR)
library(quantmod)
library(RMySQL)
loadSymbolLookup(file="mysymbols.rda")


stock.init <- function(){
	stocks <- read.table('all_stocks_with_daima_static.txt',header=F,stringsAsFactors=F)
	daima  <<- stocks$V3
	today <<- Sys.Date()
}

stock.recent.active.day <- function(day){
	#目前的实现不完善，只考虑了周日和周末
	weekday <- weekdays(day)
	if(weekday == "Saturday") return (day-1)
	if(weekday == "Sunday") return (day-2)
  day
}

stock.update <- function(previous=400){
	stock.init()
	for(i in 1:length(daima)){
		tryCatch({
			time <- index(get(daima[i]))
			active.day <- stock.recent.active.day(today)
			if(time[length(time)] == active.day){
				print(paste("Skip ", daima[i]))
				next
			}
			print(paste(time[length(time)],",",active.day))
			print(paste("Update ", daima[i]))
			getSymbols(daima[i],from=today-previous,to=today)
			# getSymbols(daima[i],to=today)
			# STOCKS = c(STOCKS,get(daima[i]))
			assign(daima[i],get(daima[i]),envir = .GlobalEnv)
			# assign(daima[i],get(daima[i]),envir = .GlobalEnv)
		})
	}
}

stock.db.connection <- function(){
        dbConnect(MySQL(),
                 user='root',
                 password='',
                 dbname='stocks',
                 host="localhost")
}

stock.persist <- function(){
	#stock.update(previous=2000)
	stocks <- read.table('all_stocks_with_daima_static.txt',header=F,stringsAsFactors=F)
	con <- stock.db.connection()
	for(i in 1:nrow(stocks)){
		stock <- get(stocks[i,3])
		id <- stocks[i,1] * nrow(stock)
		dbWriteTable(con,name="yahoo_stocks",value=cbind(id,stock), append = T)
	}

}

ma.10.20.warning <- function(stock,days=5){
	stock.update()
	for(i in 1:length(daima)){
		stock <- get(daima[i])
		ma_10 <- MA(cl(stock),10)
		ma_20 <- MA(cl(stock),20)
	}
}