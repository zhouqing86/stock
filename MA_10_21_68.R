library(quantmod)
library(TTR)
MA.10_21_68 <- function(x){
  getSymbols("SYZY",from=today-400, to=today)
  chartSeries(x)
  addTA(SMA(Cl(x),10),on=1,col="red")
  addTA(SMA(Cl(x),21),on=1,col="green")
  addTA(SMA(Cl(x),68),on=1,col="blue")
}