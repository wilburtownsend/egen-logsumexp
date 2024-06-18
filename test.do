set seed 1
clear
set obs 3
forvalues j = 1/10 {
gen x`j' = rexponential(20) if runiform() < 0.8
}
egen logse = rowlogsumexp(x*)
bro
gen i = _n
reshape long x, i(i) j(j)
bys i: egen logse_alt = logsumexp(x)
bys i: generate log_cumsum_exp_x = log(sum(exp(x)))
