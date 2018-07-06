#Use this script to initialise folders

#Create list of main folders to create
folders = c("Input", "Output", "R")

#Create data folder
for(i in 1:length(folders)){
  if(!dir.exists(folders[i])){
    dir.create(folders[i])
  }else{
    print(paste(folders[i],"folder exists",sep = ""))
  }
}

#Initialise .Rprofile for loading of packages and running of function scripts
if(!file.exists("./.Rprofile")) # only create if not already there
  file.create("./.Rprofile")    # (don't overwrite it)
file.edit("./.Rprofile")



