#
# Workstation Tracking statistics
#
# expect CSV input file with header row:
#   id
#   computer_name
#   guest_flag
#   os
#   status
#   timestamp
#   user_hash

library(stringr)

printf <- function(...) {
  print(sprintf(...), quote = FALSE)
}

num <- function(num) {
  format(num, big.mark = ",", scientific = FALSE)
}

# Get location of workstation using regex matching on the workstation name
location.cache = new.env(hash=TRUE)

getLocation <- function(location) {

  for (i in seq_along(location)) {
    name = location[i]
    
    cache.hit = FALSE
    location.mapped = NULL
    
    if (exists(name, envir=location.cache)) {
      # use the cached value
      location.mapped <- location.cache[[name]]
      cache.hit = TRUE
      
    } else if (str_detect(name, perl('^libwkmck1f\\d+.*$'))) {
      location.mapped <- 'McKeldin Library 1st floor'
    
    } else if (str_detect(name, perl('^libwkm[abcd]2f\\d+.*$'))) {
      location.mapped <- 'McKeldin Library 2nd floor'
    
    } else {
      location.mapped <- 'Unknown Location'
    }
    
    location[i] <- location.mapped
    
    # save the mapping in the cache
    if (! cache.hit) {
      location.cache[[name]] = location.mapped
    }
  }

  return(location)
}

# read input file
printf('Reading input file...')
args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 1) {
  wst_orig= read.csv(args[1])
} else {
  wst_orig= read.csv("/dev/stdin")
}

printf('Processing data...')
names(wst_orig) <- gsub("\\.", "_", tolower(names(wst_orig)))
wst <- transform(wst_orig, computer_name=tolower(computer_name))
wst <- subset(wst, substr(computer_name,1,5) == 'libwk')
wst <- transform(wst, location=getLocation(computer_name))
wst <- transform(wst, timestamp=as.POSIXct(timestamp, "%Y-%m-%d %H:%M:%S", tz="UTC"))
wst <- transform(wst, wday=weekdays(as.Date(timestamp)))
attach(wst)
login = subset(wst, status=='login')
logout = subset(wst, status=='logout')

timestamp_vector <- as.character(timestamp)
printf('')
printf('Time Period: %s to %s', min(timestamp_vector), max(timestamp_vector))
printf('')

printf('Summary Statistics')
printf('  Total Entries:         %11s', num(nrow(wst_orig)))
printf('  Accepted Entries:      %11s', num(nrow(wst)))
printf('  Logins:                %11s', num(nrow(login)))
printf('  Logouts:               %11s', num(nrow(logout)))
printf('  Unique Regular Users:  %11s', num(length(unique(subset(wst,guest_flag=='false')$user_hash))))
printf('  Unique Guest Users:    %11s', num(length(unique(subset(wst,guest_flag=='true')$user_hash))))
printf('  Unique Computer Names: %11s', num(length(unique(computer_name))))
printf('')

printf('Logins by Location')
logins.location <- tapply(login$location, login$location, FUN=length)
for (row in rownames(logins.location)) {
  printf('  %8s %10s',row,num(logins.location[row]))
}
printf('')

printf('Logins by OS')
logins.os <- tapply(login$os, login$os, FUN=length)
for (row in rownames(logins.os)) {
  printf('  %20s %10s',row,num(logins.os[row]))
}
printf('')

printf('Logins by Day of the Week')
logins.wday <- tapply(login$wday, login$wday, FUN=length)
for (row in c('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday')) {
  printf('  %9s %10s',row,num(logins.wday[row]))
}
printf('')

#print(wst)
#write.table(wst,file="data/out.csv",sep=",",row.names=TRUE)
