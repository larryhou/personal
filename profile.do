cmdlog using ~/Documents/Stata/personal/command.log, replace
log using ~/Documents/Stata/personal/stata.log, smcl replace

sysdir set PERSONAL "~/Documents/Stata/personal"
sysdir set PLUS "~/Documents/Stata/plus"
graph set window fontface "Verlag-Book"

cd "~/Documents/Stata"
update all