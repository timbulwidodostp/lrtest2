*! SPH/AT version 1.0.0  15/04/99   STB-49 sg111
* after lrtest version 3.0.2  03/01/92

program define lrtest2
	version 3.0
	local options "Saving(string) Using(string) Model(string) Df(real -9)"
	parse "`*'"
	if "`model'"=="" {
		local nmod "$S_E_cmd"
		if "`nmod'"=="" { error 301 }
		if "`nmod'"=="cox" { local b 1 }
		else if "`nmod'"=="logit" | "`nmod'"=="probit" { local b 1 }
		else if "`nmod'"=="tobit" | "`nmod'"=="cnreg" { local b 1 } 
		else if "`nmod'"=="ologit" | "`nmod'"=="oprobit" { local b 1 } 
		else if "`nmod'"=="mlogit" | "`nmod'"=="clogit" { local b 1 } 
		if "`b'"!="" { 
			quietly `nmod'
			local nobs = _result(1)
			local nll  = _result(2)
			local ndf  = _result(3)
		}
		else { 
			local nobs "$S_E_nobs"
			local nll  "$S_E_ll"
			local ndf  "$S_E_mdf"
			capture confirm integer number `nobs'
			if _rc { error 301 } 
			capture confirm number `nll'
			if _rc { error 301 } 
			capture confirm integer number `ndf'
			if _rc { error 301 } 
		}
	}
	else {
		if (length("`model'")>4) { 
			di in red "model() name too long"
			exit 198
		}
		local name LRTS`model'
		local touse $`name'
		if "`touse'"=="" { 
			di in red "model `model' not found"
			exit 302
		}
		parse "`touse'", parse(" ")
		local nmod `1'
		local nobs `2'
		local nll  `3'
		local ndf  `4'
	}
		
	if "`saving'" != "" {
		if (length("`saving'")>4) { 
			di in red "saving() name too long"
			exit 198
		}
		mac def LRTS`saving' "`nmod' `nobs' `nll' `ndf'"
		if ("`using'"=="") { exit }
	}

	if "`using'"!= "" {
		if (length("`using'")>4) { 
			di in red "using() name too long"
			exit 198
		}
		local user `using'
	}
	else 	local user 0 
	local name LRTS`user'
	local touse $`name'
	if "`touse'"=="" {
		di in red "model `user' not found"
		exit 302
	}
	parse "`touse'", parse(" ")
	local bmod `1'
	local bobs `2'
	local bll  `3'
	local bdf  `4'
	if "`bmod'"!="`nmod'" { 
		di in red "cannot compare `bmod' and `nmod' estimates"
		exit 402
	}
	if `bobs' != `nobs' { 
		di in blu "Warning:  observations differ:  `bobs' vs. `nobs'"
	}
	if `df' == -9 { 
		local df = `bdf' - `ndf'
                local df = abs(`df')
	}
	mac def S_3 `df'
	mac def S_6 = abs(-2*(`nll'-`bll'))
	mac def S_7 = chiprob(`df',$S_6)
	local name = upper(substr("$S_E_cmd",1,1))+substr("$S_E_cmd",2,.)
	#delimit ; 
	di in gr "`name':  likelihood-ratio test" _col(55)
		"chi2(" in ye `df' in gr ")     = "
		in ye %10.2f $S_6 _n _col(55) in gr "Prob > chi2 = " 
		in ye %10.4f $S_7 ;
	#delimit cr
end

