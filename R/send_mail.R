#Steps for sending watchlist
library("rJava")
library('mailR')

source("./R/emails.R")

# Write the content of your email
msg <- paste("Hey there, I'm sending this ETF watchlist that is updated as of ", 
             "\n",
             as.character(date()),
             "\n",
             "This is part of my daily automated ETF dashboard + Email notification and I thought you may be interested in it. See the following link for more details: http://jirong-huang.netlify.com/project/watch_list/",
             "\n",
             "If this irritates you too much, let me know and I can take you out of this mailing list:)","","Best,","Jirong", sep = "\n")

# Define who the sender is
sender <- "jironghuang88@gmail.com"
# Define who should get your email
recipients <- emails
              # Send your email with the send.mail function
              send.mail(from = sender,
                        to = recipients,
                        subject = "ETF Watchlist",
                        body = msg,
                        attach.files = "./Output/yahoo_crawled_data.csv",
                        smtp = list(host.name = "smtp.gmail.com", port = 587,
                                    user.name = "jironghuang88@gmail.com",
                                    passwd = Sys.getenv("mail"), ssl = TRUE),
                        authenticate = TRUE,
                        send = TRUE)
              
              # JAVA_HOME /usr/lib/jvm/java-8-oracle             