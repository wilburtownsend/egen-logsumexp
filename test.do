set seed 1
clear all
set obs 3
forvalues j = 1/10 {
gen x`j' = rexponential(20) if runiform() < 0.8 & `j' < 10
}
egen logse = rowlogsumexp(x*)
bro
gen i = _n
reshape long x, i(i) j(j)
bys i: egen logse_alt = logsumexp(x)
bys i: generate log_cumsum_exp_x = log(sum(exp(x)))

bro



set seed 1
clear all
set obs 10
gen x = rexponential(20) if _n < 10
egen logse_alt = logsumexp(x)
generate log_cumsum_exp_x = log(sum(exp(x)))

bro
