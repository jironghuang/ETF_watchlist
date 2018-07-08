# https://github.com/jennybc/googlesheets/blob/master/vignettes/managing-auth-tokens.md
# library("googlesheets")
# token <- gs_auth(cache = FALSE)
# gd_token()
# saveRDS(token, file = "googlesheets_token.rds")

# gs_ls()

#Obtain the API KEY for google 
rsd_file = Sys.getenv("GOOGLESHEET")
gs_auth(token = rsd_file)
## and you're back in business, using the same old token
## if you want silence re: token loading, use this instead
suppressMessages(gs_auth(token = rsd_file, verbose = FALSE))

dat = gs_title("Investment")
gs_ws_ls(dat)   #tab names
data <- gs_read(ss=dat, ws = "monthly_dashboard", skip=0)
data = as.data.frame(data)
data = subset(data,select = c("Date","NW","NW_exCPF","Portfolio","Portfolio_and_CPFOA_STIETF"))
data$Date = as.Date(data$Date,origin = "1899-12-30")


