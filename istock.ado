capture program drop istock
program define istock, rclass
	
	#delimit ;
	syntax , Ticker(string) 
	[
		Dir(string)
		Span(int 180)
		Probplot
		Rateplot
		Export
		Filter(int 40)
		PRINT
		Cellwidth(int 15)
		Header
	];
	#delimit cr
	
	if "`dir'" == "" local dir = "~/Documents/Github/stock1m/history"
	local path = "`dir'/`ticker'"
	
	if "`header'" != "" {
		#delimit ;
		dis "{txt}"
			"{ralign `cellwidth':Ticker }{c |}"
			"{ralign `cellwidth':Variable}"
			"{ralign `cellwidth':Max Yield}";
		#delimit cr
	}
	
	quietly insheet using "`path'",clear
	
	format open-close %6.2f
	format volume %12.0fc
	format dividend %6.4f

	quietly gen v1=date(date,"YMD")
	format v1 %td

	quietly drop date
	rename v1 date

	order date *
	if date[1] > date[2] gsort + date
	else gsort - date

	quietly drop if volume == 0

	local list "open high low close"
	quietly foreach var of local list {
		replace `var'=`var'/split
	}

	quietly gen diff = close[_n] - close[_n+1]
	format diff %4.2f

	quietly gen ratio = 100 * (close[_n] - close[_n+1]) / close[_n+1]
	quietly gen range = 100 * (high[_n] - low[_n]) / close[_n+1] 
	format ratio range %6.2f
	
	quietly gen day = .
	quietly gen rmp = .
	quietly gen rup = .
	quietly gen rlp = .

	local list = "50 75 90"
	quietly foreach i of local list {
		gen ru`i'p = .
		gen rl`i'p = .
	}
	
	local max = `filter'
	local maxvar = "."
	quietly forvalues n = 1/`span' {
		
		local var = "r" + string(`n', "%03.0f") + "d"
		if `n' > _N {
			gen `var' = .
			continue
		}
		
		gen `var' = 100 * (close[_n] - close[_n+`n']) / close[_n+`n']
		irange `var' if _n <= `span', level(99.9)
		
		if `max' < r(max) {
			local max = r(max)
			local maxvar = "`var'"
			
			noisily if "`print'" != "" {		
				#delimit ;
				dis "{txt}{hline `cellwidth'}{c +}{hline `=`cellwidth'*2'}";
				dis "{res}"
					"{ralign `cellwidth':`ticker' }{txt:{c |}}"
					"{ralign `cellwidth':`var'}"
					"{ralign `cellwidth':" %9.5f r(max) "%}";
				#delimit cr
			}
		}
		
		replace day = `n' in `n'
		replace rmp = r(mean) in `n'
		replace rup = r(ub) in `n'
		replace rlp = r(lb) in `n'
		
		foreach i of local list {
			irange `var' if _n <= `span', level(`i')
			replace ru`i'p = r(ub) in `n'
			replace rl`i'p = r(lb) in `n'
		}
	}

	format r*p %6.2f
	
	local step = 10
	local num = 100
	while `num' > 5 {
		local num = max(1, round(`span' / `step'))
		local step = `step' + 10
	}
	
	if "`probplot'" != "" {
		#delimit ;
		line rup rmp rlp rl??p day, xsize(8) ysize(4.3) 
		lcolor(green midblue red orange pink purple)
		legend(ring(0) position(12) rows(1) region(style(none)) symx(*0.2) size(small))
		xlabel(0(`step')`span', grid glw(vthin))
		xmtick(##10, grid glw(vthin))
		ymtick(##5, grid glw(vthin))
		xlabel(, grid glw(medium) labs(small)) ylabel(, glw(medium) labs(small))
		subtitle("`ticker'", ring(0) place(11))
		ytitle("Yields(%)") xtitle("Invest Periodic Span(days)");
		#delimit cr
		if "`export'" != "" {
			graph export "graph/`ticker'-P.pdf", as(pdf) replace
		}
	}
	
	local step = max(1, round(`span' / 30))
	if `=`span'/4' >= 30 {
		local varlist = "`varlist' r" + string(round(`span'/4), "%03.0f") + "d"
	}
	if `=`span'/2' >= 30 {
		local varlist = "`varlist' r" + string(round(`span'/2), "%03.0f") + "d" 
	}
	if `span' > 30 {
		local varlist = "`varlist' r" + string(`span', "%03.0f") + "d"
	}
	
	local count = wordcount("`varlist'")
	if `count' == 0 {
		if `span' > 15 {
			local varlist = "r" + string(15, "%03.0f") + "d `varlist'"
		}
		if `span' > 10 {
			local varlist = "r" + string(10, "%03.0f") + "d `varlist'"
		}
		else if `span' > 5 {
			local varlist = "r" + string(5, "%03.0f") + "d `varlist'"
		}
		if `span' > 1 {
			local varlist = "r" + string(`span', "%03.0f") + "d `varlist'"
		}
	}
	else if `count' == 1 {
		local varlist = "r" + string(30, "%03.0f") + "d `varlist'"
		local varlist = "r" + string(20, "%03.0f") + "d `varlist'"
		local varlist = "r" + string(10, "%03.0f") + "d `varlist'"
	}
	else if `count' == 2 {
		local varlist = "r" + string(20, "%03.0f") + "d `varlist'"
		local varlist = "r" + string(10, "%03.0f") + "d `varlist'"
	}
	else {
		if `=`span'/4 - 30' > 10 {
			local varlist = "r" + string(30, "%03.0f") + "d `varlist'"
		}
		else {
			local varlist = "r" + string(20, "%03.0f") + "d `varlist'"
		}
	}
	
	if "`rateplot'" != "" {
		#delimit ;
		line r001d `varlist' date if date >= date[1] - `span', xsize(8) ysize(4.3)
		lc(midblue orange green pink purple)
		legend(ring(0) position(12) rows(1) region(style(none)) symx(*0.2) size(small))
		ymtick(##5, grid glw(vthin))
		xlabel(`=date[1] - `span''(`step')`=date[1]', grid glw(vthin) angle(35) labs(small))
		ylabel(, glw(medium) labs(small))
		subtitle("`ticker'", ring(0) place(11))
		xtitle("") ytitle("Yields(%)");
		#delimit cr
		
		if "`export'" != "" {
			graph export "graph/`ticker'-R.pdf", as(pdf) replace
		}
	}
	
	return scalar max = `max'
	return local var = "`maxvar'"
	return local ticker = "`ticker'"
	
end
