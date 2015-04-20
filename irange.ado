capture program drop irange
program define irange, rclass
	
	#delimit ;
	syntax varlist(numeric) [if] [in] 
							[, Box Level(real 95)
							Prefix(varlist)
							Cellwidth(int 12)
							Format(string)
							Outter];
	#delimit cr
	
	if "`format'" == "" local format = "%6.4f"
	
	local type = upper("`box'")
	if "`type'" == "" local type = "`level'%"
	
	#delimit ;
	dis "{txt}"
		"{ralign `cellwidth':Variable }{c |}"
		"{ralign `cellwidth':Obs}"
		"{ralign `cellwidth':Mean}"
		"{ralign `cellwidth':Std. Dev.}"
		"{ralign `=`cellwidth'*2':[`type' Value Range]}";
	#delimit cr
	
	foreach var of local varlist {
		quietly sum `var' `if' `in', detail
		if "`box'" == "box" {
			local lb = r(p25) - (r(p75) - r(p25)) * 1.5
			local ub = r(p75) + (r(p75) - r(p25)) * 1.5
		} 
		else {
			local prob = 1 - `level' / 100
			local ub = invnormal(1 - `prob'/2) * r(sd) + r(mean)
			local lb = invnormal(`prob'/2) * r(sd) + r(mean)
		}
		
		local mean = r(mean)
		
		dis "{txt}{hline `cellwidth'}{c +}{hline `=`cellwidth'*5'}"
		
		#delimit ;
		dis "{res}"
			"{ralign `cellwidth':{txt:" abbrev("`var'", `cellwidth') " }}{txt:{c |}}"
			"{ralign `cellwidth':" `r(N)' "}"
			"{ralign `cellwidth':" `format' `r(mean)' "}"
			"{ralign `cellwidth':" `format' `r(sd)' "}"
			"{ralign `cellwidth':" `format' `lb' "}"
			"{ralign `cellwidth':" `format' `ub' "}";
		#delimit cr
		
		if "`outter'" != "" {
			if "`if'" == "" local cond = "if `var' < `lb' | `var' > `ub'"
			else local cond = "`if' `var' < `lb' | `var' > `ub'"
			list `prefix' `var' `cond' `in'
		}
	}
	
	return scalar lb = `lb'
	return scalar ub = `ub'
	return scalar mean = r(mean)
	return scalar max = r(max)
	return scalar min = r(min)
	return scalar sd = r(sd)
end
