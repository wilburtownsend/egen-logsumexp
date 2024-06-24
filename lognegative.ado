

// This program finds the log of a negative real number, in the complex plane.
// usage:
//    lognegative real_part imaginary_part = z if _n != 3
cap program drop lognegative
program define lognegative
	syntax newvarlist(min=2 max=2) =/exp [if]
	local real_part      = word("`varlist'", 1)
	local imaginary_part = word("`varlist'", 2)
	generate `real_part'      = log(abs(`exp')) `if'
	generate `imaginary_part' = cond(`exp' == 0, ., cond(`exp' > 0, 0, _pi)) `if'
end


// usage:
//    complex_log real_log_z imaginary_log_z if _n != 6, real_part(real_z) imaginary_part(imaginary_z)
cap program drop complex_log
program define complex_log
	syntax newvarlist(min=2 max=2) [if], real_part(varname numeric) imaginary_part(varname numeric)
	local real_log_z      = word("`varlist'", 1)
	local imaginary_log_z = word("`varlist'", 2)
	generate `real_log_z'      = log(sqrt(`real_part'^2 + `imaginary_part'^2)) `if'
	generate `imaginary_log_z' = atan2(`imaginary_part', `real_part') `if'
	replace `imaginary_log_z' = . if missing(`real_log_z')
end



// This program finds the real part of the exponent of a complex number.
// usage:
//    real_exponential z if _n != 6, real_part(real_part) imaginary_part(imaginary_part)
cap program drop real_exponential
program define real_exponential
	syntax newvarname [if], real_part(varname numeric) imaginary_part(varname numeric)
	generate `varlist' = exp(`real_part')*cos(`imaginary_part') `if'
end



// This program finds the exponent of a complex number.
// usage:
//    complex_exponential real_exp_z imaginary_exp_z if _n != 6, real_part(real_z) imaginary_part(imaginary_z)
cap program drop complex_exponential
program define complex_exponential
	syntax newvarlist(min=2 max=2) [if], real_part(varname numeric) imaginary_part(varname numeric)
	local real_exp_z      = word("`varlist'", 1)
	local imaginary_exp_z = word("`varlist'", 2)
	generate `real_exp_z'      = exp(`real_part')*cos(`imaginary_part') `if'
	generate `imaginary_exp_z' = exp(`real_part')*sin(`imaginary_part') `if'
end


// log sum exp (x)
// max(real(x)) + log sum exp (x) - max(real(x))
// max(real(x)) + log sum exp (x) - log(exp(max(real(x))))
// max(real(x)) + log (sum exp (x) / exp(max(real(x))))
// max(real(x)) + log (sum exp (x - max(real(x))))
cap program drop logsumexp_complex
program define logsumexp_complex
	version 18
	syntax newvarlist(min=2 max=2)  [if] [in] , real_part(varname numeric) imaginary_part(varname numeric) [by(varlist)]
	local real_logsumexp      = word("`varlist'", 1)
	local imaginary_logsumexp = word("`varlist'", 2)
	tempvar order touse max_x x_minus_max_x_real real_summand imaginary_summand real_sum imaginary_sum
	quietly {
		generate `order' = _n
		gen byte `touse'=1 `if' `in'
		sort `touse' `by'
		by `touse' `by': egen `max_x' = max(`real_part') if (`touse'==1)
		generate `x_minus_max_x_real' = `real_part' - `max_x' if (`touse'==1)
		complex_exponential `real_summand' `imaginary_summand' if (`touse'==1), ///
						real_part(`x_minus_max_x_real') imaginary_part(`imaginary_part')
		by `touse' `by': gen `real_sum'      = sum(`real_summand')      if (`touse'==1)
		by `touse' `by': gen `imaginary_sum' = sum(`imaginary_summand') if (`touse'==1)
		complex_log `real_logsumexp' `imaginary_logsumexp', ///
			          real_part(`real_sum') imaginary_part(`imaginary_sum')
		by `touse' `by': replace `real_logsumexp' = `real_logsumexp' + `max_x'     if `touse'==1
		by `touse' `by': replace `real_logsumexp'      = `real_logsumexp'[_N]      if `touse'==1
		by `touse' `by': replace `imaginary_logsumexp' = `imaginary_logsumexp'[_N] if `touse'==1
		sort `order'
	}
end
//
//
// clear 
// set obs 10
// generate z = rnormal()
// generate zero = 0
// complex_log real_part imaginary_part if _n != 3, real_part(z) imaginary_part(zero)
// complex_exponential z_again should_be_zero if _n != 6, real_part(real_part) imaginary_part(imaginary_part)


// clear 
// set obs 3
// generate z_real      = rnormal()
// generate z_imaginary = rnormal()
// logsumexp_complex logsumexp_real logsumexp_imaginary, real_part(z_real) imaginary_part(z_imaginary)
// bro
