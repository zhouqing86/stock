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

build.simple.frame <- function(v, dimension=10){
  frame <- data.frame()
  for(index in length(v):dimension){
    ve <- as.vector(v[(index-dimension):index])
    #ve <- as.vector(v[(index-dimension):(index-1)])
    #s <- sign(as.vector(v[index])-as.vector(v[index-1]))
    #ve <- c(ve,s)
    frame <- rbind(frame,ve)
  }
  frame
}

weight <- function(v){ 
  set.seed(10)
  x<-runif(10,min=0,max=1)
  x<-x/sum(x);
  x %*% v
}

iris.nnetwork <- function(){
  a<-0.2
  w<-rep(0,3)
  iris1<-t(as.matrix(iris[,3:4]))
  d<-c(rep(0,50),rep(1,100))
  e<-rep(0,150)
  p<-rbind(rep(1,150),iris1)
  max<-100000
  eps<-rep(0,100000)
  i<-0
  repeat{
    v<-w%*%p;
    y<-ifelse(sign(v)>=0,1,0);
    e<-d-y;
    eps[i+1]<-sum(abs(e))/length(e)
    if(eps[i+1]<0.01){
      print("finish:");
      print(abs(e));
      print(w);
      break;
    }
    w<-w+a*(d-y)%*%t(p);
    i<-i+1;
    if(i>max){
      print("max time loop:");
      print(abs(e))
      print(eps[i])
      print(y);
      break;
    }
  }
}


stock.cl.nnetwork <- function(m,dimension=10){
  a<-0.2
  w<-rep(0,dimension)
  iris1<-t(m[,1:dimension])
  d<-m[,dimension+1]
  e<-rep(0,nrow(m))
  p<-rbind(rep(1,150),iris1)
  max<-100000
  eps<-rep(0,100000)
  i<-0
  repeat{
    v<-w%*%p;
    y<-ifelse(sign(v)>=0,1,0);
    e<-d-y;
    eps[i+1]<-sum(abs(e))/length(e)
    if(eps[i+1]<0.01){
      print("finish:");
      print(abs(e));
      print(w);
      break;
    }
    w<-w+a*(d-y)%*%t(p);
    i<-i+1;
    if(i>max){
      print("max time loop:");
      print(abs(e))
      print(eps[i])
      print(y);
      break;
    }
  }
}
