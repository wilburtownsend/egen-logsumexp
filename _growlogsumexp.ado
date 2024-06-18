program define _growlogsumexp
	version 18
	gettoken type 0 : 0
	gettoken h    0 : 0 
	gettoken eqs  0 : 0
	syntax varlist(min=1) [if] [in]
	confirm new variable `h'
	tempvar touse max_x unlogged_sum
	quietly {
		gen byte `touse'=1 `if' `in'
		egen `type' `max_x' = rowmax(`varlist') if (`touse'==1)
		gen `type' `unlogged_sum' = 0
		foreach var of varlist `varlist' {
		    replace `unlogged_sum' = `unlogged_sum' + exp(`var' - `max_x') if (`touse'==1) & !missing(`var')
		}
		gen `type' `h' = log(`unlogged_sum') + `max_x' if `touse'==1
	}
end
