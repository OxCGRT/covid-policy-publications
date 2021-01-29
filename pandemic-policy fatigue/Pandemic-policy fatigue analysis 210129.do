**************************************
** Pandemic policy fatigue analysis **
**************************************

global path ""

*************************************************************
** Fig. 1 | Change in behaviour estimates from survey data **
*************************************************************
use "$path\Data\Yougov_pseudo_panel_fem.dta", clear

global ind indexc1 indexc2 indexc3 indexc4 indexc5 indexc6 indexc7 indexc8
global demographics fem age
global avoidances ga_a sh_a
global t tfreq17 
global wtd c.hemisphere##c.mean_temp_WB hits_covid increase_deaths_sm  
global mask wm_a 


** Physical distancing - panel a
foreach t of global t{
foreach v of global avoidances{

** Multilevel model - no fatigue
xtmixed `v'  $ind if has_latest_round == 1 & `t'_m_o <=7 & `t'>= 0 & Australia ==0 ||country_enc: ||id_pseudo:, mle variance
estimates store `v'`t'_tlnulllmix
predict `v'_ind, fitted
gen res_`v'_ind = `v' - `v'_ind

** Multilevel model - no control (Fig. 1)
xtmixed `v'  $ind $demographics i.`t'_m if has_latest_round == 1 & `t'_m_o <=7 & `t'>= 0 & Australia ==0 ||country_enc: ||id_pseudo:, mle variance
estimates store `v'`t'_tlnonemlmix

** Multilevel model - weather, trends and deaths (Supplementary Fig. 1a)
xtmixed `v'  $ind $demographics $wtd i.`t'_m if has_latest_round == 1 & `t'_m_o <=7 & `t'>= 0 & Australia ==0 ||country_enc: ||id_pseudo:, mle variance
estimates store `v'`t'_tlwtdmlmix

** Multilevel model residuals - no control (Supplementary Fig. 1b)
xtmixed res_`v'_ind $demographics i.`t'_m if has_latest_round == 1 & `t'_m_o <=7 & `t'>= 0 & Australia ==0 ||country_enc: ||id_pseudo:, mle variance
estimates store `v'`t'_tlnonemlmixres

** Multilevel model residuals - weather, trends and deaths (Supplementary Fig. 1c)
xtmixed res_`v'_ind $demographics $wtd i.`t'_m if has_latest_round == 1 & `t'_m_o <=7 & `t'>= 0 & Australia ==0 ||country_enc:  ||id_pseudo:, mle variance
estimates store `v'`t'_tlwtdmlmixres

drop res_`v'_ind `v'_ind
}
}
*
** Masks - panel b
foreach t of global t{
foreach v of global mask{

** Multilevel model - no fatigue
xtmixed `v'  $ind indexh6 if has_latest_round == 1 & `t'_m_o <=7 & `t'>= 0 & Australia ==0 ||country_enc: ||id_pseudo:, mle variance
estimates store `v'`t'_tlnullmlmix
predict `v'_ind, fitted
gen res_`v'_ind = `v' - `v'_ind


** Multilevel model - no control (Fig. 1)
xtmixed `v'  $ind indexh6 $demographics i.`t'_m if has_latest_round == 1 & `t'_m_o <=7 & `t'>= 0 & Australia ==0 ||country_enc: ||id_pseudo:, mle variance
estimates store `v'`t'_tlnonemlmix

** Multilevel model - weather, trends and deaths (Supplementary Fig. 1a)
xtmixed `v'  $ind indexh6 $demographics $wtd i.`t'_m if has_latest_round == 1 & `t'_m_o <=7 & `t'>= 0 & Australia ==0 ||country_enc: ||id_pseudo:, mle variance
estimates store `v'`t'_tlwtdmlmix

** Multilevel model residuals - no control (Supplementary Fig. 1b)
xtmixed res_`v'_ind $demographics i.`t'_m if has_latest_round == 1 & `t'_m_o <=7 & `t'>= 0 & Australia ==0 ||country_enc: ||id_pseudo:, mle variance
estimates store `v'`t'_tlnonemlmixres

** Multilevel model residuals - weather, trends and deaths (Supplementary Fig. 1c)
xtmixed res_`v'_ind $demographics $wtd i.`t'_m if has_latest_round == 1 & `t'_m_o <=7 & `t'>= 0 & Australia ==0 ||country_enc: ||id_pseudo:, mle variance
estimates store `v'`t'_tlwtdmlmixres

drop res_`v'_ind `v'_ind
}
}
* Coefplots - panel a
global controls nonemlmix wtdmlmix nonemlmixres wtdmlmixres
foreach c of global controls{
foreach t of global t{
coefplot (ga_a`t'_tl`c', label(Avoidance of gatherings) mcolor (blue) msize (small) ciopts(color(blue))) (sh_a`t'_tl`c', label(Avoidance of going out) mcolor (gray) msize (small) ciopts(color(gray))), ///
keep(*`t'_m*) yline(0, lcolor(gray) lpattern (dash)) yscale(r(-1.0,0.1)) ylabel (-0.5 "-.5" 0 "0" 0.5 ".5" 1.0 "1.0",labsize(vsmall) nogrid) ///
xtitle ("Period since first required measure (days)", size(small) margin (medsmall)) title ("{bf:a}", size(medium) color(black) position(11)) ///
t2title ("Physical distancing", size(medium) color(black) position(13)) xlabel (,labsize(vsmall)) ///
legend (label (5) size(small) rows(2) pos (7) region(style(none))) graphregion(color(white)) bgcolor(white) vertical
graph save "Graph" "pd`t'_`c'.gph", replace
graph export "pd`t'_`c'.png", as(png) name("Graph") replace
}
}
*
* Coefplots - panel b
foreach c of global controls{
foreach t of global t{
coefplot (wm_a`t'_tl`c', mcolor (blue) msize (small) ciopts(color(blue))), ///
keep(*`t'_m*) yline(0, lcolor(gray) lpattern (dash)) yscale(r(-1.0,0.1)) ylabel (-0.5 "-.5" 0 "0" 0.5 ".5" 1.0 "1.0",labsize(vsmall) nogrid) xtitle ("Period since first required measure (days)", size(small) margin (medsmall)) ///
xlabel (,labsize(vsmall)) title ("{bf:b}", size(medium) color(black)  position(11)) graphregion(color(white)) t2title ("Mask wearing", size(medium) color(black) position(13)) graphregion(color(white)) bgcolor(white) vertical
graph save "Graph" "mw`t'_`c'.gph", replace
graph export "mw`t'_`c'.png", as(png) name("Graph") replace
}
}
*
* Fig. 1
foreach c of global controls{
foreach t of global t{ 
grc1leg pd`t'_`c'.gph mw`t'_`c'.gph, graphregion(color(white)) l1("Change in behaviour" "controlling for policy strength", size(small)) ring(1) pos(7) 
graph save "Graph" "F1`t'_`c'.gph", replace
graph export "F1`t'_`c'.png", as(png) name("Graph") replace 
}
}
*

* Supplementary Fig. 1 with a first order autoregressive term
bysort country_enc (tfreq17_m): gen tfreq17i = _n
bysort country_enc (tfreq17_m): gen wm_a_l1 = wm_a[_n-1]
bysort country_enc (tfreq17_m): gen g_sh_l1 = g_sh[_n-1]
bysort country_enc (tfreq17_m): gen ga_a_l1 = ga_a[_n-1]
bysort country_enc (tfreq17_m): gen sh_a_l1 = sh_a[_n-1]


** Physical distancing - panel a
foreach t of global t{
foreach v of global avoidances{

** Multilevel model - no control (Supplementary Fig. 1d)
xtmixed `v' `v'_l1 $ind $demographics i.`t'_m if has_latest_round == 1 & `t'_m_o <=7 & `t'>= 0 & Australia ==0 ||country_enc: ||id_pseudo:, mle variance 
estimates store `v'`t'_tlnonemlmix

** Multilevel model - weather, trends and deaths (Supplementary Fig. 1e)
xtmixed `v' `v'_l1 $ind $demographics $wtd i.`t'_m if has_latest_round == 1 & `t'_m_o <=7 & `t'>= 0 & Australia ==0 ||country_enc: ||id_pseudo:, mle variance 
estimates store `v'`t'_tlwtdmlmix

}
}
*
** Masks - panel b
foreach t of global t{
foreach v of global mask{

** Multilevel model - no control (Supplementary Fig. 1d)
xtmixed `v' `v'_l1  $ind indexh6 $demographics i.`t'_m if has_latest_round == 1 & `t'_m_o <=7 & `t'>= 0 & Australia ==0 ||country_enc: ||id_pseudo:, mle variance 
estimates store `v'`t'_tlnonemlmix

** Multilevel model - weather, trends and deaths (Supplementary Fig. 1e)
xtmixed `v' `v'_l1  $ind indexh6 $demographics $wtd i.`t'_m if has_latest_round == 1 & `t'_m_o <=7 & `t'>= 0 & Australia ==0 ||country_enc: ||id_pseudo:, mle variance 
estimates store `v'`t'_tlwtdmlmix

}
}
* Coefplots - panel a
global controls nonemlmix wtdmlmix  
foreach c of global controls{
foreach t of global t{
coefplot (ga_a`t'_tl`c', label(Avoidance of gatherings) mcolor (blue) msize (small) ciopts(color(blue))) (sh_a`t'_tl`c', label(Avoidance of going out) mcolor (gray) msize (small) ciopts(color(gray))), ///
keep(*`t'_m*) yline(0, lcolor(gray) lpattern (dash)) yscale(r(-1.0,0.1)) ylabel (-0.5 "-.5" 0 "0" 0.5 ".5" 1.0 "1.0",labsize(vsmall) nogrid) ///
xtitle ("Period since first required measure (days)", size(small) margin (medsmall)) title ("{bf:a}", size(medium) color(black) position(11)) ///
t2title ("Physical distancing", size(medium) color(black) position(13)) xlabel (,labsize(vsmall)) ///
legend (label (5) size(small) rows(2) pos (7) region(style(none))) graphregion(color(white)) bgcolor(white) vertical
graph save "Graph" "pd`t'_`c'_AR.gph", replace
graph export "pd`t'_`c'.png", as(png) name("Graph") replace
}
}
*
* Coefplots - panel b
foreach c of global controls{
foreach t of global t{
coefplot (wm_a`t'_tl`c', mcolor (blue) msize (small) ciopts(color(blue))), ///
keep(*`t'_m*) yline(0, lcolor(gray) lpattern (dash)) yscale(r(-1.0,0.1)) ylabel (-0.5 "-.5" 0 "0" 0.5 ".5" 1.0 "1.0",labsize(vsmall) nogrid) xtitle ("Period since first required measure (days)", size(small) margin (medsmall)) ///
xlabel (,labsize(vsmall)) title ("{bf:b}", size(medium) color(black)  position(11)) graphregion(color(white)) t2title ("Mask wearing", size(medium) color(black) position(13)) graphregion(color(white)) bgcolor(white) vertical
graph save "Graph" "mw`t'_`c'_AR.gph", replace
graph export "mw`t'_`c'.png", as(png) name("Graph") replace
}
}
*
* Supplementary Fig. 1d and 1e
foreach c of global controls{
foreach t of global t{ 
grc1leg pd`t'_`c'_AR.gph mw`t'_`c'_AR.gph, graphregion(color(white)) l1("Change in behaviour" "controlling for policy strength", size(small)) ring(1) pos(7) 
graph save "Graph" "F1`t'_`c'_AR.gph", replace
graph export "F1`t'_`c'_AR.png", as(png) name("Graph") replace 
}
}
*

* Supplementary Fig. 1 with pseudo-panel aggregated at the country level
use "$path\Yougov_pseudo_panel_main.dta", replace

** Physical distancing - panel a
foreach t of global t{
foreach v of global avoidances{

** Multilevel model - weather, trends and deaths (Supplementary Fig. 1f)
xtmixed `v'  $ind  $wtd i.`t'_m if has_latest_round == 1 & `t'_m_o <=7 & `t'>= 0 & Australia ==0 ||country_enc: , mle variance
estimates store `v'`t'_tlwtdmlmix
}
}
*
** Masks - panel b
foreach t of global t{
foreach v of global mask{

** Multilevel model - weather, trends and deaths (Supplementary Fig. 1f)
xtmixed `v'  $ind indexh6  $wtd i.`t'_m if has_latest_round == 1 & `t'_m_o <=7 & `t'>= 0 & Australia ==0 ||country_enc: , mle variance
estimates store `v'`t'_tlwtdmlmix

}
}
* Coefplots - panel a
global controls wtdmlmix 
foreach c of global controls{
foreach t of global t{
coefplot (ga_a`t'_tl`c', label(Avoidance of gatherings) mcolor (blue) msize (small) ciopts(color(blue))) (sh_a`t'_tl`c', label(Avoidance of going out) mcolor (gray) msize (small) ciopts(color(gray))), ///
keep(*`t'_m*) yline(0, lcolor(gray) lpattern (dash)) yscale(r(-1.0,0.1)) ylabel (-0.5 "-.5" 0 "0" 0.5 ".5" 1.0 "1.0",labsize(vsmall) nogrid) ///
xtitle ("Period since first required measure (days)", size(small) margin (medsmall)) title ("{bf:a}", size(medium) color(black) position(11)) ///
t2title ("Physical distancing", size(medium) color(black) position(13)) xlabel (,labsize(vsmall)) ///
legend (label (5) size(small) rows(2) pos (7) region(style(none))) graphregion(color(white)) bgcolor(white) vertical
graph save "Graph" "pd`t'_`c'.gph", replace
graph export "pd`t'_`c'.png", as(png) name("Graph") replace
}
}
*
* Coefplots - panel b
foreach c of global controls{
foreach t of global t{
coefplot (wm_a`t'_tl`c', mcolor (blue) msize (small) ciopts(color(blue))), ///
keep(*`t'_m*) yline(0, lcolor(gray) lpattern (dash)) yscale(r(-1.0,0.1)) ylabel (-0.5 "-.5" 0 "0" 0.5 ".5" 1.0 "1.0",labsize(vsmall) nogrid) xtitle ("Period since first required measure (days)", size(small) margin (medsmall)) ///
xlabel (,labsize(vsmall)) title ("{bf:b}", size(medium) color(black)  position(11)) graphregion(color(white)) t2title ("Mask wearing", size(medium) color(black) position(13)) graphregion(color(white)) bgcolor(white) vertical
graph save "Graph" "mw`t'_`c'.gph", replace
graph export "mw`t'_`c'.png", as(png) name("Graph") replace
}
}
*
* Supplementary Fig. 1f
foreach c of global controls{
foreach t of global t{ 
grc1leg pd`t'_`c'.gph mw`t'_`c'.gph, graphregion(color(white)) l1("Change in behaviour" "controlling for policy strength", size(small)) ring(1) pos(7) 
graph save "Graph" "F1f`t'_`c'.gph", replace
graph export "F1f`t'_`c'.png", as(png) name("Graph") replace 
}
}
*

********************************************************************************
** Fig. 2 | Pandemic-policy fatigue estimates from mobile-phone mobility data **
********************************************************************************
use "$path\Data\mobility\googlemobility_modified.dta", clear

label variable res "Time spent in residential locations"
label variable ret "Retail and recreation visits"
label variable tfreq17 "Time since first measure required"

* Time spent in residential locations - panel a
global dvs res
foreach l of numlist 8{
foreach t of global t{
foreach v of global dvs{

** Multilevel model - no fatigue
xtmixed `v' $ind  if `t'>=0 & `t'_m_o<=`l'  ||countrycode_enc:, mle variance 
estimates store `v'`t'_tlnullmlmix`l'
predict `v'_ind, fitted
gen res_`v'_ind = `v' - `v'_ind

** Multilevel model - no control (Fig. 2)
xtmixed `v' $ind i.`t'_m if `t'>=0 & `t'_m_o<=`l'  ||countrycode_enc:, mle variance 
estimates store `v'`t'_tlnonemlmix`l'

coefplot (`v'`t'_tlnonemlmix`l', mcolor (blue) msize (small) ciopts(color(blue))), keep(*`t'*) yline(0, lcolor(gray) lpattern (dash)) yscale(r(-1.0,0.1)) ylabel (-5 "-5" 0 "0" 5 "5",labsize(vsmall) nogrid) ///
xtitle ("Period since first required measure (days)", size(small) margin (medsmall)) xlabel (,labsize(vsmall)) ytitle ("Change (in percentage points)""in behaviour controlling""for policy strength", size(small)) ///
title ("{bf:a}", size(medium) color(black) position(11)) t2title ("`:variable label `v''", size(medium) color(black) position(13)) graphregion(color(white)) vertical
graph save "Graph" "`v'_`t'_nonemlmix`l'.gph", replace
graph export "`v'_`t'_nonemlmix`l'.png", as(png) name("Graph") replace


** Multilevel model - weather, trends and deaths (Supplementary Fig. 2a)
xtmixed `v' $ind $wtd i.`t'_m if `t'>=0 & `t'_m_o<=`l' ||countrycode_enc: , mle variance 
estimates store `v'`t'_tlwtdmlmix`l' 

coefplot (`v'`t'_tlwtdmlmix`l', mcolor (blue) msize (small) ciopts(color(blue))), keep(*`t'*) yline(0, lcolor(gray) lpattern (dash)) yscale(r(-1.0,0.1)) ylabel (-5 "-5" 0 "0" 5 "5",labsize(vsmall) nogrid) ///
xtitle ("Period since first required measure (days)", size(small) margin (medsmall)) xlabel (,labsize(vsmall)) ytitle ("Change (in percentage points)""in behaviour controlling""for policy strength", size(small)) ///
title ("{bf:a}", size(medium) color(black) position(11)) t2title ("`:variable label `v''", size(medium) color(black) position(13)) graphregion(color(white)) vertical
graph save "Graph" "`v'_`t'_wtdmlmix`l'.gph", replace
graph export "`v'_`t'_wtdmlmix`l'.png", as(png) name("Graph") replace

** Multilevel model residuals - no controls (Supplementary Fig. 2b)
xtmixed res_`v'_ind i.`t'_m if `t'>=0 & `t'_m_o<=`l' ||countrycode_enc: , mle variance 
estimates store `v'`t'_tlnonemlmixres`l' 

coefplot (`v'`t'_tlnonemlmixres`l', mcolor (blue) msize (small) ciopts(color(blue))), keep(*`t'*) yline(0, lcolor(gray) lpattern (dash)) yscale(r(-1.0,0.1)) ylabel (-5 "-5" 0 "0" 5 "5",labsize(vsmall) nogrid) ///
xtitle ("Period since first required measure (days)", size(small) margin (medsmall)) xlabel (,labsize(vsmall)) ytitle ("Change (in percentage points)""in behaviour controlling""for policy strength", size(small)) ///
title ("{bf:a}", size(medium) color(black) position(11)) t2title ("`:variable label `v''", size(medium) color(black) position(13)) graphregion(color(white)) vertical
graph save "Graph" "`v'_`t'_nonemlmixres`l'.gph", replace
graph export "`v'_`t'_nonemlmixres`l'.png", as(png) name("Graph") replace

** Multilevel model residuals - weather, trends and deaths (Supplementary Fig. 2c)
xtmixed res_`v'_ind $wtd i.`t'_m if `t'>=0 & `t'_m_o<=`l' ||countrycode_enc: , mle variance 
estimates store `v'`t'_tlwtdmlmixres`l' 

coefplot (`v'`t'_tlwtdmlmixres`l', mcolor (blue) msize (small) ciopts(color(blue))), keep(*`t'*) yline(0, lcolor(gray) lpattern (dash)) yscale(r(-1.0,0.1)) ylabel (-5 "-5" 0 "0" 5 "5",labsize(vsmall) nogrid) ///
xtitle ("Period since first required measure (days)", size(small) margin (medsmall)) xlabel (,labsize(vsmall)) ytitle ("Change (in percentage points)""in behaviour controlling""for policy strength", size(small)) ///
title ("{bf:a}", size(medium) color(black) position(11)) t2title ("`:variable label `v''", size(medium) color(black) position(13)) graphregion(color(white)) vertical
graph save "Graph" "`v'_`t'_wtdmlmixres`l'.gph", replace
graph export "`v'_`t'_wtdmlmixres`l'.png", as(png) name("Graph") replace

drop res_`v'_ind `v'_ind
}
}
}
* Retail and recreation visits - panel b
global dvs ret
foreach l of numlist 8{
foreach t of global t{
foreach v of global dvs{

** Multilevel model - no fatigue
xtmixed `v' $ind if `t'>=0 & `t'_m_o<=`l' ||countrycode_enc:, mle variance 
estimates store `v'`t'_tlnonemlmix`l'
predict `v'_ind, fitted
gen res_`v'_ind = `v' - `v'_ind

** Multilevel model - no control (Fig. 2)
xtmixed `v' $ind i.`t'_m if `t'>=0 & `t'_m_o<=`l' ||countrycode_enc:, mle variance 
estimates store `v'`t'_tlnonemlmix`l'

coefplot (`v'`t'_tlnonemlmix`l', mcolor (blue) msize (small) ciopts(color(blue))), keep(*`t'*) yline(0, lcolor(gray) lpattern (dash)) yscale(r(-1.0,0.1)) ylabel (-5 "-5" 0 "0" 5 "5" 10 "10" 15 "15",labsize(vsmall) nogrid) ///
xtitle ("Period since first required measure (days)", size(small) margin (medsmall)) xlabel (,labsize(vsmall)) ytitle ("Change (in percentage points)""in behaviour controlling""for policy strength", size(small)) ///
title ("{bf:b}", size(medium) color(black) position(11)) t2title ("`:variable label `v''", size(medium) color(black) position(13)) graphregion(color(white)) vertical
graph save "Graph" "`v'_`t'_nonemlmix`l'.gph", replace
graph export "`v'_`t'_nonemlmix`l'.png", as(png) name("Graph") replace


** Multilevel model - weather, trends and deaths (Supplementary Fig. 2a)
xtmixed `v' $ind $wtd i.`t'_m if `t'>=0 & `t'_m_o<=`l' ||countrycode_enc: , mle variance 
estimates store `v'`t'_tlwtdmlmix`l' 

coefplot (`v'`t'_tlwtdmlmix`l', mcolor (blue) msize (small) ciopts(color(blue))), keep(*`t'*) yline(0, lcolor(gray) lpattern (dash)) yscale(r(-1.0,0.1)) ylabel (-5 "-5" 0 "0" 5 "5" 10 "10" 15 "15",labsize(vsmall) nogrid) ///
xtitle ("Period since first required measure (days)", size(small) margin (medsmall)) xlabel (,labsize(vsmall)) ytitle ("Change (in percentage points)""in behaviour controlling""for policy strength", size(small)) ///
title ("{bf:b}", size(medium) color(black) position(11)) t2title ("`:variable label `v''", size(medium) color(black) position(13)) graphregion(color(white)) vertical
graph save "Graph" "`v'_`t'_wtdmlmix`l'.gph", replace
graph export "`v'_`t'_wtdmlmix`l'.png", as(png) name("Graph") replace

** Multilevel model residuals - no controls (Supplementary Fig. 2b)
xtmixed res_`v'_ind i.`t'_m if `t'>=0 & `t'_m_o<=`l' ||countrycode_enc: , mle variance 
estimates store `v'`t'_tlnonemlmixres`l' 

coefplot (`v'`t'_tlnonemlmixres`l', mcolor (blue) msize (small) ciopts(color(blue))), keep(*`t'*) yline(0, lcolor(gray) lpattern (dash)) yscale(r(-1.0,0.1)) ylabel (-5 "-5" 0 "0" 5 "5" 10 "10" 15 "15",labsize(vsmall) nogrid) ///
xtitle ("Period since first required measure (days)", size(small) margin (medsmall)) xlabel (,labsize(vsmall)) ytitle ("Change (in percentage points)""in behaviour controlling""for policy strength", size(small)) ///
title ("{bf:b}", size(medium) color(black) position(11)) t2title ("`:variable label `v''", size(medium) color(black) position(13)) graphregion(color(white)) vertical
graph save "Graph" "`v'_`t'_nonemlmixres`l'.gph", replace
graph export "`v'_`t'_nonemlmixres`l'.png", as(png) name("Graph") replace

** Multilevel model residuals - weather, trends and deaths (Supplementary Fig. 2c)
xtmixed res_`v'_ind $wtd i.`t'_m if `t'>=0 & `t'_m_o<=`l' ||countrycode_enc:, mle variance 
estimates store `v'`t'_tlwtdmlmixres`l' 

coefplot (`v'`t'_tlwtdmlmixres`l', mcolor (blue) msize (small) ciopts(color(blue))), keep(*`t'*) yline(0, lcolor(gray) lpattern (dash)) yscale(r(-1.0,0.1)) ylabel (-5 "-5" 0 "0" 5 "5" 10 "10" 15 "15",labsize(vsmall) nogrid) ///
xtitle ("Period since first required measure (days)", size(small) margin (medsmall)) xlabel (,labsize(vsmall)) ytitle ("Change (in percentage points)""in behaviour controlling""for policy strength", size(small)) ///
title ("{bf:b}", size(medium) color(black) position(11)) t2title ("`:variable label `v''", size(medium) color(black) position(13)) graphregion(color(white)) vertical
graph save "Graph" "`v'_`t'_wtdmlmixres`l'.gph", replace
graph export "`v'_`t'_wtdmlmixres`l'.png", as(png) name("Graph") replace


drop res_`v'_ind `v'_ind
}
}
}
*
* Fig. 2
global controls wtdmlmix nonemlmix nonemlmixres wtdmlmixres
foreach c of global controls{
foreach l of numlist 8{
foreach t of global t{

graph combine res_`t'_`c'`l'.gph ret_`t'_`c'`l'.gph, graphregion(color(white)) 
graph save "Graph" "F2`t'_`c'`l'.gph", replace
graph export "F2`t'_`c'`l'.png", as(png) name("Graph") replace 
}
}
}
*
* Supplementary Fig. 2 with a first order autoregressive term
bysort countrycode_enc (date_mdy): gen res_l1 = res[_n-1]
bysort countrycode_enc (date_mdy): gen ret_l1 = ret[_n-1]

* Time spent in residential locations - panel a
global dvs res
foreach l of numlist 8{
foreach t of global t{
foreach v of global dvs{

** Multilevel model - no control (Supplementary Fig. 2d)
xtmixed `v' `v'_l1 $ind i.`t'_m if `t'>=0 & `t'_m_o<=`l'  ||countrycode_enc:, mle variance 
estimates store `v'`t'_tlnonemlmix`l'

coefplot (`v'`t'_tlnonemlmix`l', mcolor (blue) msize (small) ciopts(color(blue))), keep(*`t'*) yline(0, lcolor(gray) lpattern (dash)) yscale(r(-1.0,0.1)) ylabel (-5 "-5" 0 "0" 5 "5",labsize(vsmall) nogrid) ///
xtitle ("Period since first required measure (days)", size(small) margin (medsmall)) xlabel (,labsize(vsmall)) ytitle ("Change (in percentage points)" "in behaviour controlling""for policy strength", size(small)) ///
title ("{bf:a}", size(medium) color(black) position(11)) t2title ("`:variable label `v''", size(medium) color(black) position(13)) graphregion(color(white)) vertical
graph save "Graph" "`v'_`t'_nonemlmix`l'_AR.gph", replace
graph export "`v'_`t'_nonemlmix`l'_AR.png", as(png) name("Graph") replace


** Multilevel model - weather, trends and deaths (Supplementary Fig. 2e)
xtmixed `v' `v'_l1 $ind $wtd i.`t'_m if `t'>=0 & `t'_m_o<=`l' ||countrycode_enc: , mle variance 
estimates store `v'`t'_tlwtdmlmix`l' 

coefplot (`v'`t'_tlwtdmlmix`l', mcolor (blue) msize (small) ciopts(color(blue))), keep(*`t'*) yline(0, lcolor(gray) lpattern (dash)) yscale(r(-1.0,0.1)) ylabel (-5 "-5" 0 "0" 5 "5",labsize(vsmall) nogrid) ///
xtitle ("Period since first required measure (days)", size(small) margin (medsmall)) xlabel (,labsize(vsmall)) ytitle ("Change (in percentage points)" "in behaviour controlling""for policy strength", size(small)) ///
title ("{bf:a}", size(medium) color(black) position(11)) t2title ("`:variable label `v''", size(medium) color(black) position(13)) graphregion(color(white)) vertical
graph save "Graph" "`v'_`t'_wtdmlmix`l'_AR.gph", replace
graph export "`v'_`t'_wtdmlmix`l'_AR.png", as(png) name("Graph") replace

}
}
}
** Retail and recreation visits - panel b
global dvs ret
foreach l of numlist 8{
foreach t of global t{
foreach v of global dvs{

** Multilevel model - no control (Supplementary Fig. 2d)
xtmixed `v' `v'_l1 $ind i.`t'_m if `t'>=0 & `t'_m_o<=`l' ||countrycode_enc:, mle variance 
estimates store `v'`t'_tlnonemlmix`l'

coefplot (`v'`t'_tlnonemlmix`l', mcolor (blue) msize (small) ciopts(color(blue))), keep(*`t'*) yline(0, lcolor(gray) lpattern (dash)) yscale(r(-1.0,0.1)) ylabel (-5 "-5" 0 "0" 5 "5" 10 "10" 15 "15",labsize(vsmall) nogrid) ///
xtitle ("Period since first required measure (days)", size(small) margin (medsmall)) xlabel (,labsize(vsmall)) ytitle ("Change (in percentage points)" "in behaviour controlling""for policy strength", size(small)) ///
title ("{bf:b}", size(medium) color(black) position(11)) t2title ("`:variable label `v''", size(medium) color(black) position(13)) graphregion(color(white)) vertical
graph save "Graph" "`v'_`t'_nonemlmix`l'_AR.gph", replace
graph export "`v'_`t'_nonemlmix`l'_AR.png", as(png) name("Graph") replace


** Multilevel model - weather, trends and deaths (Supplementary Fig. 2e)
xtmixed `v' `v'_l1 $ind $wtd i.`t'_m if `t'>=0 & `t'_m_o<=`l' ||countrycode_enc: , mle variance 
estimates store `v'`t'_tlwtdmlmix`l' 

coefplot (`v'`t'_tlwtdmlmix`l', mcolor (blue) msize (small) ciopts(color(blue))), keep(*`t'*) yline(0, lcolor(gray) lpattern (dash)) yscale(r(-1.0,0.1)) ylabel (-5 "-5" 0 "0" 5 "5" 10 "10" 15 "15",labsize(vsmall) nogrid) ///
xtitle ("Period since first required measure (days)", size(small) margin (medsmall)) xlabel (,labsize(vsmall)) ytitle ("Change (in percentage points)" "in behaviour controlling""for policy strength", size(small)) ///
title ("{bf:b}", size(medium) color(black) position(11)) t2title ("`:variable label `v''", size(medium) color(black) position(13)) graphregion(color(white)) vertical
graph save "Graph" "`v'_`t'_wtdmlmix`l'_AR.gph", replace
graph export "`v'_`t'_wtdmlmix`l'_AR.png", as(png) name("Graph") replace

}
}
}
*
* Supplementary Fig. 2d and 2e
global controls wtdmlmix nonemlmix  
foreach c of global controls{
foreach l of numlist 8{
foreach t of global t{

graph combine res_`t'_`c'`l'_AR.gph ret_`t'_`c'`l'_AR.gph, graphregion(color(white)) 
graph save "Graph" "F2`t'_`c'`l'_AR.gph", replace
graph export "F2`t'_`c'`l'_AR.png", as(png) name("Graph") replace 
}
}
}
*
********************************************************************************************************************************
** Fig. 3 | Pandemic-policy fatigue estimates from mobile-phone mobility data by geographical region and country-income level **
********************************************************************************************************************************
label define tfreq17_m_o 0 "0-30" 1 "30-60" 2 "60-90" 3 "90-120" 4 "120-150" 5 "150-180" 6 "180-210" 7 "210-240" 8 "240-270" 9 "270-300" 10 "300-330", modify
label values tfreq17_m_o tfreq17_m_o

* Geographical Region
global dvs res ret
foreach v of global dvs{
foreach t of global t{
foreach i of numlist 8{

** Multilevel model - no fatigue
xtmixed `v' $ind if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc:, mle variance 
predict `v'_ind, fitted
gen res_`v'_ind = `v' - `v'_ind

** Multilevel model - no control and no interaction
xtmixed `v' $ind i.`t'_m if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc:, mle variance 

** Multilevel model - no control (Fig. 3)
xtmixed `v' $ind  i.`t'_m##ib1.reg if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc:, mle variance 
estimates store `v'_`t'_nonemlmixr1
xtmixed `v' $ind  i.`t'_m##ib2.reg if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc:, mle variance 
estimates store `v'_`t'_nonemlmixr2
xtmixed `v' $ind  i.`t'_m##ib3.reg if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc:, mle variance 
estimates store `v'_`t'_nonemlmixr3
xtmixed `v' $ind  i.`t'_m##ib4.reg if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc:, mle variance 
estimates store `v'_`t'_nonemlmixr4
xtmixed `v' $ind  i.`t'_m##ib5.reg if `t' >= 0 ||countrycode_enc:, mle variance
estimates store `v'_`t'_nonemlmixr5


** Multilevel model - weather, trends and deaths (Supplementary Fig. 3a)
xtmixed `v' $ind  $wtd i.`t'_m##ib1.reg if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc: , mle variance 
estimates store `v'_`t'_wtdmlmixr1
xtmixed `v' $ind  $wtd i.`t'_m##ib2.reg if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc: , mle variance 
estimates store `v'_`t'_wtdmlmixr2
xtmixed `v' $ind  $wtd i.`t'_m##ib3.reg if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc: , mle variance 
estimates store `v'_`t'_wtdmlmixr3
xtmixed `v' $ind  $wtd i.`t'_m##ib4.reg if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc: , mle variance 
estimates store `v'_`t'_wtdmlmixr4
xtmixed `v' $ind  $wtd i.`t'_m##ib5.reg if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc: , mle variance
estimates store `v'_`t'_wtdmlmixr5


** Multilevel model residuals - no controls (Supplementary Fig. 3b)
xtmixed res_`v'_ind i.`t'_m##ib1.reg if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc: , mle variance 
estimates store `v'_`t'_nonemlmixresr1
xtmixed res_`v'_ind i.`t'_m##ib2.reg if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc: , mle variance 
estimates store `v'_`t'_nonemlmixresr2
xtmixed res_`v'_ind i.`t'_m##ib3.reg if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc: , mle variance 
estimates store `v'_`t'_nonemlmixresr3
xtmixed res_`v'_ind i.`t'_m##ib4.reg if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc: , mle variance 
estimates store `v'_`t'_nonemlmixresr4
xtmixed res_`v'_ind i.`t'_m##ib5.reg if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc: , mle variance
estimates store `v'_`t'_nonemlmixresr5

** Multilevel model residuals - weather, trends and deaths (Supplementary Fig. 3c)
xtmixed res_`v'_ind $wtd i.`t'_m##ib1.reg if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc: , mle variance 
estimates store `v'_`t'_wtdmlmixresr1
xtmixed res_`v'_ind $wtd i.`t'_m##ib2.reg if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc: , mle variance 
estimates store `v'_`t'_wtdmlmixresr2
xtmixed res_`v'_ind $wtd i.`t'_m##ib3.reg if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc: , mle variance
estimates store `v'_`t'_wtdmlmixresr3
xtmixed res_`v'_ind $wtd i.`t'_m##ib4.reg if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc: , mle variance 
estimates store `v'_`t'_wtdmlmixresr4
xtmixed res_`v'_ind $wtd i.`t'_m##ib5.reg if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc: , mle variance
estimates store `v'_`t'_wtdmlmixresr5

drop res_`v'_ind `v'_ind
}
}
}
*
* Coefplots - panel a
label variable ret "retail and recreation"
label variable res "residential mobility"

global controls nonemlmix wtdmlmix nonemlmixres wtdmlmixres 
global dvs ret
foreach v of global dvs{
foreach t of global t{
foreach c of global controls{
coefplot (`v'_`t'_`c'r4, label(Sub-Saharan Africa) mcolor (blue) msize (small) ciopts(color(blue))) (`v'_`t'_`c'r2, label(Latin America & Caribbean) mcolor (orange) msize (small) ciopts(color(orange))) ///
(`v'_`t'_`c'r1, label(Europe) mcolor (purple) msize (small) ciopts(color(purple))) (`v'_`t'_`c'r3, label(East Asia) mcolor (gray) msize (small) ciopts(color(gray))), ///
keep(*`t'_m*) drop(*index* *req_c4_g* *req_c4_g* *reg* *tfpm_m#reg* *mean_temp_WB* *hits_covid* *hits_coronavirus* *increase_deaths_sm*) ///
yline(0, lcolor(gray) lpattern (dash)) ytitle ("Change (in percentage points)" "in `:variable label `v''""controlling for policy strength", size(small) margin (small)) ///
title ("{bf:a}", size(mediumsmall) color(black) position(11)) aspectratio(0.47) t2title ("Geographical Region", size(medium) color(black) position(13)) ///
ylabel (-10 "-10" 0 "0" 10 "10" 20 "20" 30 "30",labsize(small) nogrid) xlabel (,labsize(vsmall)) graphregion(color(white) margin(2 1 2 2)) ///
legend (off) vertical
graph save "Graph" "`v'_`t'_`c'reg.gph", replace
graph export "`v'_`t'_`c'reg.png", as(png) name("Graph") replace
}
}
}
*
* Coefplots - panel c
global controls nonemlmix wtdmlmix nonemlmixres wtdmlmixres 
global dvs res
foreach v of global dvs{
foreach t of global t{
foreach c of global controls{
coefplot (`v'_`t'_`c'r4, label(Sub-Saharan Africa) mcolor (blue) msize (small) ciopts(color(blue))) (`v'_`t'_`c'r2, label(Latin America & Caribbean) mcolor (orange) msize (small) ciopts(color(orange))) ///
(`v'_`t'_`c'r1, label(Europe) mcolor (purple) msize (small) ciopts(color(purple))) (`v'_`t'_`c'r3, label(East Asia) mcolor (gray) msize (small) ciopts(color(gray))), ///
keep(*`t'_m*) drop(*index* *req_c4_g* *req_c4_g* *reg* *tfpm_m#reg* *mean_temp_WB* *hits_covid* *hits_coronavirus* *increase_deaths_sm*) ///
title ("{bf:c}", size(mediumsmall) color(black) position(11)) xtitle ("Period since first required measure (days)", size(small) margin (medsmall)) ///
yline(0, lcolor(gray) lpattern (dash)) ytitle ("Change (in percentage points)" "in `:variable label `v''""controlling for policy strength", size(small) margin (medsmall)) ///
ylabel (-10 "-10" -5 "-5" 0 "0" 5 "5",labsize(small) nogrid) xlabel (,labsize(vsmall)) graphregion(color(white) margin(2 1 2 2)) ///
legend(size(small) rows(2) region(style(none))) vertical
graph save "Graph" "`v'_`t'_`c'reg.gph", replace
graph export "`v'_`t'_`c'reg.png", as(png) name("Graph") replace
}
}
}
*

* Income
global dvs res ret
foreach v of global dvs{
foreach t of global t{
foreach i of numlist 8{

** Multilevel model - no fatigue
xtmixed `v' $ind if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc:, mle variance 
predict `v'_ind, fitted
gen res_`v'_ind = `v' - `v'_ind

** Multilevel model - no control and no interaction
xtmixed `v' $ind i.`t'_m if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc:, mle variance 

** Multilevel model - no control (Fig. 3)
xtmixed `v' $ind i.`t'_m##ib1.inc if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc:, mle variance 
estimates store `v'_`t'_nonemlmixi1
xtmixed `v' $ind i.`t'_m##ib2.inc if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc:, mle variance 
estimates store `v'_`t'_nonemlmixi2
xtmixed `v' $ind i.`t'_m##ib3.inc if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc:, mle variance 
estimates store `v'_`t'_nonemlmixi3
xtmixed `v' $ind i.`t'_m##ib4.inc if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc:, mle variance 
estimates store `v'_`t'_nonemlmixi4

** Multilevel model - weather, trends and deaths (Supplementary Fig. 3a)
xtmixed `v' $ind $wtd i.`t'_m##ib1.inc if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc: , mle variance 
estimates store `v'_`t'_wtdmlmixi1
xtmixed `v' $ind $wtd i.`t'_m##ib2.inc if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc: , mle variance 
estimates store `v'_`t'_wtdmlmixi2
xtmixed `v' $ind $wtd i.`t'_m##ib3.inc if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc: , mle variance 
estimates store `v'_`t'_wtdmlmixi3
xtmixed `v' $ind $wtd i.`t'_m##ib4.inc if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc: , mle variance 
estimates store `v'_`t'_wtdmlmixi4

** Multilevel model residuals - no controls (Supplementary Fig. 3b)
xtmixed res_`v'_ind i.`t'_m##ib1.inc if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc: , mle variance 
estimates store `v'_`t'_nonemlmixresi1
xtmixed res_`v'_ind i.`t'_m##ib2.inc if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc: , mle variance 
estimates store `v'_`t'_nonemlmixresi2
xtmixed res_`v'_ind i.`t'_m##ib3.inc if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc: , mle variance 
estimates store `v'_`t'_nonemlmixresi3
xtmixed res_`v'_ind i.`t'_m##ib4.inc if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc: , mle variance 
estimates store `v'_`t'_nonemlmixresi4

** Multilevel model residuals - weather, trends and deaths (Supplementary Fig. 3c)
xtmixed res_`v'_ind $wtd i.`t'_m##ib1.inc if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc: , mle variance 
estimates store `v'_`t'_wtdmlmixresi1
xtmixed res_`v'_ind $wtd i.`t'_m##ib2.inc if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc: , mle variance 
estimates store `v'_`t'_wtdmlmixresi2
xtmixed res_`v'_ind $wtd i.`t'_m##ib3.inc if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc: , mle variance 
estimates store `v'_`t'_wtdmlmixresi3
xtmixed res_`v'_ind $wtd i.`t'_m##ib4.inc if `t' >= 0 & `t'_m_o <= `i' ||countrycode_enc: , mle variance 
estimates store `v'_`t'_wtdmlmixresi4


drop res_`v'_ind `v'_ind
}
}
}
*
* Coefplots - panel b
global controls nonemlmix wtdmlmix nonemlmixres wtdmlmixres 
global dvs ret
foreach v of global dvs{
foreach t of global t{
foreach c of global controls{
coefplot (`v'_`t'_`c'i1, label(High income) mcolor (blue) msize (small) ciopts(color(blue))) (`v'_`t'_`c'i2, label(Upper-middle income) mcolor (orange) msize (small) ciopts(color(orange))) ///
(`v'_`t'_`c'i3, label(Lower-middle income) mcolor (purple) msize (small) ciopts(color(purple))) (`v'_`t'_`c'i4, label(Low income) mcolor (gray) msize (small) ciopts(color(gray))), ///
keep(*`t'_m*) drop(*index* *req_c4_g* *req_c4_g* *inc* *`t'#* *mean_temp_WB* *hits_covid* *hits_coronavirus* *increase_deaths_sm*) ///
title ("{bf:b}", size(mediumsmall) color(black) position(11)) t2title ("Income", size(medium) color(black) position(13)) ///
yline(0, lcolor(gray) lpattern (dash)) aspectratio(0.4) ///
ylabel (-10 "-10" 0 "0" 10 "10" 20 "20" 30 "30",labsize(small) nogrid) xlabel (,labsize(vsmall)) graphregion(color(white) margin(2 5 2 2)) ///
legend (off) vertical
graph save "Graph" "`v'_`t'_`c'inc.gph", replace
graph export "`v'_`t'_`c'inc.png", as(png) name("Graph") replace
}
}
}
*
* Coefplots - panel d
global controls nonemlmix wtdmlmix nonemlmixres wtdmlmixres 
global dvs res 
foreach v of global dvs{
foreach t of global t{
foreach c of global controls{
coefplot (`v'_`t'_`c'i1, label(High income) mcolor (blue) msize (small) ciopts(color(blue))) (`v'_`t'_`c'i2, label(Upper-middle income) mcolor (orange) msize (small) ciopts(color(orange))) ///
(`v'_`t'_`c'i3, label(Lower-middle income) mcolor (purple) msize (small) ciopts(color(purple))) (`v'_`t'_`c'i4, label(Low income) mcolor (gray) msize (small) ciopts(color(gray))), ///
keep(*`t'_m*) drop(*index* *req_c4_g* *req_c4_g* *inc* *`t'#* *mean_temp_WB* *hits_covid* *hits_coronavirus* *increase_deaths_sm*) ///
title ("{bf:d}", size(mediumsmall) color(black) position(11)) xtitle ("Period since first required measure (days)", size(small) margin (medsmall)) ///
yline(0, lcolor(gray) lpattern (dash)) ///
ylabel (-10 "-10" -5 "-5" 0 "0" 5 "5",labsize(small) nogrid) xlabel (,labsize(vsmall)) graphregion(color(white) margin(2 5 2 2)) ///
legend(size(small) rows(2) region(style(none))) vertical
graph save "Graph" "`v'_`t'_`c'inc.gph", replace
graph export "`v'_`t'_`c'inc.png", as(png) name("Graph") replace
}
}
}
*
* Fig. 3
foreach c of global controls{
foreach t of global t{ 
foreach v of global dvs{
graph combine ret_`t'_`c'reg.gph ret_`t'_`c'inc.gph res_`t'_`c'reg.gph  res_`t'_`c'inc.gph, rows(2) graphregion(color(white)) 
graph save "Graph" "F3_coef_`t'_`c'.gph", replace
graph export "F3_coef_`t'_`c'.png", as(png) name("Graph") replace 
}
}
}
*
************************************************************************************************************************
** Fig. 4 | Pandemic-policy fatigue estimates from survey data by gender, age, chronic diseases and employment status **
************************************************************************************************************************

* Binary moderators
global demographics acr
global moderators fem hci hhs1 hhs2
global avoidances g_sh
global t tfreq17

foreach m of global moderators{
use "$path\Data\Yougov_pseudo_panel_`m'.dta", clear
foreach t of global t{
foreach v of global avoidances{
foreach i of numlist 1{
foreach j of numlist 0{

** Multilevel model - no control and no interaction
xtmixed `v' $ind if has_latest_round == 1 & `t'<8 & `t'>= 0 & Australia == `j' ||country_enc: ||id_pseudo:, mle variance
predict `v'_ind, fitted
gen res_`v'_ind = `v' - `v'_ind

** Multilevel model - no control (Fig. 4 and Supplementary Fig. 4d)
xtmixed `v' $ind $demographics i.`t'_m##`m' if has_latest_round >=`i' & `t'<8 & `t' >= 0 & Australia == `j' ||country_enc: ||id_pseudo:, mle variance
estimates store `v'_`t'`m'0nonemlmix
xtmixed `v' $ind $demographics i.`t'_m##ib1.`m' if has_latest_round >=`i' & `t'<8 & `t' >= 0 & Australia == `j' ||country_enc: ||id_pseudo:, mle variance
estimates store `v'_`t'`m'1nonemlmix

** Multilevel model - weather, trends and deaths (Supplementary Fig. 4a and 4e)
xtmixed `v' $ind $demographics $wtd i.`t'_m##`m' if has_latest_round >=`i' & `t'<8 & `t' >= 0 & Australia == `j' ||country_enc: ||id_pseudo:, mle variance
estimates store  `v'_`t'`m'0wtdmlmix
xtmixed `v' $ind $demographics $wtd i.`t'_m##ib1.`m' if has_latest_round >=`i' & `t'<8 & `t' >= 0 & Australia == `j' ||country_enc: ||id_pseudo:, mle variance
estimates store `v'_`t'`m'1wtdmlmix

** Multilevel model residuals - no controls (Supplementary Fig. 4b and 4f)
xtmixed res_`v'_ind $demographics i.`t'_m##`m' if has_latest_round >=`i' & `t'<8 & `t' >= 0 & Australia == `j' ||country_enc: ||id_pseudo:, mle variance
estimates store  `v'_`t'`m'0nonemlmixu
xtmixed res_`v'_ind $demographics i.`t'_m##ib1.`m' if has_latest_round >=`i' & `t'<8 & `t' >= 0 & Australia == `j' ||country_enc: ||id_pseudo:, mle variance
estimates store `v'_`t'`m'1nonemlmixu

** Multilevel model residuals - weather, trends and deaths (Supplementary Fig. 4c and 4g)
xtmixed res_`v'_ind $demographics $wtd i.`t'_m##`m' if has_latest_round >=`i' & `t'<8 & `t' >= 0 & Australia == `j' ||country_enc: ||id_pseudo:, mle variance
estimates store  `v'_`t'`m'0wtdmlmixu
xtmixed res_`v'_ind $demographics $wtd i.`t'_m##ib1.`m' if has_latest_round >=`i' & `t'<8 & `t' >= 0 & Australia == `j' ||country_enc: ||id_pseudo:, mle variance
estimates store `v'_`t'`m'1wtdmlmixu

drop res_`v'_ind `v'_ind
}
} 
}
}
}
*
* Coefplots - panel a (gender)
global controls nonemlmix wtdmlmix nonemlmixu wtdmlmixu  
global moderators fem

foreach t of global t{
foreach v of global avoidances{
foreach i of numlist 1{
foreach m of global moderators{
foreach c of global controls{

coefplot (`v'_`t'fem0`c', label(Men) mcolor (blue) msize (small) ciopts(color(blue))) (`v'_`t'fem1`c', label(Women) mcolor (gray) msize (small) ciopts(color(gray))) ///
, keep(*`t'*) drop (*`m'* *`t'##`m'* *index* *req_c4_g* *req_c4_g* *mean_temp_WB* *hits_covid* *hits_coronavirus* *increase_deaths_sm*) yline(0, lcolor(gray) lpattern (dash)) yscale(r(-1.0,0.1)) ///
ylabel (-1.0 "-1.0" -0.5 "-.5" 0 "0" 0.5 ".5",labsize(vsmall) nogrid) xlabel (,labsize(vsmall)) graphregion(color(white)) vertical ///
title ("{bf:a}", size(medium) color(black) position(11)) t2title ("Gender", size(medium) color(black) position(13)) ///
xlabel (,labsize(vsmall)) legend (label (5) size(small) region(style(none)))
graph save "Graph" "`v'_`t'gender`c'.gph", replace
graph export "`v'_`t'gender`c'.png", as(png) name("Graph") replace
}
}
}
}
}
*
* Coefplots - panel b (chronic diseases)
global controls nonemlmix wtdmlmix nonemlmixu wtdmlmixu  
global moderators hci

foreach t of global t{
foreach v of global avoidances{
foreach i of numlist 1{
foreach m of global moderators{
foreach c of global controls{

coefplot (`v'_`t'hci0`c', label(No) mcolor (blue) msize (small) ciopts(color(blue))) (`v'_`t'hci1`c', label(Yes) mcolor (gray) msize (small) ciopts(color(gray))) ///
, keep(*`t'*) drop (*`m'* *`t'##`m'* *index* *req_c4_g* *req_c4_g* *mean_temp_WB* *hits_covid* *hits_coronavirus* *increase_deaths_sm*) yline(0, lcolor(gray) lpattern (dash)) yscale(r(-1.0,0.1)) ///
ylabel (-1.0 "-1.0" -0.5 "-.5" 0 "0" 0.5 ".5",labsize(vsmall) nogrid) xlabel (,labsize(vsmall)) graphregion(color(white)) vertical ///
title ("{bf:b}", size(medium) color(black) position(11)) t2title ("Chronic diseases", size(medium) color(black) position(13)) ///
xlabel (,labsize(vsmall)) legend (label (5) size(small) region(style(none)))
graph save "Graph" "`v'_`t'hci`c'.gph", replace
graph export "`v'_`t'hci`c'.png", as(png) name("Graph") replace
}
}
}
}
}
*
* Coefplots - panel a (one-person households)
global controls nonemlmix wtdmlmix nonemlmixu wtdmlmixu  
global moderators hhs1

foreach t of global t{
foreach v of global avoidances{
foreach i of numlist 1{
foreach m of global moderators{
foreach c of global controls{

coefplot (`v'_`t'hhs10`c', label(Households with more than one person) mcolor (blue) msize (small) ciopts(color(blue))) (`v'_`t'hhs11`c', label(One-person households) mcolor (gray) msize (small) ciopts(color(gray))) ///
, keep(*`t'*) drop (*`m'* *`t'##`m'* *index* *req_c4_g* *req_c4_g* *mean_temp_WB* *hits_covid* *hits_coronavirus* *increase_deaths_sm*) yline(0, lcolor(gray) lpattern (dash)) yscale(r(-1.0,0.1)) ///
ylabel (-1.0 "-1.0" -0.5 "-.5" 0 "0" 0.5 ".5",labsize(vsmall) nogrid) xlabel (,labsize(vsmall)) graphregion(color(white)) vertical ///
title ("{bf:a}", size(medium) color(black) position(11)) t2title ("Household size", size(medium) color(black) position(13)) ///
xlabel (,labsize(vsmall)) legend (label (5) size(small) row (2) region(style(none)))
graph save "Graph" "`v'_`t'hhs1`c'.gph", replace
graph export "`v'_`t'hhs1`c'.png", as(png) name("Graph") replace
}
}
}
}
}
*
* coefplots - panel b (one- or two-person households)
global controls nonemlmix wtdmlmix nonemlmixu wtdmlmixu  
global moderators hhs2

foreach t of global t{
foreach v of global avoidances{
foreach i of numlist 1{
foreach m of global moderators{
foreach c of global controls{

coefplot (`v'_`t'hhs20`c', label(Households with more than two persons) mcolor (blue) msize (small) ciopts(color(blue))) (`v'_`t'hhs21`c', label(One- or two-person households) mcolor (gray) msize (small) ciopts(color(gray))) ///
, keep(*`t'*) drop (*`m'* *`t'##`m'* *index* *req_c4_g* *req_c4_g* *mean_temp_WB* *hits_covid* *hits_coronavirus* *increase_deaths_sm*) yline(0, lcolor(gray) lpattern (dash)) yscale(r(-1.0,0.1)) ///
ylabel (-1.0 "-1.0" -0.5 "-.5" 0 "0" 0.5 ".5",labsize(vsmall) nogrid) xlabel (,labsize(vsmall)) graphregion(color(white)) vertical ///
title ("{bf:b}", size(medium) color(black) position(11)) t2title ("Household size", size(medium) color(black) position(13)) ///
xlabel (,labsize(vsmall)) legend (label (5) size(small) row (2) region(style(none)))
graph save "Graph" "`v'_`t'hhs2`c'.gph", replace
graph export "`v'_`t'hhs2`c'.png", as(png) name("Graph") replace
}
}
}
}
}
*
* Multinomial moderators
global moderators acr empc
global avoidances g_sh
label define acr 1"up to 30 years" 2"from 30 to 45 years" 3"from 45 to 60 years" 4"60 years or more"
label values acr acr

foreach m of global moderators{
use "$path\Data\Yougov_pseudo_panel_`m'.dta", clear
foreach t of global t{
foreach v of global avoidances{
foreach i of numlist 1{
foreach j of numlist 0{
foreach k of numlist 1/4{

** Multilevel model - no control and no interaction
xtmixed `v' $ind if has_latest_round == 1 & `t'<8 & `t'>= 0 & Australia == `j' ||country_enc: ||id_pseudo:, mle variance
predict `v'_ind, fitted
gen res_`v'_ind = `v' - `v'_ind

** Multilevel model - no control (Fig. 4)
xtmixed `v' $ind $demographics i.`t'_m##ib`k'.`m' if has_latest_round >=`i' & `t'<8 & `t' >= 0 & Australia == `j' ||country_enc: ||id_pseudo:, mle variance
estimates store `v'_`t'`m'`k'nonemlmix

** Multilevel model - weather, trends and deaths (Supplementary Fig. 4a)
xtmixed `v' $ind $demographics $wtd  i.`t'_m##ib`k'.`m' if has_latest_round >=`i' & `t'<8 & `t' >= 0 & Australia == `j' ||country_enc: ||id_pseudo:, mle variance
estimates store `v'_`t'`m'`k'wtdmlmix

** Multilevel model residuals - no controls (Supplementary Fig. 4b)
xtmixed res_`v'_ind $demographics  i.`t'_m##ib`k'.`m' if has_latest_round >=`i' & `t'<8 & `t' >= 0 & Australia == `j' ||country_enc: ||id_pseudo:, mle variance
estimates store `v'_`t'`m'`k'nonemlmixu

** Multilevel model residuals - weather, trends and deaths (Supplementary Fig. 4c)
xtmixed res_`v'_ind $demographics $wtd  i.`t'_m##ib`k'.`m' if has_latest_round >=`i' & `t'<8 & `t' >= 0 & Australia == `j' ||country_enc: ||id_pseudo:, mle variance
estimates store `v'_`t'`m'`k'wtdmlmixu

drop res_`v'_ind `v'_ind
}
} 
}
}
}
}
*
* Coefplots - panel c (age)
global controls nonemlmix wtdmlmix nonemlmixu wtdmlmixu
global moderators acr

foreach t of global t{
foreach v of global avoidances{
foreach i of numlist 1{
foreach m of global moderators{
foreach c of global controls{

coefplot (`v'_`t'`m'1`c', label(up to 30 years) mcolor (blue) msize (small) ciopts(color(blue))) (`v'_`t'`m'2`c', label(30 to 45 years) mcolor (orange) msize (small) ciopts(color(orange))) ///
(`v'_`t'`m'3`c', label(45 to 60 years) mcolor (purple) msize (small) ciopts(color(purple))) (`v'_`t'`m'4`c', label(60 years or more) mcolor (gray) msize (small) ciopts(color(gray))) ///
, keep(*`t'*) drop (*`m'* *`t'##`m'* *index* *req_c4_g* *req_c4_g* *mean_temp_WB* *hits_covid* *hits_coronavirus* *increase_deaths_sm* *hci* *fem*) yline(0, lcolor(gray) lpattern (dash)) yscale(r(-1.0,0.1)) ///
ylabel (-1.0 "-1.0" -0.5 "-.5" 0 "0" 0.5 ".5",labsize(vsmall) nogrid) xlabel (,labsize(vsmall)) graphregion(color(white)) vertical ///
title ("{bf:c}", size(medium) color(black) position(11)) t2title ("Age", size(medium) color(black) position(13)) ///
xlabel (,labsize(vsmall)) legend (label (5) size(small) row (2) region(style(none)))
graph save "Graph" "`v'_`t'age`c'.gph", replace
graph export "`v'_`t'age`c'.png", as(png) name("Graph") replace
}
}
}
}
}
*
* Coefplots - panel d (employment status)
global controls nonemlmix wtdmlmix nonemlmixu wtdmlmixu
global moderators empc

foreach t of global t{
foreach v of global avoidances{
foreach i of numlist 1{
foreach m of global moderators{
foreach c of global controls{

coefplot (`v'_`t'`m'1`c', label(Retired) mcolor (blue) msize (small) ciopts(color(blue))) (`v'_`t'`m'2`c', label(Student/others) mcolor (orange) msize (small) ciopts(color(orange))) ///
(`v'_`t'`m'3`c', label(Unemployed/not working) mcolor (purple) msize (small) ciopts(color(purple))) (`v'_`t'`m'4`c', label(Working) mcolor (gray) msize (small) ciopts(color(gray))) ///
, keep(*`t'*) drop (*`m'* *`t'##`m'* *index* *req_c4_g* *req_c4_g* *mean_temp_WB* *hits_covid* *hits_coronavirus* *increase_deaths_sm*) yline(0, lcolor(gray) lpattern (dash)) yscale(r(-1.0,0.1)) ///
ylabel (-1.0 "-1.0" -0.5 "-.5" 0 "0" 0.5 ".5",labsize(vsmall) nogrid) xlabel (,labsize(vsmall)) graphregion(color(white)) vertical ///
title ("{bf:d}", size(medium) color(black) position(11)) t2title ("Employment status", size(medium) color(black) position(13)) ///
xlabel (,labsize(vsmall)) legend (label (5) size(small) row (2) region(style(none)))
graph save "Graph" "`v'_`t'es`c'.gph", replace
graph export "`v'_`t'es`c'.png", as(png) name("Graph") replace
}
}
}
}
}
*
* Fig. 4
foreach c of global controls{
foreach t of global t{ 
foreach v of global avoidances{
graph combine `v'_`t'gender`c'.gph `v'_`t'hci`c'.gph `v'_`t'age`c'.gph `v'_`t'es`c'.gph, graphregion(color(white)) ///
col(2) l1("Change in behaviour (physical distancing)" "controlling for policy strength", size(small)) b1("Period since first required measure (days)", size(small) justification (right)) ycommon
graph save "Graph" "F4_`v'_`t'_`c'.gph", replace
graph export "F4_`v'_`t'_`c'.png", as(png) name("Graph") replace 
}
}
}
* Supplementary Fig. 4d-4g
foreach c of global controls{
foreach t of global t{ 
foreach v of global avoidances{
graph combine `v'_`t'hhs1`c'.gph `v'_`t'hhs2`c'.gph, graphregion(color(white)) ///
col(2) l1("Change in behaviour (physical distancing)" "controlling for policy strength", size(small)) b1("Period since first required measure (days)", size(small) justification (right)) ycommon
graph save "Graph" "F4_hhs_`v'`t'_`c'.gph", replace
graph export "F4_hhs_`v'`t'_`c'.png", as(png) name("Graph") replace 
}
}
}
*
********************************************************************************************************************************
** Fig. 5 | Pandemic-policy fatigue estimates from mobile-phone mobility data by institutional and interpersonal trust levels **
********************************************************************************************************************************

global moderators pth ith
global dvs ret res
foreach m of global moderators{
foreach v of global dvs{
foreach t of global t{

** Multilevel model - no control and no fatigue
xtmixed `v' $ind if `t' >= 0 & `t'_m_o <= 8 ||countrycode_enc:, mle variance 
predict `v'_ind, fitted
gen res_`v'_ind = `v' - `v'_ind

** Multilevel model - no control (Fig. 5)
xtmixed `v' $ind i.`t'_m##i.`m' if `t' >= 0 & `t'_m_o <= 8 ||countrycode_enc:, mle variance 
estimates store `v'_`t'_`m'0_nonemlmix
xtmixed `v' $ind i.`t'_m##ib1.`m' if `t' >= 0 & `t'_m_o <= 8 ||countrycode_enc:, mle variance 
estimates store `v'_`t'_`m'1_nonemlmix

** Multilevel model - weather, trends and deaths (Supplementary Fig. 5a)
xtmixed `v' $ind $wtd i.`t'_m##i.`m' if `t' >= 0 & `t'_m_o <= 8 ||countrycode_enc: , mle variance 
estimates store `v'_`t'_`m'0_wtdmlmix
xtmixed `v' $ind $wtd i.`t'_m##ib1.`m' if `t' >= 0 & `t'_m_o <= 8 ||countrycode_enc: , mle variance 
estimates store `v'_`t'_`m'1_wtdmlmix

** Multilevel model residuals - no controls (Supplementary Fig. 5b)
xtmixed res_`v'_ind i.`t'_m##i.`m' if `t' >= 0 & `t'_m_o <= 8 ||countrycode_enc: , mle variance 
estimates store `v'_`t'_`m'0_nonemlmixu
xtmixed res_`v'_ind i.`t'_m##ib1.`m' if `t' >= 0 & `t'_m_o <= 8 ||countrycode_enc: , mle variance 
estimates store `v'_`t'_`m'1_nonemlmixu

** Multilevel model residuals - weather, trends and deaths (Supplementary Fig. 5c)
xtmixed res_`v'_ind $wtd i.`t'_m##i.`m' if `t' >= 0 & `t'_m_o <= 8 ||countrycode_enc: , mle variance 
estimates store `v'_`t'_`m'0_wtdmlmixu
xtmixed res_`v'_ind $wtd i.`t'_m##ib1.`m' if `t' >= 0 & `t'_m_o <= 8 ||countrycode_enc: , mle variance 
estimates store `v'_`t'_`m'1_wtdmlmixu

drop res_`v'_ind `v'_ind
}
}
}
*
label variable ret "retail and recreation"
label variable res "residential mobility"
label variable ith "Institutional trust"
label variable pth "Interpersonal trust"

* Coefplots - panel a
global controls nonemlmix wtdmlmix nonemlmixu wtdmlmixu 
global dvs ret
global moderators ith
foreach c of global controls{
foreach v of global dvs{
foreach m of global moderators{
foreach t of global t{
coefplot (`v'_`t'_`m'0_`c', label(Low) mcolor (gs4) msize (small) ciopts(color(gs4))) (`v'_`t'_`m'1_`c', label(High) mcolor (blue) msize (small) ciopts(color(blue))) , keep(*`t'_m*) drop(*`m'* *income* *inc* *gini* *pth*) yline(0, lcolor(gray) lpattern (dash)) ///
title ("{bf:a}", size(mediumsmall) color(black) position(11)) t2title ("`:variable label `m''", size(mediumsmall) color(black) position(13)) ///
ylabel (-5(5)25,labsize(small) nogrid) xtitle ("",) ytitle ("Change (in percentage points)" "in `:variable label `v''" ///
"controlling for policy strength", size(small) margin (small) width(20)) xlabel (,labsize(vsmall)) legend(off) graphregion(color(white) margin(2 1 2 2)) vertical
graph save "Graph" "`v'_`t'_`m'_`c'.gph", replace
graph export "`v'_`t'_`m'_`c'.png", as(png) name("Graph") replace
}
}
}
}
*
* Coefplots - panel b
global controls nonemlmix wtdmlmix nonemlmixu wtdmlmixu 
global dvs ret
global moderators pth
foreach c of global controls{
foreach v of global dvs{
foreach m of global moderators{
foreach t of global t{
coefplot (`v'_`t'_`m'0_`c', label(Low) mcolor (gs4) msize (small) ciopts(color(gs4))) (`v'_`t'_`m'1_`c', label(High) mcolor (blue) msize (small) ciopts(color(blue))) , keep(*`t'_m*) drop(*`m'* *income* *inc* *gini* *ith*) yline(0, lcolor(gray) lpattern (dash)) ///
title ("{bf:b}", size(mediumsmall) color(black) position(11)) t2title ("`:variable label `m''", size(mediumsmall) color(black) position(13)) ///
ylabel (-5(5)25,labsize(small) nogrid) xtitle ("",) ytitle ("",) ///
xlabel (,labsize(vsmall)) legend(off) graphregion(color(white) margin(2 5 2 2)) vertical
graph save "Graph" "`v'_`t'_`m'_`c'.gph", replace
graph export "`v'_`t'_`m'_`c'.png", as(png) name("Graph") replace
}
}
}
}
*
* Coefplots - panel c
global controls nonemlmix wtdmlmix nonemlmixu wtdmlmixu 
global dvs res
global moderators ith
foreach c of global controls{
foreach v of global dvs{
foreach m of global moderators{
foreach t of global t{
coefplot (`v'_`t'_`m'0_`c', label(Low) mcolor (gs4) msize (small) ciopts(color(gs4))) (`v'_`t'_`m'1_`c', label(High) mcolor (blue) msize (small) ciopts(color(blue))) , keep(*`t'_m*) drop(*`m'* *income* *inc* *gini* *pth*) yline(0, lcolor(gray) lpattern (dash)) ///
title ("{bf:c}", size(mediumsmall) color(black) position(11)) ///
ylabel (-10(5)5,labsize(vsmall) nogrid)xtitle ("Period since first required measure (days)", size(small) margin (medsmall)) ytitle ("Change (in percentage points)" "in `:variable label `v''" ///
"controlling for policy strength", size(small) margin (small) width(20)) xlabel (,labsize(vsmall)) legend(size(small) rows(1) region(style(none))) graphregion(color(white) margin(2 1 2 2)) vertical
graph save "Graph" "`v'_`t'_`m'_`c'.gph", replace
graph export "`v'_`t'_`m'_`c'.png", as(png) name("Graph") replace
}
}
}
}
*
* Coefplots - panel d
global controls nonemlmix wtdmlmix nonemlmixu wtdmlmixu 
global dvs res
global moderators pth
foreach c of global controls{
foreach v of global dvs{
foreach m of global moderators{
foreach t of global t{
coefplot (`v'_`t'_`m'0_`c', label(Low) mcolor (gs4) msize (small) ciopts(color(gs4))) (`v'_`t'_`m'1_`c', label(High) mcolor (blue) msize (small) ciopts(color(blue))) , keep(*`t'_m*) drop(*`m'* *income* *inc* *gini* *ith*) yline(0, lcolor(gray) lpattern (dash)) ///
title ("{bf:d}", size(mediumsmall) color(black) position(11)) ///
ylabel (-10(5)5,labsize(vsmall) nogrid) xtitle ("Period since first required measure (days)", size(small) margin (medsmall)) ytitle ("",) ///
xlabel (,labsize(vsmall)) legend(size(small) rows(1) region(style(none))) graphregion(color(white) margin(2 5 2 2)) vertical
graph save "Graph" "`v'_`t'_`m'_`c'.gph", replace
graph export "`v'_`t'_`m'_`c'.png", as(png) name("Graph") replace
}
}
}
}
*
* Fig. 5
foreach c of global controls{
foreach t of global t{ 

graph combine ret_`t'_ith_`c'.gph ret_`t'_pth_`c'.gph res_`t'_ith_`c'.gph res_`t'_pth_`c'.gph, rows(2) graphregion(color(white)) 
graph save "Graph" "F5_`t'_`c'.gph", replace
graph export "F5_`t'_`c'.png", as(png) name("Graph") replace

}
}
*
* Supplementary Fig. 5 with additional controls
global moderators pth
global dvs ret res
foreach m of global moderators{
foreach v of global dvs{
foreach t of global t{

** Multilevel model - weather, trends, deaths, gini coef. and the other type of trust (Supplementary Fig. 5d)
xtmixed `v' $ind $wtd i.`t'_m##i.ith i.`t'_m##c.gini i.`t'_m##i.`m' if `t' >= 0 & `t'_m_o <= 8 ||countrycode_enc: , mle variance 
estimates store `v'_`t'_`m'0_wtdmlmix
xtmixed `v' $ind $wtd i.`t'_m##i.ith i.`t'_m##c.gini i.`t'_m##ib1.`m' if `t' >= 0 & `t'_m_o <= 8 ||countrycode_enc: , mle variance 
estimates store `v'_`t'_`m'1_wtdmlmix

}
}
}
*
global moderators ith
global dvs ret res
foreach m of global moderators{
foreach v of global dvs{
foreach t of global t{


** Multilevel model - weather, trends, deaths, gini coef. and the other type of trust (Supplementary Fig. 5d)
xtmixed `v' $ind $wtd i.`t'_m##i.pth i.`t'_m##c.gini i.`t'_m##i.`m' if `t' >= 0 & `t'_m_o <= 8 ||countrycode_enc: , mle variance 
estimates store `v'_`t'_`m'0_wtdmlmix
xtmixed `v' $ind $wtd i.`t'_m##i.pth i.`t'_m##c.gini i.`t'_m##ib1.`m' if `t' >= 0 & `t'_m_o <= 8 ||countrycode_enc: , mle variance 
estimates store `v'_`t'_`m'1_wtdmlmix

}
}
}
*
* Coefplots - panel a
global controls wtdmlmix
global dvs ret
global moderators ith
foreach c of global controls{
foreach v of global dvs{
foreach m of global moderators{
foreach t of global t{
coefplot (`v'_`t'_`m'0_`c', label(Low) mcolor (gs4) msize (small) ciopts(color(gs4))) (`v'_`t'_`m'1_`c', label(High) mcolor (blue) msize (small) ciopts(color(blue))) , keep(*`t'_m*) drop(*`m'* *gini* *pth*) yline(0, lcolor(gray) lpattern (dash)) ///
title ("{bf:a}", size(mediumsmall) color(black) position(11)) t2title ("`:variable label `m''", size(mediumsmall) color(black) position(13)) ///
ylabel (-10(10)60,labsize(small) nogrid) xtitle ("",) ytitle ("Change (in percentage points)" "in `:variable label `v''" ///
"controlling for policy strength", size(small) margin (small) width(20)) xlabel (,labsize(vsmall)) legend(off) graphregion(color(white) margin(2 1 2 2)) vertical
graph save "Graph" "`v'_`t'_`m'_`c'.gph", replace
graph export "`v'_`t'_`m'_`c'.png", as(png) name("Graph") replace
}
}
}
}
*
* Coefplots - panel b
global controls wtdmlmix 
global dvs ret
global moderators pth
foreach c of global controls{
foreach v of global dvs{
foreach m of global moderators{
foreach t of global t{
coefplot (`v'_`t'_`m'0_`c', label(Low) mcolor (gs4) msize (small) ciopts(color(gs4))) (`v'_`t'_`m'1_`c', label(High) mcolor (blue) msize (small) ciopts(color(blue))) , keep(*`t'_m*) drop(*`m'* *gini* *ith*) yline(0, lcolor(gray) lpattern (dash)) ///
title ("{bf:b}", size(mediumsmall) color(black) position(11)) t2title ("`:variable label `m''", size(mediumsmall) color(black) position(13)) ///
ylabel (-10(10)60,labsize(small) nogrid) xtitle ("",) ytitle ("",) ///
xlabel (,labsize(vsmall)) legend(off) graphregion(color(white) margin(2 5 2 2)) vertical
graph save "Graph" "`v'_`t'_`m'_`c'.gph", replace
graph export "`v'_`t'_`m'_`c'.png", as(png) name("Graph") replace
}
}
}
}
*
* Coefplots - panel c
global controls wtdmlmix 
global dvs res
global moderators ith
foreach c of global controls{
foreach v of global dvs{
foreach m of global moderators{
foreach t of global t{
coefplot (`v'_`t'_`m'0_`c', label(Low) mcolor (gs4) msize (small) ciopts(color(gs4))) (`v'_`t'_`m'1_`c', label(High) mcolor (blue) msize (small) ciopts(color(blue))) , keep(*`t'_m*) drop(*`m'* *gini* *pth*) yline(0, lcolor(gray) lpattern (dash)) ///
title ("{bf:c}", size(mediumsmall) color(black) position(11)) ///
ylabel (-25(5)5,labsize(vsmall) nogrid)xtitle ("Period since first required measure (days)", size(small) margin (medsmall)) ytitle ("Change (in percentage points)" "in `:variable label `v''" ///
"controlling for policy strength", size(small) margin (small) width(20)) xlabel (,labsize(vsmall)) legend(size(small) rows(1) region(style(none))) graphregion(color(white) margin(2 1 2 2)) vertical
graph save "Graph" "`v'_`t'_`m'_`c'.gph", replace
graph export "`v'_`t'_`m'_`c'.png", as(png) name("Graph") replace
}
}
}
}
*
* Coefplots - panel d
global controls wtdmlmix
global dvs res
global moderators pth
foreach c of global controls{
foreach v of global dvs{
foreach m of global moderators{
foreach t of global t{
coefplot (`v'_`t'_`m'0_`c', label(Low) mcolor (gs4) msize (small) ciopts(color(gs4))) (`v'_`t'_`m'1_`c', label(High) mcolor (blue) msize (small) ciopts(color(blue))) , keep(*`t'_m*) drop(*`m'* *gini* *ith*) yline(0, lcolor(gray) lpattern (dash)) ///
title ("{bf:d}", size(mediumsmall) color(black) position(11)) ///
ylabel (-25(5)5,labsize(vsmall) nogrid) xtitle ("Period since first required measure (days)", size(small) margin (medsmall)) ytitle ("",) ///
xlabel (,labsize(vsmall)) legend(size(small) rows(1) region(style(none))) graphregion(color(white) margin(2 5 2 2)) vertical
graph save "Graph" "`v'_`t'_`m'_`c'.gph", replace
graph export "`v'_`t'_`m'_`c'.png", as(png) name("Graph") replace
}
}
}
}
*
* Supplementary Fig. 5d
foreach c of global controls{
foreach t of global t{ 

graph combine ret_`t'_ith_`c'.gph ret_`t'_pth_`c'.gph res_`t'_ith_`c'.gph res_`t'_pth_`c'.gph, rows(2) graphregion(color(white)) 
graph save "Graph" "F5_`t'_`c'trustincgini.gph", replace
graph export "F5_`t'_`c'trustincgini.png", as(png) name("Graph") replace

}
}
*
**************************
** Supplementary Fig. 6 **
**************************
label variable ith "Institutional trust"
label variable pth "Interpersonal trust"

label define tfreq17_m_o 0 "0-30" 1 "30-60" 2 "60-90" 3 "90-120" 4 "120-150" 5 "150-180" 6 "180-210" 7 "210-240" 8 "240-270" 9 "270-300" 10 "300-330", modify
label values tfreq17_m_o tfreq17_m_o

* Panel a (Supplementary Fig. 6a and 6b)
global moderators ith 
foreach m of global moderators{
foreach t of global t{ 
preserve
replace `m' = 2 if `m' == 0
collapse (p50) stringencyindex, by(`m' `t'_m_o)
xtset `m' `t'_m_o
xtline stringencyindex if `t'_m_o>=0 & `t'_m_o<=8, overlay plot1(lc(blue)) plot2(lc(gs4)) graphregion(color(white)) ///
title ("{bf:a}", size(mediumsmall) color(black) position(11)) t2title ("`:variable label `m''", size(mediumsmall) color(black) position(13)) ytitle("Policy strength", size(small) margin (medium) width(20)) xtitle("",) ///
xlabel(, labsize(small) valuelabel) ylabel(0 "0" 50 "50" 100 "100", labsize(small) nogrid) ///
legend(off) graphregion(margin(2 20 2 2)),
graph save "Graph" "str_`m'_desc_`t'.gph", replace
graph export "str_`m'_desc_`t'.png", as(png) name("Graph") replace 
restore
}
}
*
* Panel b (Supplementary Fig. 6a and 6b)
global moderators pth
foreach m of global moderators{
foreach t of global t{ 
preserve
replace `m' = 2 if `m' == 0
collapse (p50) stringencyindex, by(`m' `t'_m_o)
xtset `m' `t'_m_o
xtline stringencyindex if `t'_m_o>=0 & `t'_m_o<=8, overlay plot1(lc(blue)) plot2(lc(gs4)) graphregion(color(white)) ///
title ("{bf:b}", size(mediumsmall) color(black) position(11)) t2title ("`:variable label `m''", size(mediumsmall) color(black) position(13)) ytitle("",) xtitle("",) ///
xlabel(, labsize(small) valuelabel) ylabel(0 "0" 50 "50" 100 "100", labsize(small) nogrid) ///
legend(off) graphregion(margin(2 20 2 2)),
graph save "Graph" "str_`m'_desc_`t'.gph", replace
graph export "str_`m'_desc_`t'.png", as(png) name("Graph") replace 
restore
}
}
*
* Panel c (Supplementary Fig. 6a)
global dvs ret
global moderators ith 
foreach m of global moderators{
foreach t of global t{ 
foreach v of global dvs{ 
preserve
replace `m' = 2 if `m' == 0
collapse `v' `t', by(`m' `t'_m_o)
xtset `m' `t'_m_o 
xtline `v' if `t'_m_o>=0 & `t'_m_o<=8, overlay plot1(lc(blue)) plot2(lc(gs4)) graphregion(color(white)) ///
title ("{bf:c}", size(mediumsmall) color(black) position(11)) ///
xtitle ("Period since first required measure (days)", size(small) margin (medsmall)) ytitle("Percentage change" "in retail and recreation", size(small) margin (medsmall) width(20)) ylabel(-50 "-50" -40 "-40" -30 "-30" -20 "-20" -10 "-10", labsize(small) nogrid) ///
legend(order(1 "High" 2 "Low") size(small) rows(1) region(style(none))) graphregion(margin(2 20 2 2)) xlabel(, labsize(small) valuelabel)
graph save "Graph" "`v'_`m'_desc_`t'.gph", replace
graph export "`v'_`m'_desc_`t'.png", as(png) name("Graph") replace 
restore
}
}
}
* Panel c (Supplementary Fig. 6b)
global dvs res
global moderators ith 
foreach m of global moderators{
foreach t of global t{ 
foreach v of global dvs{ 
preserve
replace `m' = 2 if `m' == 0
collapse `v' `t', by(`m' `t'_m_o)
xtset `m' `t'_m_o 
xtline `v' if `t'_m_o>=0 & `t'_m_o<=8, overlay plot1(lc(blue)) plot2(lc(gs4)) graphregion(color(white)) ///
title ("{bf:c}", size(mediumsmall) color(black) position(11)) ///
xtitle ("Period since first required measure (days)", size(small) margin (medsmall)) ytitle("Percentage change" "in residential mobility", size(small) margin (medsmall) width(20)) ylabel(0 "0" 5 "5" 10 "10" 15 "15" 20 "20" 25 "25", labsize(small) nogrid) ///
legend(order(1 "High" 2 "Low") size(small) rows(1) region(style(none))) graphregion(margin(2 20 2 2)) xlabel(, labsize(small) valuelabel)
graph save "Graph" "`v'_`m'_desc_`t'.gph", replace
graph export "`v'_`m'_desc_`t'.png", as(png) name("Graph") replace 
restore
}
}
}
* Panel d (Supplementary Fig. 6a)
global dvs res 
global moderators pth 
foreach m of global moderators{
foreach t of global t{ 
foreach v of global dvs{ 
preserve
replace `m' = 2 if `m' == 0
collapse `v' `t', by(`m' `t'_m_o)
xtset `m' `t'_m_o 
xtline `v' if `t'_m_o>=0 & `t'_m_o<=8, overlay plot1(lc(blue)) plot2(lc(gs4)) graphregion(color(white)) ///
title ("{bf:d}", size(mediumsmall) color(black) position(11)) ///
xtitle ("Period since first required measure (days)", size(small) margin (medsmall)) ytitle ("",) ylabel(0 "0" 5 "5" 10 "10" 15 "15" 20 "20" 25 "25", labsize(small) nogrid) ///
legend(order(1 "High" 2 "Low") size(small) rows(1) region(style(none))) graphregion(margin(2 20 2 2)) xlabel(, labsize(small) valuelabel)
graph save "Graph" "`v'_`m'_desc_`t'.gph", replace
graph export "`v'_`m'_desc_`t'.png", as(png) name("Graph") replace 
restore
}
}
}
* Panel d (Supplementary Fig. 6b)
global dvs ret
global moderators pth 
foreach m of global moderators{
foreach t of global t{ 
foreach v of global dvs{ 
preserve
replace `m' = 2 if `m' == 0
collapse `v' `t', by(`m' `t'_m_o)
xtset `m' `t'_m_o 
xtline `v' if `t'_m_o>=0 & `t'_m_o<=8, overlay plot1(lc(blue)) plot2(lc(gs4)) graphregion(color(white)) ///
title ("{bf:d}", size(mediumsmall) color(black) position(11)) ///
xtitle ("Period since first required measure (days)", size(small) margin (medsmall)) ytitle ("",) ylabel(-50 "-50" -40 "-40" -30 "-30" -20 "-20" -10 "-10", labsize(small) nogrid) ///
legend(order(1 "High" 2 "Low") size(small) rows(1) region(style(none))) graphregion(margin(2 20 2 2)) xlabel(, labsize(small) valuelabel)
graph save "Graph" "`v'_`m'_desc_`t'.gph", replace
graph export "`v'_`m'_desc_`t'.png", as(png) name("Graph") replace 
restore
}
}
}
*
* Supplementary Fig. 6a and 6b
global dvs ret res
foreach t of global t{ 
foreach v of global dvs{

graph combine str_ith_desc_`t'.gph str_pth_desc_`t'.gph `v'_ith_desc_`t'.gph `v'_pth_desc_`t'.gph ///
, rows(3) graphregion(color(white)) graphregion(margin(l=3 r=3))
graph save "Graph" "F6_`v'_`t'.gph", replace
graph export "F6_`v'_`t'.png", as(png) name("Graph") replace

}
}
*
* Supplementary Fig. 6c-6h

* Supplementary Fig. 6c (age)
use "$path\Data\Yougov_pseudo_panel_acr.dta", clear
label define tfreq17_m_o 0 "0-30" 1 "30-60" 2 "60-90" 3 "90-120" 4 "120-150" 5 "150-180" 6 "180-210" 7 "210-240" 8 "240-270" 9 "270-300" 10 "300-330", modify
label values tfreq17_m_o tfreq17_m_o
global dvs g_sh
global moderators acr
foreach m of global moderators{
foreach t of global t{ 
foreach v of global dvs{ 
preserve
collapse `v' `t', by(`m' `t'_m_o)
xtset `m' `t'_m_o 
xtline `v' if `t'_m_o >=0 & `t'_m_o<=8, overlay plot1(lc(blue)) plot2(lc(orange)) plot3(lc(purple)) plot4(lc(gray)) graphregion(color(white)) ///
ytitle("Physical distancing", size(small) margin (medium) width(20)) ylabel (3.0 "3" 3.5 "3.5" 4.0 "4" 4.5 "4.5",labsize(vsmall) nogrid) ///
legend(order(1 "up to 30 years" 2 "30 to 45 years" 3 "45 to 60 years" 4 "60 years or more") size(small) rows(2) region(style(none))) ///
legend (label (1 "up to 30 years") size(vsmall)) graphregion(margin(2 20 2 2)) xtitle("",) xlabel(, labsize(vsmall) valuelabel)
graph save "Graph" "F6_`m'_`v'_`t'_`c'.gph", replace
graph export "F6_`m'_`v'_`t'_`c'.png", as(png) name("Graph") replace 
restore
}
}
}
*
* Supplementary Fig. 6d (employment status)
use "$path\Data\Yougov_pseudo_panel_empc.dta", clear
label define tfreq17_m_o 0 "0-30" 1 "30-60" 2 "60-90" 3 "90-120" 4 "120-150" 5 "150-180" 6 "180-210" 7 "210-240" 8 "240-270" 9 "270-300" 10 "300-330", modify
label values tfreq17_m_o tfreq17_m_o
global dvs g_sh
global moderators empc
foreach m of global moderators{
foreach t of global t{ 
foreach v of global dvs{ 
preserve
collapse `v' `t', by(`m' `t'_m_o)
xtset `m' `t'_m_o 
xtline `v' if `t'_m_o >=0 & `t'_m_o<=8, overlay plot1(lc(blue)) plot2(lc(orange)) plot3(lc(purple)) plot4(lc(gray)) graphregion(color(white)) ///
ytitle("Physical distancing", size(small) margin (medium) width(20)) ylabel (3.0 "3" 3.5 "3.5" 4.0 "4" 4.5 "4.5",labsize(vsmall) nogrid) ///
legend(order(1 "Retired" 2 "Student/others" 3 "Unemployed/not working" 4 "Working") size(small) rows(2) region(style(none))) ///
legend (label (1 "Retired") size(vsmall)) graphregion(margin(2 20 2 2)) xtitle("",) xlabel(, labsize(vsmall) valuelabel)
graph save "Graph" "F6_`m'_`v'_`t'_`c'.gph", replace
graph export "F6_`m'_`v'_`t'_`c'.png", as(png) name("Graph") replace 
restore
}
}
}
*
* Supplementary Fig. 6e (gender)
use "$path\Data\Yougov_pseudo_panel_fem.dta", clear
label define tfreq17_m_o 0 "0-30" 1 "30-60" 2 "60-90" 3 "90-120" 4 "120-150" 5 "150-180" 6 "180-210" 7 "210-240" 8 "240-270" 9 "270-300" 10 "300-330", modify
label values tfreq17_m_o tfreq17_m_o
global dvs g_sh
global moderators fem
foreach m of global moderators{
foreach t of global t{ 
foreach v of global dvs{ 
preserve
replace `m' = 2 if `m' == 0
collapse `v' `t', by(`m' `t'_m_o)
xtset `m' `t'_m_o 
xtline `v' if `t'_m_o >=0 & `t'_m_o<=8, overlay plot1(lc(blue)) plot2(lc(gs4)) graphregion(color(white)) ///
ytitle("Physical distancing", size(small) margin (medium) width(20)) ylabel (3.0 "3" 3.5 "3.5" 4.0 "4" 4.5 "4.5",labsize(vsmall) nogrid) ///
legend(order(1 "Women" 2 "Men") size(small) rows(1) region(style(none))) ///
legend (label (1 "Women") size(vsmall)) graphregion(margin(2 20 2 2)) xtitle("",) xlabel(, labsize(vsmall) valuelabel)
graph save "Graph" "F6_`m'_`v'_`t'_`c'.gph", replace
graph export "F6_`m'_`v'_`t'_`c'.png", as(png) name("Graph") replace 
restore
}
}
}
* Supplementary Fig. 6f (chronic diseases)
use "$path\Data\Yougov_pseudo_panel_hci.dta", clear
label define tfreq17_m_o 0 "0-30" 1 "30-60" 2 "60-90" 3 "90-120" 4 "120-150" 5 "150-180" 6 "180-210" 7 "210-240" 8 "240-270" 9 "270-300" 10 "300-330", modify
label values tfreq17_m_o tfreq17_m_o
global dvs g_sh
global moderators hci
foreach m of global moderators{
foreach t of global t{ 
foreach v of global dvs{ 
preserve
replace `m' = 2 if `m' == 0
collapse `v' `t', by(`m' `t'_m_o)
xtset `m' `t'_m_o 
xtline `v' if `t'_m_o >=0 & `t'_m_o<=8, overlay plot1(lc(blue)) plot2(lc(gs4)) graphregion(color(white)) ///
ytitle("Physical distancing", size(small) margin (medium) width(20)) ylabel (3.0 "3" 3.5 "3.5" 4.0 "4" 4.5 "4.5",labsize(vsmall) nogrid) ///
legend(order(1 "Has chronic illness" 2 "Has not chronic illness") size(small) rows(2) region(style(none))) ///
legend (label (1 "Has chronic illness") size(vsmall)) graphregion(margin(2 20 2 2)) xtitle("",) xlabel(, labsize(vsmall) valuelabel)
graph save "Graph" "F6_`m'_`v'_`t'_`c'.gph", replace
graph export "F6_`m'_`v'_`t'_`c'.png", as(png) name("Graph") replace 
restore
}
}
}
*
* Supplementary Fig. 6g (household size - one-person households)
use "$path\Data\Yougov_pseudo_panel_hhs1.dta", clear
label define tfreq17_m_o 0 "0-30" 1 "30-60" 2 "60-90" 3 "90-120" 4 "120-150" 5 "150-180" 6 "180-210" 7 "210-240" 8 "240-270" 9 "270-300" 10 "300-330", modify
label values tfreq17_m_o tfreq17_m_o
global dvs g_sh
global moderators hhs1
foreach m of global moderators{
foreach t of global t{ 
foreach v of global dvs{ 
preserve
replace `m' = 2 if `m' == 0
collapse `v' `t', by(`m' `t'_m_o)
xtset `m' `t'_m_o 
xtline `v' if `t'_m_o >=0 & `t'_m_o<=8, overlay plot1(lc(blue)) plot2(lc(gs4)) graphregion(color(white)) ///
ytitle("Physical distancing", size(small) margin (medium) width(20)) ylabel (3.0 "3" 3.5 "3.5" 4.0 "4" 4.5 "4.5",labsize(vsmall) nogrid) ///
legend(order(1 "One-person households" 2 "Households with more than one person") size(small) rows(2) region(style(none))) ///
legend (label (1 "One-person households") size(vsmall)) graphregion(margin(2 20 2 2)) xtitle("",) xlabel(, labsize(vsmall) valuelabel)
graph save "Graph" "F6_`m'_`v'_`t'_`c'.gph", replace
graph export "F6_`m'_`v'_`t'_`c'.png", as(png) name("Graph") replace 
restore
}
}
}
*
* Supplementary Fig. 6h (household size - one- or two-person households)
use "$path\Data\Yougov_pseudo_panel_hhs2.dta", clear
label define tfreq17_m_o 0 "0-30" 1 "30-60" 2 "60-90" 3 "90-120" 4 "120-150" 5 "150-180" 6 "180-210" 7 "210-240" 8 "240-270" 9 "270-300" 10 "300-330", modify
label values tfreq17_m_o tfreq17_m_o
global dvs g_sh
global moderators hhs2
foreach m of global moderators{
foreach t of global t{ 
foreach v of global dvs{ 
preserve
replace `m' = 2 if `m' == 0
collapse `v' `t', by(`m' `t'_m_o)
xtset `m' `t'_m_o 
xtline `v' if `t'_m_o >=0 & `t'_m_o<=8, overlay plot1(lc(blue)) plot2(lc(gs4)) graphregion(color(white)) ///
ytitle("Physical distancing", size(small) margin (medium) width(20)) ylabel (3.0 "3" 3.5 "3.5" 4.0 "4" 4.5 "4.5",labsize(vsmall) nogrid) ///
legend(order(1 "One- or two-person households" 2 "Households with more than two persons") size(small) rows(2) region(style(none))) ///
legend (label (1 "One- or two-person households") size(vsmall)) graphregion(margin(2 20 2 2)) xtitle("",) xlabel(, labsize(vsmall) valuelabel)
graph save "Graph" "F5_`m'_`v'_`t'_`c'.gph", replace
graph export "F5_`m'_`v'_`t'_`c'.png", as(png) name("Graph") replace 
restore
}
}
}
*
* Supplementary Fig. 6i and 6j
use "$path\Data\googlemobility_modified.dta", clear

label define tfreq17_m_o 0 "0-30" 1 "30-60" 2 "60-90" 3 "90-120" 4 "120-150" 5 "150-180" 6 "180-210" 7 "210-240" 8 "240-270" 9 "270-300" 10 "300-330", modify
label values tfreq17_m_o tfreq17_m_o

* Supplementary Fig. 6i - panel a (income)
global dvs ret
global moderators inc
foreach m of global moderators{
foreach t of global t{ 
foreach v of global dvs{ 
preserve
collapse `v' `t', by(`m' `t'_m_o)
xtset `m' `t'_m_o 
xtline `v' if `t'_m_o >=0 & `t'_m_o<=8, overlay plot1(lc(blue)) plot2(lc(orange)) plot3(lc(purple)) plot4(lc(gray)) graphregion(color(white)) ///
ytitle("Percentage change" "in retail and recreation", size(small) margin (medium) width(20)) ylabel(-50 "-50" -25 "-25" 0 "0" 25 "25", labsize(small) nogrid) ///
title ("{bf:a}", size(medium) color(black) position(11)) legend(order(1 "High income" 2 "Upper-middle income" 3 "Lower-middle income" 4 "Low income") size(small) rows(2) region(style(none))) ///
legend (label (1 "High income") size(vsmall)) graphregion(margin(1 5 1 1)) xtitle("",) xlabel(, labsize(vsmall) valuelabel)
graph save "Graph" "`v'_`m'_desc_`t'.gph", replace
graph export "`v'_`m'_desc_`t'.png", as(png) name("Graph") replace 
restore
}
}
}
*
* Supplementary Fig. 6j - panel a (region)
global dvs ret
global moderators reg
foreach m of global moderators{
foreach t of global t{ 
foreach v of global dvs{ 
preserve
collapse `v' `t', by(`m' `t'_m_o)
xtset `m' `t'_m_o 
xtline `v' if `t'_m_o >=0 & `t'_m_o<=8, overlay plot1(lc(purple)) plot2(lc(orange)) plot3(lc(gray)) plot4(lc(blue)) graphregion(color(white)) ///
ytitle("Percentage change" "in retail and recreation", size(small) margin (medsmall) width(20)) ylabel(-50 "-50" -25 "-25" 0 "0" 25 "25", labsize(small) nogrid) ///
title ("{bf:a}", size(medium) color(black) position(11)) legend(order(1 "Europe" 2 "Latin America & Caribbean" 3 "East Asia" 4 "Sub-Saharan Africa") size(small) rows(2) region(style(none))) ///
legend (label (1 "Europe") size(vsmall)) graphregion(margin(1 5 1 1)) xtitle("",) xlabel(, labsize(vsmall) valuelabel) 
graph save "Graph" "`v'_`m'_desc_`t'.gph", replace
graph export "`v'_`m'_desc_`t'.png", as(png) name("Graph") replace 
restore
}
}
}
*
* Supplementary Fig. 6i and 6j - panel b (income and region)
global dvs res
global moderators inc reg
foreach m of global moderators{
foreach t of global t{ 
foreach v of global dvs{ 
preserve
collapse `v' `t', by(`m' `t'_m_o)
xtset `m' `t'_m_o 
xtline `v' if `t'_m_o >=0 & `t'_m_o<=8, overlay plot1(lc(blue)) plot2(lc(orange)) plot3(lc(purple)) plot4(lc(gray)) graphregion(color(white)) ///
ytitle("Percentage change" "in residential mobility", size(small) margin (medsmall) width(20)) ylabel(-50 "-50" -25 "-25" 0 "0" 25 "25", labsize(small) nogrid) ///
title ("{bf:b}", size(medium) color(black) position(11)) legend(off) graphregion(margin(1 5 1 1)) xtitle ("",) xlabel(, labsize(vsmall) valuelabel)
graph save "Graph" "`v'_`m'_desc_`t'.gph", replace
graph export "`v'_`m'_desc_`t'.png", as(png) name("Graph") replace 
restore
}
}
}
*
* Supplementary Fig. 6i and 6j
global moderators inc reg
foreach m of global moderators{
foreach t of global t{ 
grc1leg ret_`m'_desc_`t'.gph res_`m'_desc_`t'.gph, graphregion(color(white)) graphregion(margin(l=3 r=3)) b1("Period since first required measure (days)", size (small)) ring(4)
graph save "Graph" "F6_`m'_`v'_`t'_`c'.gph", replace
graph export "F6_`m'_`v'_`t'_`c'.png", as(png) name("Graph") replace
 
}
}
*
**************************
** Supplementary Fig. 7 **
**************************

* Supplementary Fig. 7a
collapse indexc4 indexc6, by(country tfreq17_m_o)

tostring tfreq17_m_o, gen (date_str)
gen id = country + date_str

rename indexc4 v_1
rename indexc6 v_2


reshape long v_ , i(id) j(v_j)

label define v_j 1"Restrictions on gatherings" 2"Stay at home req."
label values v_j v_j

decode v_j, gen (v_j_txt)
gen country_v = country + v_j_txt
encode country_v, gen(country_v_enc)

xtset country_v_enc tfreq17_m_o

tab country, gen (country_dummy)
rename country_dummy1 Canada
rename country_dummy2 Denmark
rename country_dummy3 Finland
rename country_dummy4 France
rename country_dummy5 Germany
rename country_dummy6 Italy
rename country_dummy7 Japan
rename country_dummy8 Netherlands
rename country_dummy9 Norway
rename country_dummy10 SK
rename country_dummy11 Singapore
rename country_dummy12 Spain
rename country_dummy13 Sweden
rename country_dummy14 UK

label variable Canada "Canada"
label variable Denmark "Denmark"
label variable Finland "Finland"
label variable France "France"
label variable Germany "Germany"
label variable Italy "Italy"
label variable Japan "Japan"
label variable Netherlands "Netherlands"
label variable Norway "Norway"
label variable SK "South Korea"
label variable Singapore "Singapore"
label variable Spain "Spain"
label variable Sweden "Sweden"
label variable UK "United Kingdom"

global countries Canada Denmark Finland France Germany Italy Japan Netherlands Norway SK Singapore Spain Sweden UK
global t tfreq17
foreach c of global countries{
foreach t of global t{

xtline v_ if `c' == 1 & `t'_m_o >= 0 & `t'_m_o <= 8 & (v_j == 1 | v_j == 2), overlay plot1(lc(blue)) plot2(lc(gray)) ///
legend(order(1 "Restrictions on gatherings" 2 "Stay at home req.") size(vsmall) rows(1) ///
symxsize(5) region(style(none))) graphregion(color(white) margin(0 3 0 0)) ytitle("") plotregion(margin(0 0 0 0)) ///
xtitle (" ") xlabel(0 "0-30" 2 "60-90" 4 "120-150" 6 "180-210" 8 "240-270",labsize(vsmall)) ///
ylabel(0(25)100, labsize(vsmall) nogrid) yscale(r(-10,100)) title ("`:variable label `c''", size(small) color(black)) 

graph save "Graph" "appendix_`c'.gph", replace
graph export "appendix_`c'.png", as(png) name("Graph")  replace
}
}
*
* Supplementary Fig. 7a
grc1leg appendix_Canada.gph appendix_Denmark.gph appendix_Finland.gph appendix_France.gph appendix_Germany.gph appendix_Italy.gph ///
appendix_Japan.gph appendix_Netherlands.gph appendix_Norway.gph appendix_Singapore.gph appendix_SK.gph ///
appendix_Spain.gph appendix_Sweden.gph appendix_UK.gph, graphregion(color(white)) ring(1)  b1("Period since first required measure (days)", size(vsmall)) ///
l1("Policy strength", size(vsmall)) graphregion(margin(l=3 r=3))
graph save "Graph" "F7a_country_list.gph", replace
graph export "F7a_country_list.png", as(png) name("Graph") replace

* Supplementary Fig. 7b and 7c

use "$path\Data\Yougov_pseudo_panel_fem.dta", clear
decode country_enc, gen (countryname)
merge m:m countryname using "$path\Data\mobility\googlemobility_modified.dta"

keep if _merge == 3

label define tfreq17_m_o 0 "0-30" 1 "30-60" 2 "60-90" 3 "90-120" 4 "120-150" 5 "150-180" 6 "180-210" 7 "210-240" 8 "240-270" 9 "270-300" 10 "300-330", modify
label values tfreq17_m_o tfreq17_m_o

keep ret res g_sh country tfreq17_m_o

collapse ret res g_sh, by(country tfreq17_m_o)

tostring tfreq17_m_o, gen (date_str)
gen id = country + date_str

rename res v_1
rename ret v_2
rename g_sh v_3

reshape long v_ , i(id) j(v_j)

label define v_j 1"Time spent in residential locations" 2"Retail and recreation visits" 3"Avoidance of gatherings and going out"
label values v_j v_j

decode v_j, gen (v_j_txt)
gen country_v = country + v_j_txt
encode country_v, gen(country_v_enc)

xtset country_v_enc tfreq17_m_o

tab country, gen (country_dummy)
rename country_dummy1 Canada
rename country_dummy2 Denmark
rename country_dummy3 Finland
rename country_dummy4 France
rename country_dummy5 Germany
rename country_dummy6 Italy
rename country_dummy7 Japan
rename country_dummy8 Netherlands
rename country_dummy9 Norway
rename country_dummy10 SK
rename country_dummy11 Singapore
rename country_dummy12 Spain
rename country_dummy13 Sweden
rename country_dummy14 UK

label variable Canada "Canada"
label variable Denmark "Denmark"
label variable Finland "Finland"
label variable France "France"
label variable Germany "Germany"
label variable Italy "Italy"
label variable Japan "Japan"
label variable Netherlands "Netherlands"
label variable Norway "Norway"
label variable SK "South Korea"
label variable Singapore "Singapore"
label variable Spain "Spain"
label variable Sweden "Sweden"
label variable UK "United Kingdom"

* Avoidance
foreach c of global countries{
foreach t of global t{

xtline v_ if `c' == 1 & `t'_m_o >= 0 & `t'_m_o <= 8 & (v_j == 3), overlay plot1(lc(gray)) ///
graphregion(color(white) margin(0 3 0 0)) ytitle("") plotregion(margin(0 0 0 0)) ///
xtitle (" ") xlabel(0 "0-30" 2 "60-90" 4 "120-150" 6 "180-210" 8 "240-270",labsize(vsmall)) ///
ylabel(2.5(0.5)4.6, labsize(vsmall) nogrid) title ("`:variable label `c''", size(small) color(black)) legend(off)

graph save "Graph" "appendix_`c'.gph", replace
graph export "appendix_`c'.png", as(png) name("Graph")  replace
}
}
*
* Supplementary Fig. 7b  
graph combine appendix_Canada.gph appendix_Denmark.gph appendix_Finland.gph appendix_France.gph appendix_Germany.gph appendix_Italy.gph ///
appendix_Japan.gph appendix_Netherlands.gph appendix_Norway.gph appendix_Singapore.gph appendix_SK.gph ///
appendix_Spain.gph appendix_Sweden.gph appendix_UK.gph, graphregion(color(white)) b1("Period since first required measure (days)", size(vsmall)) ///
l1("Physical distancing", size(vsmall)) graphregion(margin(l=3 r=3))
graph save "Graph" "F7b_country_list.gph", replace
graph export "F7b_country_list.png", as(png) name("Graph") replace

* Mobility
global countries Canada Denmark Finland France Germany Italy Japan Netherlands Norway SK Singapore Spain Sweden UK
global t tfreq17
foreach c of global countries{
foreach t of global t{

xtline v_ if `c' == 1 & `t'_m_o >= 0 & `t'_m_o <= 8 & (v_j == 1 | v_j == 2), overlay plot1(lc(blue)) plot2(lc(gray)) ///
legend(order(1 "Retail and recreation visits" 2 "Time spent in residential locations") size(vsmall) rows(2) ///
symxsize(5) region(style(none))) graphregion(color(white) margin(0 3 0 0)) ytitle("") plotregion(margin(0 0 0 0)) ///
xtitle (" ") xlabel(0 "0-30" 2 "60-90" 4 "120-150" 6 "180-210" 8 "240-270",labsize(vsmall)) ///
ylabel(-100(25)25, labsize(vsmall) nogrid) title ("`:variable label `c''", size(small) color(black)) 

graph save "Graph" "appendix_`c'.gph", replace
graph export "appendix_`c'.png", as(png) name("Graph")  replace
}
}
*
* Supplementary Fig. 7c
grc1leg appendix_Canada.gph appendix_Denmark.gph appendix_Finland.gph appendix_France.gph appendix_Germany.gph appendix_Italy.gph ///
appendix_Japan.gph appendix_Netherlands.gph appendix_Norway.gph appendix_Singapore.gph appendix_SK.gph ///
appendix_Spain.gph appendix_Sweden.gph appendix_UK.gph, graphregion(color(white)) ring(1)  b1("Period since first required measure (days)", size(vsmall)) ///
l1("Percentage change""in mobility", size(vsmall)) graphregion(margin(l=3 r=3))
graph save "Graph" "F7c_country_list.gph", replace
graph export "F7c_country_list.png", as(png) name("Graph") replace


***************************************************************************************************************
** Table 1 | Pandemic-policy fatigue estimates - physical distancing as the dependent variable (survey data) **
***************************************************************************************************************
use "$path\Data\Yougov_pseudo_panel_fem.dta", clear

global avoidances g_sh  
foreach t of global t{
foreach v of global avoidances{

* null model
xtmixed `v' if has_latest_round == 1 & `t'<8 & `t'>= 0 & Australia ==0 ||country_enc: ||id_pseudo: , mle variance 

* no fatigue (Model 1)
xtmixed `v' $ind if has_latest_round == 1 & `t'<8 & `t'>= 0 & Australia ==0 ||country_enc: ||id_pseudo: , mle variance 
xtmrho
outreg2 using "Table_1.xls", label ci r2 dec(3) noaster long addstat("ICC", e(rho1)) alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' no fatigue) sideway append 
predict `v'_ind, fitted
gen res_`v'_ind = `v' - `v'_ind

* null model residuals
xtmixed res_`v'_ind if has_latest_round == 1 & `t'<8 & `t'>= 0 & Australia ==0 ||country_enc: ||id_pseudo: , mle variance 

* fatigue without controls (Model 2)
xtmixed `v' $ind $demographics tfreq17_c tfreq17_c2 if has_latest_round == 1 & `t'<8 & `t'>= 0 & Australia ==0 ||country_enc: ||id_pseudo: tfreq17_c tfreq17_c2  , mle variance 
xtmrho
outreg2 using "Table_1.xls", label ci r2 dec(3) noaster long addstat("ICC", e(rho1)) alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with no controls) sideway append 

* fatigue without controls residuals (Model 3)
xtmixed res_`v'_ind $demographics tfreq17_c tfreq17_c2 if has_latest_round == 1 & `t'<8 & `t'>= 0 & Australia ==0 ||country_enc: ||id_pseudo: tfreq17_c tfreq17_c2 , mle variance 
xtmrho
outreg2 using "Table_1.xls", label ci r2 dec(3) noaster long addstat("ICC", e(rho1)) alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with no controls residuals) sideway append 

*fatigue with controls (Model 4)
xtmixed `v' tfreq17_c tfreq17_c2 $ind $demographics $wtd  if has_latest_round == 1 & `t'<8 & `t'>= 0 & Australia ==0 || country_enc: ||id_pseudo: tfreq17_c tfreq17_c2 ,  mle variance 
xtmrho
outreg2 using "Table_1.xls", label ci r2 dec(3) noaster long addstat("ICC", e(rho1)) alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with controls) sideway append 

drop res_`v'_ind `v'_ind
}
}
*
************************************************************************
** Tables 2 and 3 | Pandemic-policy fatigue estimates (mobility data) **
************************************************************************
use "$path\Data\mobility\googlemobility_modified.dta", clear

global dvs ret res
foreach l of numlist 8{
foreach t of global t{
foreach v of global dvs{

* null model
xtmixed `v' if `t'>=0 & `t'<=`l' ||countrycode_enc:, mle variance 

* no fatigue
xtmixed `v' $ind  if `t'>=0 & `t'<=`l' ||countrycode_enc:, mle variance  
xtmrho
outreg2 using "Table_`v'.xls", label ci r2 dec(3) noaster long addstat("ICC", e(rho1)) alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' no fatigue) sideway append 

* fatigue without controls
xtmixed `v' $ind tfreq17_c tfreq17_c2 if `t'>=0 & `t'<=`l' ||countrycode_enc: tfreq17_c tfreq17_c2 , mle variance  
xtmrho
outreg2 using "Table_`v'.xls", label ci r2 dec(3) noaster long addstat("ICC", e(rho1)) alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with no controls) sideway append 

* fatigue with controls
xtmixed `v' $ind tfreq17_c tfreq17_c2 $wtd if `t'>=0 & `t'<=`l' ||countrycode_enc: tfreq17_c tfreq17_c2 , mle variance  
xtmrho
outreg2 using "Table_`v'.xls", label ci r2 dec(3) noaster long addstat("ICC", e(rho1)) alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with controls) sideway append 

}
}
}
*
********************************************************************************************
** Supplementary Table 1a | Fatigue estimates (residual models with additional controls)  **
********************************************************************************************
use "$path\Data\Yougov_pseudo_panel_fem.dta", clear
global avoidances g_sh  
foreach t of global t{
foreach v of global avoidances{

* no fatigue
xtmixed `v' $ind if has_latest_round == 1 & `t'<8 & `t'>= 0 & Australia ==0 ||country_enc: ||id_pseudo: , mle variance 
predict `v'_ind, fitted
gen res_`v'_ind = `v' - `v'_ind

* null model residuals
xtmixed res_`v'_ind if has_latest_round == 1 & `t'<8 & `t'>= 0 & Australia ==0 ||country_enc: ||id_pseudo: , mle variance 

*fatigue with controls residuals
xtmixed res_`v'_ind tfreq17_c tfreq17_c2 $demographics $wtd  if has_latest_round == 1 & `t'<8 & `t'>= 0 & Australia ==0 || country_enc: ||id_pseudo: tfreq17_c tfreq17_c2 ,  mle variance 
xtmrho
outreg2 using "Table_1a.xls", label se r2 long addstat("ICC", e(rho1)) alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with controls residuals) append 

drop res_`v'_ind `v'_ind
}
}
*
use "$path\Data\mobility\googlemobility_modified.dta", clear
global dvs ret res
foreach l of numlist 8{
foreach t of global t{
foreach v of global dvs{


* no fatigue
xtmixed `v' $ind  if `t'>=0 & `t'<=`l' ||countrycode_enc:, mle variance  
predict `v'_ind, fitted
gen res_`v'_ind = `v' - `v'_ind

* null model residuals
xtmixed res_`v'_ind if `t'>=0 & `t'<=`l' ||countrycode_enc:, mle variance  

* fatigue with controls residuals
xtmixed res_`v'_ind tfreq17_c tfreq17_c2 $wtd if `t'>=0 & `t'<=`l' ||countrycode_enc: tfreq17_c tfreq17_c2 , mle variance  
xtmrho
outreg2 using "Table_1a.xls", label se r2 long addstat("ICC", e(rho1)) alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with controls residuals) append 

drop res_`v'_ind `v'_ind
}
}
}
*
************************************************************************
** Supplementary Table 1b | Fatigue estimates - Fixed-effects models  **
************************************************************************
use "$path\Data\Yougov_pseudo_panel_fem.dta", clear
xtset id_pseudo
global avoidances g_sh  
foreach t of global t{
foreach v of global avoidances{

* no fatigue
xtreg `v' $ind if has_latest_round == 1 & `t'<8 & `t'>= 0 & Australia ==0, fe cluster(id_pseudo) 
outreg2 using "Table_1b.xls", label se r2 alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' no fatigue) append 

* fatigue without controls
xtreg `v' $ind $demographics tfreq17_c tfreq17_c2 if has_latest_round == 1 & `t'<8 & `t'>= 0 & Australia ==0, fe cluster(id_pseudo)  
outreg2 using "Table_1b.xls", label se r2 alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with no controls) append 

*fatigue with controls
xtreg `v' $ind $demographics $wtd tfreq17_c tfreq17_c2 if has_latest_round == 1 & `t'<8 & `t'>= 0 & Australia ==0, fe cluster(id_pseudo)  
outreg2 using "Table_1b.xls", label se r2 alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with controls) append 

}
}
*
use "$path\Data\mobility\googlemobility_modified.dta", clear

global dvs ret res
foreach l of numlist 8{
foreach t of global t{
foreach v of global dvs{

* no fatigue
xtreg `v' $ind  if `t'>=0 & `t'<=`l', fe cluster(countrycode_enc)  
outreg2 using "Table_1b.xls", label se r2 alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with no fatigue) append 

* fatigue without controls
xtreg `v' $ind tfreq17_c tfreq17_c2 if `t'>=0 & `t'<=`l', fe cluster(countrycode_enc) 
outreg2 using "Table_1b.xls", label se r2 alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with no controls) append 

* fatigue with controls
xtreg `v' $ind $wtd tfreq17_c tfreq17_c2 if `t'>=0 & `t'<=`l', fe cluster(countrycode_enc) 
outreg2 using "Table_1b.xls", label se r2 alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with controls) append 

}
}
}
*
************************************************************************************************************************
** Supplementary Table 1c | Fatigue estimates for physical distancing with categorical policy variables (survey data) **
************************************************************************************************************************
use "$path\Data\Yougov_pseudo_panel_fem.dta", clear

gen c1_i = 0 if indexc1 <16.66666
replace c1_i = 17 if indexc1 >= 16.66666 & indexc1 < 33.33333
replace c1_i = 33 if indexc1 >= 33.33333 & indexc1 < 50
replace c1_i = 50 if indexc1 >= 50 & indexc1 < 66.66666
replace c1_i = 67 if indexc1 >= 66.66666 & indexc1 < 83.33333
replace c1_i = 83 if indexc1 >= 83.33333 & indexc1 < 100
replace c1_i = 100 if indexc1 == 100

gen c2_i = 0 if indexc2 <16.66666
replace c2_i = 17 if indexc2 >= 16.66666 & indexc2 < 33.33333
replace c2_i = 33 if indexc2 >= 33.33333 & indexc2 < 50
replace c2_i = 50 if indexc2 >= 50 & indexc2 < 66.66666
replace c2_i = 67 if indexc2 >= 66.66666 & indexc2 < 83.33333
replace c2_i = 83 if indexc2 >= 83.33333 & indexc2 < 100
replace c2_i = 100 if indexc2 == 100

gen c3_i = 0 if indexc3 <25
replace c3_i = 25 if indexc3 >= 25 & indexc3 < 50
replace c3_i = 50 if indexc3 >= 50 & indexc3 < 75
replace c3_i = 75 if indexc3 >= 75 & indexc3 < 100
replace c3_i = 100 if indexc3 == 100

gen c4_i = 0 if indexc4 <12.5
replace c4_i = 13 if indexc4 >= 12.5 & indexc4 < 25
replace c4_i = 25 if indexc4 >= 25 & indexc4 < 37.5
replace c4_i = 38 if indexc4 >= 37.5 & indexc4 < 50
replace c4_i = 50 if indexc4 >= 50 & indexc4 < 62.5
replace c4_i = 63 if indexc4 >= 62.5 & indexc4 < 75
replace c4_i = 75 if indexc4 >= 75 & indexc4 < 87.5
replace c4_i = 88 if indexc4 >= 87.5 & indexc4 < 100
replace c4_i = 100 if indexc4 == 100

gen c5_i = 0 if indexc5 <25
replace c5_i = 25 if indexc5 >= 25 & indexc5 < 50
replace c5_i = 50 if indexc5 >= 50 & indexc5 < 75
replace c5_i = 75 if indexc5 >= 75 & indexc5 < 100
replace c5_i = 100 if indexc5 == 100

gen c6_i = 0 if indexc6 <16.66666
replace c6_i = 17 if indexc6 >= 16.66666 & indexc6 < 33.33333
replace c6_i = 33 if indexc6 >= 33.33333 & indexc6 < 50
replace c6_i = 50 if indexc6 >= 50 & indexc6 < 66.66666
replace c6_i = 67 if indexc6 >= 66.66666 & indexc6 < 83.33333
replace c6_i = 83 if indexc6 >= 83.33333 & indexc6 < 100
replace c6_i = 100 if indexc6 == 100

gen c7_i = 0 if indexc7 <25
replace c7_i = 25 if indexc7 >= 25 & indexc7 < 50
replace c7_i = 50 if indexc7 >= 50 & indexc7 < 75
replace c7_i = 75 if indexc7 >= 75 & indexc7 < 100
replace c7_i = 100 if indexc7 == 100

gen c8_i = 0 if indexc8 <25
replace c8_i = 25 if indexc8 >= 25 & indexc8 < 50
replace c8_i = 50 if indexc8 >= 50 & indexc8 < 75
replace c8_i = 75 if indexc8 >= 75 & indexc8 < 100
replace c8_i = 100 if indexc8 == 100

global ind i.c1_i i.c2_i i.c3_i i.c4_i i.c5_i i.c6_i i.c7_i i.c8_i

global avoidances g_sh  
foreach t of global t{
foreach v of global avoidances{

* null model
xtmixed `v' if has_latest_round == 1 & `t'<8 & `t'>= 0 & Australia ==0 ||country_enc: ||id_pseudo: , mle variance 

* no fatigue
xtmixed `v' $ind if has_latest_round == 1 & `t'<8 & `t'>= 0 & Australia ==0 ||country_enc: ||id_pseudo: , mle variance 
xtmrho
outreg2 using "Table_1c.xls", label se r2 long addstat("ICC", e(rho1)) alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' no fatigue) append 
predict `v'_ind, fitted
gen res_`v'_ind = `v' - `v'_ind

* null model residuals
xtmixed res_`v'_ind if has_latest_round == 1 & `t'<8 & `t'>= 0 & Australia ==0 ||country_enc: ||id_pseudo: , mle variance 

* fatigue without controls
xtmixed `v' $ind $demographics tfreq17_c tfreq17_c2 if has_latest_round == 1 & `t'<8 & `t'>= 0 & Australia ==0 ||country_enc: ||id_pseudo: tfreq17_c tfreq17_c2  , mle variance 
xtmrho
outreg2 using "Table_1c.xls", label se r2 long addstat("ICC", e(rho1)) alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with no controls) append 

* fatigue without controls residuals
xtmixed res_`v'_ind $demographics tfreq17_c tfreq17_c2 if has_latest_round == 1 & `t'<8 & `t'>= 0 & Australia ==0 ||country_enc: ||id_pseudo: tfreq17_c tfreq17_c2 , mle variance 
xtmrho
outreg2 using "Table_1c.xls", label se r2 long addstat("ICC", e(rho1)) alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with no controls residuals) append 

*fatigue with controls
xtmixed `v' tfreq17_c tfreq17_c2 $ind $demographics $wtd  if has_latest_round == 1 & `t'<8 & `t'>= 0 & Australia ==0 || country_enc: ||id_pseudo: tfreq17_c tfreq17_c2 ,  mle variance 
xtmrho
outreg2 using "Table_1c.xls", label se r2 long addstat("ICC", e(rho1)) alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with controls) append 

*fatigue with controls residuals
xtmixed res_`v'_ind tfreq17_c tfreq17_c2 $demographics $wtd  if has_latest_round == 1 & `t'<8 & `t'>= 0 & Australia ==0 || country_enc: ||id_pseudo: tfreq17_c tfreq17_c2 ,  mle variance 
xtmrho
outreg2 using "Table_1c.xls", label se r2 long addstat("ICC", e(rho1)) alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with controls residuals) append 

drop res_`v'_ind `v'_ind
}
}
*
************************************************************************************************************
** Supplementary Tables 1d and 1e | Fatigue estimates for mobility data with categorical policy variables **
************************************************************************************************************
use "$path\Data\mobility\googlemobility_modified.dta", clear

gen c1_i = round(indexc1)
gen c2_i = round(indexc2)
gen c3_i = round(indexc3)
gen c4_i = round(indexc4)
gen c5_i = round(indexc5)
gen c6_i = round(indexc6)
gen c7_i = round(indexc7)
gen c8_i = round(indexc8)

global ind i.c1_i i.c2_i i.c3_i i.c4_i i.c5_i i.c6_i i.c7_i i.c8_i

global dvs ret res
foreach l of numlist 8{
foreach t of global t{
foreach v of global dvs{

* null model
xtmixed `v' if `t'>=0 & `t'<=`l' ||countrycode_enc:, mle variance 

* no fatigue
xtmixed `v' $ind  if `t'>=0 & `t'<=`l' ||countrycode_enc:, mle variance  
xtmrho
outreg2 using "Table_1d&e.xls", label se r2 long addstat("ICC", e(rho1)) alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' no fatigue) append 
predict `v'_ind, fitted
gen res_`v'_ind = `v' - `v'_ind

* null model residuals
xtmixed res_`v'_ind if `t'>=0 & `t'<=`l' ||countrycode_enc:, mle variance  

* fatigue without controls
xtmixed `v' $ind tfreq17_c tfreq17_c2 if `t'>=0 & `t'<=`l' ||countrycode_enc: tfreq17_c tfreq17_c2 , mle variance  
xtmrho
outreg2 using "Table_1d&e.xls", label se r2 long addstat("ICC", e(rho1)) alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with no controls) append 

* fatigue without controls residuals
xtmixed res_`v'_ind tfreq17_c tfreq17_c2 if `t'>=0 & `t'<=`l' ||countrycode_enc: tfreq17_c tfreq17_c2 , mle variance  
xtmrho
outreg2 using "Table_1d&e.xls", label se r2 long addstat("ICC", e(rho1)) alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with no controls residuals) append 


* fatigue with controls
xtmixed `v' $ind tfreq17_c tfreq17_c2 $wtd if `t'>=0 & `t'<=`l' ||countrycode_enc: tfreq17_c tfreq17_c2 , mle variance  
xtmrho
outreg2 using "Table_1d&e.xls", label se r2 long addstat("ICC", e(rho1)) alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with controls) append 

* fatigue with controls residuals
xtmixed res_`v'_ind tfreq17_c tfreq17_c2 $wtd if `t'>=0 & `t'<=`l' ||countrycode_enc: tfreq17_c tfreq17_c2 , mle variance  
xtmrho
outreg2 using "Table_1d&e.xls", label se r2 long addstat("ICC", e(rho1)) alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with controls residuals) append 

drop res_`v'_ind `v'_ind
}
}
}
*
*************************************************************************
** Supplementary Tables 2a-2b and 2d-2f | Fatigue estimates moderation **
*************************************************************************
global moderators fem hci empc hhs1 hhs2
global avoidances g_sh
global t tfreq17

foreach m of global moderators{
use "$path\Data\Yougov_pseudo_panel_`m'.dta", clear
foreach v of global avoidances{
foreach t of global t{

* null model
xtmixed `v' if has_latest_round == 1 & `t'<8 & `t'>= 0 & Australia ==0 ||country_enc: ||id_pseudo:, mle variance 

* no fatigue
xtmixed `v' $ind if has_latest_round == 1 & `t'<8 & `t'>= 0 & Australia ==0 ||country_enc: ||id_pseudo:, mle variance
xtmrho 
outreg2 using "Table_2_`m'.xls", label se r2 long addstat("ICC", e(rho1)) alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' no fatigue) append 
predict `v'_ind, fitted
gen res_`v'_ind = `v' - `v'_ind

* null model residuals
xtmixed res_`v'_ind if has_latest_round == 1 & `t'<8 & `t'>= 0 & Australia ==0 ||country_enc: ||id_pseudo:, mle variance 

** Multilevel model - no control
xtmixed `v' $ind i.`t'_m##i.`m' i.`t'_m##c.age if has_latest_round >=1 & `t'<8 & `t' >= 0 & Australia == 0 ||country_enc: ||id_pseudo:, mle variance 
outreg2 using "Table_2_`m'.xls", label se r2  alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with no controls) append 

** Multilevel model residuals - no control
xtmixed res_`v'_ind i.`t'_m##i.`m' i.`t'_m##c.age if has_latest_round >=1 & `t'<8 & `t' >= 0 & Australia == 0 ||country_enc: ||id_pseudo:, mle variance 
outreg2 using "Table_2_`m'.xls", label se r2  alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with no controls residuals) append 


** Multilevel model - weather, trends and deaths
xtmixed `v' $ind $wtd i.`t'_m##i.`m' i.`t'_m##c.age if has_latest_round >=1 & `t'<8 & `t' >= 0 & Australia == 0 ||country_enc: ||id_pseudo:, mle variance 
outreg2 using "Table_2_`m'.xls", label se r2  alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with controls) append 

** Multilevel model residuals - weather, trends and deaths
xtmixed res_`v'_ind $wtd i.`t'_m##i.`m' i.`t'_m##c.age if has_latest_round >=1 & `t'<8 & `t' >= 0 & Australia == 0 ||country_enc: ||id_pseudo:, mle variance 
outreg2 using "Table_2_`m'.xls", label se r2  alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with controls residuals) append 

drop res_`v'_ind `v'_ind

}
}
}
*
***********************************************************************
** Supplementary Table 2c | Fatigue estimates moderation (age group) **
***********************************************************************
global moderators acr
global avoidances g_sh
global t tfreq17

foreach m of global moderators{
use "$path\Data\Yougov_pseudo_panel_`m'.dta", clear
foreach v of global avoidances{
foreach t of global t{

* null model
xtmixed `v' if has_latest_round == 1 & `t'<8 & `t'>= 0 & Australia ==0 ||country_enc: ||id_pseudo:, mle variance 

* no fatigue
xtmixed `v' $ind if has_latest_round == 1 & `t'<8 & `t'>= 0 & Australia ==0 ||country_enc: ||id_pseudo:, mle variance
xtmrho 
outreg2 using "Table_2_`m'.xls", label se r2 long addstat("ICC", e(rho1)) alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' no fatigue) append 
predict `v'_ind, fitted
gen res_`v'_ind = `v' - `v'_ind

* null model residuals
xtmixed res_`v'_ind if has_latest_round == 1 & `t'<8 & `t'>= 0 & Australia ==0 ||country_enc: ||id_pseudo:, mle variance 

** Multilevel model - no control
xtmixed `v' $ind i.`t'_m##i.`m' if has_latest_round >=1 & `t'<8 & `t' >= 0 & Australia == 0 ||country_enc: ||id_pseudo:, mle variance 
outreg2 using "Table_2_`m'.xls", label se r2  alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with no controls) append 

** Multilevel model residuals - no control
xtmixed res_`v'_ind i.`t'_m##i.`m' if has_latest_round >=1 & `t'<8 & `t' >= 0 & Australia == 0 ||country_enc: ||id_pseudo:, mle variance 
outreg2 using "Table_2_`m'.xls", label se r2  alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with no controls residuals) append 

** Multilevel model - weather, trends and deaths
xtmixed `v' $ind $wtd i.`t'_m##i.`m' if has_latest_round >=1 & `t'<8 & `t' >= 0 & Australia == 0 ||country_enc: ||id_pseudo:, mle variance 
outreg2 using "Table_2_`m'.xls", label se r2  alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with controls) append 

** Multilevel model residuals - weather, trends and deaths
xtmixed res_`v'_ind $wtd i.`t'_m##i.`m' if has_latest_round >=1 & `t'<8 & `t' >= 0 & Australia == 0 ||country_enc: ||id_pseudo:, mle variance 
outreg2 using "Table_2_`m'.xls", label se r2  alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with controls residuals) append 

drop res_`v'_ind `v'_ind

}
}
}
*
**************************************************************************************************************
** Supplementary Tables 3a-3b | Fatigue estimates by levels of trust, controlling for income and Gini index **
**************************************************************************************************************
use "$path\Data\mobility\googlemobility_modified.dta", clear
global dvs res ret
global moderators WVS_trust_most
foreach m of global moderators{
foreach v of global dvs{
foreach t of global t{

* null model
xtmixed `v' if `t' >= 0 & `t' <= 8 ||countrycode_enc:, mle variance 

* no fatigue
xtmixed `v' $ind if `t' >= 0 & `t' <= 8 ||countrycode_enc:, mle variance 
outreg2 using "Table_3`v'.xls", label se r2 long alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' no fatigue) append 
predict `v'_ind, fitted
gen res_`v'_ind = `v' - `v'_ind

* null model residuals
xtmixed res_`v'_ind if `t' >= 0 & `t' <= 8 ||countrycode_enc:, mle variance 

** Multilevel model - no control
xtmixed `v' $ind i.`t'_m##c.`m' i.`t'_m##i.inc i.`t'_m##c.WVS_institutional_trust i.`t'_m##c.gini if `t' >= 0 & `t' <= 8 ||countrycode_enc:, mle variance 
outreg2 using "Table_3`v'.xls", label se r2  alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with no controls) append 

** Multilevel model - weather, trends and deaths
xtmixed `v' $ind $wtd i.`t'_m##c.`m' i.`t'_m##i.inc i.`t'_m##c.WVS_institutional_trust i.`t'_m##c.gini if `t' >= 0 & `t' <= 8 ||countrycode_enc:, mle variance 
outreg2 using "Table_3`v'.xls", label se r2  alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with controls) append 

** Multilevel model residuals - no control
xtmixed res_`v'_ind i.`t'_m##c.`m' i.`t'_m##i.inc i.`t'_m##c.WVS_institutional_trust i.`t'_m##c.gini if `t' >= 0 & `t' <= 8 ||countrycode_enc:, mle variance 
outreg2 using "Table_3`v'.xls", label se r2  alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with no controls residuals) append 

** Multilevel model residuals - weather, trends and deaths
xtmixed res_`v'_ind $wtd i.`t'_m##c.`m' i.`t'_m##i.inc i.`t'_m##c.WVS_institutional_trust i.`t'_m##c.gini if `t' >= 0 & `t' <= 8 ||countrycode_enc:, mle variance 
outreg2 using "Table_3`v'.xls", label se r2  alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with controls residuals) append 

drop res_`v'_ind `v'_ind

}
}
}
*
*****************************************************************************************************************************
** Supplementary Tables 3c-3d | Fatigue estimates with binary trust (0=low, 1=high), controlling for income and Gini index **
*****************************************************************************************************************************
use "$path\Data\mobility\googlemobility_modified.dta", clear
global dvs res ret
global moderators pth
foreach m of global moderators{
foreach v of global dvs{
foreach t of global t{

* null model
xtmixed `v' if `t' >= 0 & `t' <= 8 ||countrycode_enc:, mle variance 

* no fatigue
xtmixed `v' $ind if `t' >= 0 & `t' <= 8 ||countrycode_enc:, mle variance 
outreg2 using "Table_3`v'.xls", label se r2 long alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' no fatigue) append 
predict `v'_ind, fitted
gen res_`v'_ind = `v' - `v'_ind

* null model residuals
xtmixed res_`v'_ind if `t' >= 0 & `t' <= 8 ||countrycode_enc:, mle variance 

** Multilevel model - no control
xtmixed `v' $ind i.`t'_m##i.`m' i.`t'_m##i.inc i.`t'_m##i.ith i.`t'_m##c.gini if `t' >= 0 & `t' <= 8 ||countrycode_enc:, mle variance 
outreg2 using "Table_3`v'.xls", label se r2  alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with no controls) append 

** Multilevel model - weather, trends and deaths
xtmixed `v' $ind $wtd i.`t'_m##i.`m' i.`t'_m##i.inc i.`t'_m##i.ith i.`t'_m##c.gini if `t' >= 0 & `t' <= 8 ||countrycode_enc:, mle variance 
outreg2 using "Table_3`v'.xls", label se r2  alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with controls) append 

** Multilevel model residuals - no control
xtmixed res_`v'_ind i.`t'_m##i.`m' i.`t'_m##i.inc i.`t'_m##i.ith i.`t'_m##c.gini if `t' >= 0 & `t' <= 8 ||countrycode_enc:, mle variance 
outreg2 using "Table_3`v'.xls", label se r2  alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with no controls residuals) append 

** Multilevel model residuals - weather, trends and deaths
xtmixed res_`v'_ind $wtd i.`t'_m##i.`m' i.`t'_m##i.inc i.`t'_m##i.ith i.`t'_m##c.gini if `t' >= 0 & `t' <= 8 ||countrycode_enc:, mle variance 
outreg2 using "Table_3`v'.xls", label se r2  alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with controls residuals) append 

drop res_`v'_ind `v'_ind

}
}
}
*
***************************************************************************
** Supplementary Tables 4a-4b | Fatigue estimates by geographical region **
***************************************************************************
use "$path\Data\mobility\googlemobility_modified.dta", clear
global dvs res ret
global moderators reg
foreach m of global moderators{
foreach v of global dvs{
foreach t of global t{


* null model
xtmixed `v' if `t' >= 0 & `t' <= 8 ||countrycode_enc:, mle variance 

* no fatigue
xtmixed `v' $ind if `t' >= 0 & `t' <= 8 ||countrycode_enc:, mle variance 
outreg2 using "Table_4`v'.xls", label se r2 long alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' no fatigue) append 
predict `v'_ind, fitted
gen res_`v'_ind = `v' - `v'_ind

* null model residuals
xtmixed res_`v'_ind if `t' >= 0 & `t' <= 8 ||countrycode_enc:, mle variance 

** Multilevel model - no control
xtmixed `v' $ind i.`t'_m##ib2.`m' if `t' >= 0 & `t' <= 8 ||countrycode_enc:, mle variance 
outreg2 using "Table_4`v'.xls", label se r2  alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with no controls) append 

** Multilevel model residuals - no control
xtmixed res_`v'_ind i.`t'_m##ib2.`m' if `t' >= 0 & `t' <= 8 ||countrycode_enc:, mle variance 
outreg2 using "Table_4`v'.xls", label se r2  alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with no controls residuals) append 

** Multilevel model - weather, trends and deaths
xtmixed `v' $ind $wtd i.`t'_m##ib2.`m' if `t' >= 0 & `t' <= 8 ||countrycode_enc:, mle variance 
outreg2 using "Table_4`v'.xls", label se r2  alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with controls) append 

** Multilevel model residuals - weather, trends and deaths
xtmixed res_`v'_ind $wtd i.`t'_m##ib2.`m' if `t' >= 0 & `t' <= 8 ||countrycode_enc:, mle variance 
outreg2 using "Table_4`v'.xls", label se r2  alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with controls residuals) append 

drop res_`v'_ind `v'_ind

}
}
}
*
************************************************************************
** Supplementary Tables 5a-5b | Fatigue estimates by levels of income **
************************************************************************
use "$path\Data\mobility\googlemobility_modified.dta", clear
global dvs res ret
global moderators inc
foreach m of global moderators{
foreach v of global dvs{
foreach t of global t{


* null model
xtmixed `v' if `t' >= 0 & `t' <= 8 ||countrycode_enc:, mle variance 

* no fatigue
xtmixed `v' $ind if `t' >= 0 & `t' <= 8 ||countrycode_enc:, mle variance 
outreg2 using "Table_5`v'.xls", label se r2 long alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' no fatigue) append 
predict `v'_ind, fitted
gen res_`v'_ind = `v' - `v'_ind

* null model residuals
xtmixed res_`v'_ind if `t' >= 0 & `t' <= 8 ||countrycode_enc:, mle variance 

** Multilevel model - no control
xtmixed `v' $ind i.`t'_m##i.`m' if `t' >= 0 & `t' <= 8 ||countrycode_enc:, mle variance 
outreg2 using "Table_5`v'.xls", label se r2  alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with no controls) append 

** Multilevel model residuals - no control
xtmixed res_`v'_ind i.`t'_m##i.`m' if `t' >= 0 & `t' <= 8 ||countrycode_enc:, mle variance 
outreg2 using "Table_5`v'.xls", label se r2  alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with no controls residuals) append 

** Multilevel model - weather, trends and deaths
xtmixed `v' $ind $wtd i.`t'_m##i.`m' if `t' >= 0 & `t' <= 8 ||countrycode_enc:, mle variance 
outreg2 using "Table_5`v'.xls", label se r2  alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with controls) append 

** Multilevel model residuals - weather, trends and deaths
xtmixed res_`v'_ind $wtd i.`t'_m##i.`m' if `t' >= 0 & `t' <= 8 ||countrycode_enc:, mle variance 
outreg2 using "Table_5`v'.xls", label se r2  alpha(0.01, 0.05, 0.10) ctitle(`:variable label `v'' with controls residuals) append 

drop res_`v'_ind `v'_ind

}
}
}
*
*********************************************************
** Supplementary Table 6 | Initial changes in mobility **
*********************************************************
use "$path\Data\mobility\googlemobility_modified.dta", clear
local vars indexc1 indexc2 indexc3 indexc4 indexc5 indexc6 indexc7 indexc8 res ret 
foreach v of local vars{
foreach i of numlist 0/8{
bysort countrycode_enc: egen initial_`v'_tfreq17_`i'p = mean(`v') if tfreq17>=`i' & tfreq17<=`i'+1
bysort countrycode_enc: egen initial_`v'_tfreq17_`i' = max(initial_`v'_tfreq17_`i'p)
drop initial_`v'_tfreq17_`i'p
}
}
*
encode income_group_WB, gen (income_group_WB_enc)
encode Geographical_Region, gen(Geographical_Region_enc)

reg initial_res_tfreq17_0 i.income_group_WB_enc initial_indexc1_tfreq17_0 initial_indexc2_tfreq17_0 initial_indexc3_tfreq17_0 initial_indexc4_tfreq17_0 initial_indexc5_tfreq17_0 initial_indexc6_tfreq17_0 initial_indexc7_tfreq17_0 initial_indexc8_tfreq17_0 if primary_country==1 & (Geographical_Region_enc == 10 | Geographical_Region_enc == 4 | Geographical_Region_enc == 3 | Geographical_Region_enc == 2)
outreg2 using "Table_6.xls", label se r2 alpha(0.01, 0.05, 0.10) ctitle(res) append 

reg initial_ret_tfreq17_0 i.income_group_WB_enc initial_indexc1_tfreq17_0 initial_indexc2_tfreq17_0 initial_indexc3_tfreq17_0 initial_indexc4_tfreq17_0 initial_indexc5_tfreq17_0 initial_indexc6_tfreq17_0 initial_indexc7_tfreq17_0 initial_indexc8_tfreq17_0 if primary_country==1 & (Geographical_Region_enc == 10 | Geographical_Region_enc == 4 | Geographical_Region_enc == 3 | Geographical_Region_enc == 2)
outreg2 using "Table_6.xls", label se r2 alpha(0.01, 0.05, 0.10) ctitle(ret) append 

reg initial_res_tfreq17_0 ib4.Geographical_Region_enc initial_indexc1_tfreq17_0 initial_indexc2_tfreq17_0 initial_indexc3_tfreq17_0 initial_indexc4_tfreq17_0 initial_indexc5_tfreq17_0 initial_indexc6_tfreq17_0 initial_indexc7_tfreq17_0 initial_indexc8_tfreq17_0 if primary_country==1 & (Geographical_Region_enc == 10 | Geographical_Region_enc == 4 | Geographical_Region_enc == 3 | Geographical_Region_enc == 2)
outreg2 using "Table_6.xls", label se r2 alpha(0.01, 0.05, 0.10) ctitle(res) append 

reg initial_ret_tfreq17_0 ib4.Geographical_Region_enc initial_indexc1_tfreq17_0 initial_indexc2_tfreq17_0 initial_indexc3_tfreq17_0 initial_indexc4_tfreq17_0 initial_indexc5_tfreq17_0 initial_indexc6_tfreq17_0 initial_indexc7_tfreq17_0 initial_indexc8_tfreq17_0 if primary_country==1 & (Geographical_Region_enc == 10 | Geographical_Region_enc == 4 | Geographical_Region_enc == 3 | Geographical_Region_enc == 2)
outreg2 using "Table_6.xls", label se r2 alpha(0.01, 0.05, 0.10) ctitle(ret) append 


**********************************************************************************************************
** Supplementary Table 7 | Initial change in physical distancing by demographic variables (survey data) **
**********************************************************************************************************



************************************************************************************************
** Supplementary Tables 8a-8d | Monthly changes in mobility with binary trust (0=low, 1=high) **
************************************************************************************************
use "$path\Data\mobility\googlemobility_modified.dta", clear
local vars indexc1 indexc2 indexc3 indexc4 indexc5 indexc6 indexc7 indexc8 res ret 
foreach v of local vars{
foreach i of numlist 0/8{
bysort countrycode_enc: egen initial_`v'_tfreq17_`i'p = mean(`v') if tfreq17>=`i' & tfreq17<=`i'+1
bysort countrycode_enc: egen initial_`v'_tfreq17_`i' = max(initial_`v'_tfreq17_`i'p)
drop initial_`v'_tfreq17_`i'p
}
}
*
local dvs res ret
local trust ith pth
foreach d of local dvs{
foreach t of local trust{
foreach i of numlist 0/8{

reg initial_`d'_tfreq17_`i' `t' initial_indexc1_tfreq17_`i' initial_indexc2_tfreq17_`i' initial_indexc3_tfreq17_`i' initial_indexc4_tfreq17_`i' initial_indexc5_tfreq17_`i' initial_indexc6_tfreq17_`i' initial_indexc7_tfreq17_`i' initial_indexc8_tfreq17_`i' gini i.income_WB if primary_country ==1 
outreg2 using "Table_8_`d'_`t'.xls", label se r2 alpha(0.01, 0.05, 0.10) append 

}
}
}
*
