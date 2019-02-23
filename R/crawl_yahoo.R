#Yahoo finance crawler
#Run this in bash shell 
# cd Desktop/github/ETF_watchlist/
# Rscript ./R/crawl_yahoo.R

# check.packages function: install and load multiple R packages.
# Check to see if packages are installed. Install them if they are not, then load them into the R session.
check.packages <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg)) 
    install.packages(new.pkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}

# Usage example
packages<-c("stringr", "RCurl", "parallel", "plyr", "googlesheets", "compiler", "rPython")
check.packages(packages)

#loading data
yahoo_list = read.csv("Input/yahoo_prices.csv",stringsAsFactors = FALSE)
# yahoo_list = yahoo_list[-grep("\\.L", yahoo_list$Ticker),]

yahoo_list$link = paste("https://finance.yahoo.com/quote/",yahoo_list$Ticker,"?p=",yahoo_list$Ticker,sep = "")
yahoo_list$fifty_two_weekrange = ""
yahoo_list$fifty_two_weekhigh = ""
yahoo_list$fifty_two_weeklow = ""

#crawl data function
crawl_data = function(i){
  
  data = as.data.frame(yahoo_list[i,])
  
  tryCatch({
    print(i);print(yahoo_list$Ticker[i]);yahoo_list$Price[i-1]
    html = getURL(yahoo_list$link[i]) 
    
    if(length(html)>=1){
      
      if(grepl("Summary for ",html) == TRUE){
        name_h = str_locate(html,'Summary for ')[1,2]
        name = substring(html, first = name_h-100, last = name_h+100)  
        name = substring(name,
                         first = str_locate(name,"Summary for ")[1,2]+1,
                         last = str_locate(name,"Yahoo Finance")[1,1]-4)      
        data$Name = name
      }
      
      if(grepl("data-reactid=\"35\">",html) == TRUE){
        #In numeric
        price_h = str_locate_all(html,'data-reactid=\"35\">')[[1]][2,2]
        price = substring(html, first = price_h+1, last = price_h+100)  
        price = substring(price,
                          first = 1,
                          last = str_locate(price,"<")[1,1]-1)      
        data$Price = price
      }
      
      if(grepl('data-test="PE_RATIO-value"',html) == TRUE){
        pe_h = str_locate(html,'data-test="PE_RATIO-value"')[1,2]
        pe = substring(html, first = pe_h-200, last = pe_h+200)  
        pe = substring(pe,
                       first = str_locate(yahoo_list$P.E[i],"<!-- react-text: 101 -->")[1,2]+1,
                       last = str_locate(yahoo_list$P.E[i],"<!-- /react-text --></span>")[1,1]-1)  
        data$P.E = pe
      }
      
      if(grepl('FIFTY_TWO_WK_RANGE',html) == TRUE){
        fifty_two_week_h = str_locate(html,'FIFTY_TWO_WK_RANGE')[1,2]
        fifty_two_weekrange= substring(html, first = fifty_two_week_h+1, last = fifty_two_week_h+200)  
        fifty_two_weekrange = substring(fifty_two_weekrange,
                                        first = str_locate(fifty_two_weekrange,'>')[1,2]+1,
                                        last = str_locate(fifty_two_weekrange,'<')[1,1]-1)  
        data$fifty_two_weekrange = fifty_two_weekrange
        
        print(fifty_two_weekrange)
      }
    } #if length of html more than 1
    
  }, error=function(e){
    print("Error in crawling")
    # write.csv(cars, "test.csv")   #You can do things in exception handling
  })#try catch
  
  return(data)
}

#Compile the function to increase the speed
cmp_crawl_data = cmpfun(crawl_data)

#crawling the data with multi-core
#finance_data = lapply(2: nrow(yahoo_list), cmp_crawl_data)
finance_data = mclapply(1: nrow(yahoo_list), cmp_crawl_data, mc.cores = detectCores())
yahoo_list = rbind.fill(finance_data)

#Functions for formatting string
range_fx_high = function(range){
  range = gsub(",","",range)
  a = strsplit(range," - ")
  fifty_two_weekhigh = a[[1]][2]
  return(fifty_two_weekhigh)
}

range_fx_low = function(range){
  range = gsub(",","",range)
  a = strsplit(range," - ")
  fifty_two_weeklow = a[[1]][1]
  return(fifty_two_weeklow)
}

#formatting data
yahoo_list$fifty_two_weekhigh = as.numeric(lapply(yahoo_list$fifty_two_weekrange,range_fx_high))
yahoo_list$fifty_two_weeklow = as.numeric(lapply(yahoo_list$fifty_two_weekrange,range_fx_low))
yahoo_list$Price = as.numeric(gsub(",","",yahoo_list$Price))

yahoo_list$Change_fr_52_week_high = (yahoo_list$Price - yahoo_list$fifty_two_weekhigh)/yahoo_list$fifty_two_weekhigh
yahoo_list$Change_fr_52_week_low = (yahoo_list$Price - yahoo_list$fifty_two_weeklow)/yahoo_list$fifty_two_weeklow

yahoo_list = arrange(yahoo_list,Change_fr_52_week_high)

write.csv(yahoo_list,"Output/yahoo_crawled_data.csv",row.names = FALSE)

#Uploading data in googlesheet
source("R/auth.R")  #authorization in googlesheet (dont reveal your .rds file. Store in a local location, preferably the path as a system variable)

dat <- dat %>%
  gs_edit_cells(ws = "Yahoo", input = yahoo_list, trim = TRUE)

#Send it every monday only
if(strsplit(date(), " ")[[1]][1] == "Sat"){
  #source("R/send_mail.R") 
  python.load("R/send_email.py")
}







