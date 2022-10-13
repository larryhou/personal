capture program drop xhistogram 
program define xhistogram, rclass
	syntax varlist(numeric) [, RSpan(real 3) LSpan(real 3)]
	foreach var of local varlist {
		summarize `var'
		local mean=r(mean)
		local sd=r(sd)
		#delimit ;
		histogram `var' if `var' < `mean'+`rspan'*`sd' & `var' >= `mean'-`lspan'*`sd',
		freq normal normopts(lc(orange*1.2) lw(*.5)) lw(none) gap(5) fc(navy*.6)
		xtick(`mean', tlc(ebblue) tl(*.5)) 
		text(0 `mean' "`=round(`mean')'", c(ebblue) size(*.4) place(6) m(t+1))
		xlabel(,labs(*.5) tlc(ebblue) labc(ebblue))
		ylabel(,labs(*.5) tlc(ebblue) glc(ebblue*1.2) glw(*.2) glp(-) labc(ebblue))
		xtitle(,c(ebblue) margin(t+.9) size(*.75))
		ytitle(,c(ebblue) margin(r+.5))
		graphr(c("34 34 34") la(outside))
		 plotr(c("34 34 34"))
		yscale(lc(ebblue) lw(*2))
		xscale(lc(ebblue))
		xsize(16) ysize(9)
		;
		#delimit cr
	}
end
