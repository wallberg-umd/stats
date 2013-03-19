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

printf <- function(...) {
  print(sprintf(...), quote = FALSE)
}

num <- function(num) {
  format(num, big.mark = ",", scientific = FALSE)
}

getBuilding <- function(name) {
  # strip off leading 'libwk'
  name = substring(name,6)
  # strip off numbers and everything following
  name = gsub('^([^0-9]*).*$','\\1',name)
  # convert empty string to 'unknown'
  name[name==''] <- 'unknown'
  return(name)
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
wst <- transform(wst_orig, computer_name=tolower(computer_name))
wst <- subset(wst, substr(computer_name,1,5) == 'libwk')
wst <- transform(wst, building=getBuilding(computer_name))
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
printf('  Unique Regular Users:  %11s', num(length(unique(subset(wst,guest_flag=='f')$user_hash))))
printf('  Unique Guest Users:    %11s', num(length(unique(subset(wst,guest_flag=='t')$user_hash))))
printf('  Unique Computer Names: %11s', num(length(unique(computer_name))))
printf('')

printf('Logins by Building')
logins.building <- tapply(login$building, login$building, FUN=length)
for (row in rownames(logins.building)) {
  printf('  %8s %10s',row,num(logins.building[row]))
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
