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

# read input file
printf('Reading input file...')
args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 1) {
  wst = read.csv(args[1])
} else {
  wst = read.csv("/dev/stdin")
}

printf('Processing data...')
attach(wst)
login = subset(wst, status=='login')
logout = subset(wst, status=='logout')

timestamp_vector <- as.character(timestamp)
printf('')
printf('Time Period: %s to %s', min(timestamp_vector), max(timestamp_vector))
printf('')

printf('Summary Statistics')
printf('  Total Entries:         %11s', num(nrow(wst)))
printf('  Logins:                %11s', num(nrow(login)))
printf('  Logouts:               %11s', num(nrow(logout)))
printf('  Unique Regular Users:  %11s', num(length(unique(subset(wst,guest_flag=='f')$user_hash))))
printf('  Unique Guest Users:    %11s', num(length(unique(subset(wst,guest_flag=='t')$user_hash))))
printf('  Unique Computer Names: %11s', num(length(unique(computer_name))))
       
