capture program drop itest
program itest, rclass byable(recall) sortpreserve
args var
display "_sortindex=`_sortindex'"
display "_by()=`_by()'"
display "_byindex()=`_byindex()'"
sum `var'
end
