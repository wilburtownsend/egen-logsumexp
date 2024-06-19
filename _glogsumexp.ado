program define _glogsumexp
	version 18
	syntax newvarname =/exp [if] [in] , [by(varlist)]
	tempvar touse max_x unlogged_sum
	quietly {
		gen byte `touse'=1 `if' `in'
		sort `touse' `by'
		by `touse' `by': egen `typlist' `max_x' = max(`exp') if (`touse'==1)
		by `touse' `by': gen `typlist' `unlogged_sum' = sum(exp(`exp' - `max_x')) if (`touse'==1)
		by `touse' `by': gen `typlist' `varlist' = log(`unlogged_sum') + `max_x' if `touse'==1
		by `touse' `by': replace `varlist' = `varlist'[_N] if `touse'==1
	}
end

