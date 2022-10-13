cmdlog using ~/Documents/Stata/personal/command.log, replace
log using ~/Documents/Stata/personal/stata.log, smcl replace

sysdir set PERSONAL "~/Documents/Stata/personal"
sysdir set PLUS "~/Documents/Stata/plus"
graph set window fontface "JetBrainsMono-Thin"

cd ~/Documents/Stata/workspace

set more off, permanently
set type double
