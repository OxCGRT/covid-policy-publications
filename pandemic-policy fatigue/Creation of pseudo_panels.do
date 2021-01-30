
***********************************
* Collapsed data - age and gender *
***********************************

global path ""

use "$path\Dataset_YouGov_Tracker_processed.dta", clear
set more off

gen tfreq17_day = tfreq17*30

*egen tfreq17_w = cut(tfreq17_day), at(0, 7, 14, 21, 28, 35, 42, 49, 56, 63, 70, 77, 84, 91, 98, 105, 112, 119, 126, 133, 140, 147, 154, 161, 168, 175, 182, 189)

*egen tfreq17_w = cut(tfreq17_day), at(0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100, 105, 110, 115, 120, 125, 135, 145, 150, 155, )

egen tfreq17_w = cut(tfreq17_day), at(0,  10,  20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200, 210, 220, 230, 240, 365 )


label define tfreq17_w 0 "0" 10 "10" 20 "20" 30 "30" 40 "40" 50 "50" 60 "60" 70 "70" 80 "80" 90 "90" 100 "100" 110 "110" 120 "120" 130 "130" 140 "140" 150 "150" 160 "160" 170 "170" 180 "180" 190 "190" 200 "200" 210 "210" 220 "220" 230 "230" 240 "240" 250 "250" 260 "260" 270 "270", modify
label values tfreq17_w tfreq17_w

gen ac5 = 5*ceil(age/5)
gen label = string(ac5-5) + " to " +string(ac5) + " years"
labmask ac5, val(label)

replace ac5 = 75 if ac5 > 75

label define ac5_label 20 "15 to 20 years" 25 "20 to 25 years" 30 "25 to 30 years" 35 "30 to 35 years" 40 "35 to 40 years" 45 "40 to 45 years" ///
50 "45 to 50 years" 55 "50 to 55 years" 60 "55 to 60 years" 65 "60 to 65 years" 70 "65 to 70 years" 75 "" 75 "More than 70"
label values ac5 ac5_label

global ind indexc1 indexc2 indexc3 indexc4 indexc5 indexc6 indexc7 indexc8 indexh6
global age ac5
global demographics fem hci hhs1 hhs2 empc

global avoidances sh_a ga_a g_sh
global t tfreq17_w 
global wtd hemisphere mean_temp_WB hits_covid increase_deaths_sm 
global mask wm_a

foreach m of global demographics{
preserve

bysort `m' ac5: gen n_cohort = _N

collapse (mean) $ind $avoidances $wtd $mask tfreq17_m tfreq17 tfreq17_m_o  age n_cohort, by(country_enc $t `m' ac5) 

egen id_pseudo = group(`m' ac5 country_enc)

label values tfreq17_m tfreq17_m

summ tfreq17 if tfreq17>0 & tfreq17_m_o <=7, detail
global mean = r(p50)
gen tfreq17_c = tfreq17 - $mean
gen tfreq17_c2 = tfreq17_c*tfreq17_c

gen acr = .
replace acr = 1 if ac5 <= 30
replace acr = 2 if ac5 <= 45 & acr==.
replace acr = 3 if ac5 <= 60 & acr==.
replace acr = 4 if ac5 > 60 & ac5!=.
label define acr 1"up to 30 years" 2"from 30 to 45 years" 3"from 45 to 60 years" 4"60 years or more"
label values acr acr

save "$path\Yougov_pseudo_panel_`m'.dta", replace
restore

}
*

use "$path\Yougov_pseudo_panel_fem.dta", clear
save "$path\Yougov_pseudo_panel_acr.dta", replace

****************************
* Collapsed data - overall *
****************************

use "$path\Dataset_YouGov_Tracker_processed.dta", clear
set more off

gen tfreq17_day = tfreq17*30

*egen tfreq17_w = cut(tfreq17_day), at(0, 7, 14, 21, 28, 35, 42, 49, 56, 63, 70, 77, 84, 91, 98, 105, 112, 119, 126, 133, 140, 147, 154, 161, 168, 175, 182, 189)

*egen tfreq17_w = cut(tfreq17_day), at(0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100, 105, 110, 115, 120, 125, 135, 145, 150, 155, )

egen tfreq17_w = cut(tfreq17_day), at(0,  10,  20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200, 210, 220, 230, 240, 365 )


label define tfreq17_w 0 "0" 10 "10" 20 "20" 30 "30" 40 "40" 50 "50" 60 "60" 70 "70" 80 "80" 90 "90" 100 "100" 110 "110" 120 "120" 130 "130" 140 "140" 150 "150" 160 "160" 170 "170" 180 "180" 190 "190" 200 "200" 210 "210" 220 "220" 230 "230" 240 "240" 250 "250" 260 "260" 270 "270", modify
label values tfreq17_w tfreq17_w

gen ac5 = 5*ceil(age/5)
gen label = string(ac5-5) + " to " +string(ac5) + " years"
labmask ac5, val(label)

replace ac5 = 75 if ac5 > 75

label define ac5_label 20 "15 to 20 years" 25 "20 to 25 years" 30 "25 to 30 years" 35 "30 to 35 years" 40 "35 to 40 years" 45 "40 to 45 years" ///
50 "45 to 50 years" 55 "50 to 55 years" 60 "55 to 60 years" 65 "60 to 65 years" 70 "65 to 70 years" 75 "" 75 "More than 70"
label values ac5 ac5_label

global ind indexc1 indexc2 indexc3 indexc4 indexc5 indexc6 indexc7 indexc8 indexh6
global age ac5
global demographics fem hci hhs1 hhs2 empc

global avoidances sh_a ga_a g_sh
global t tfreq17_w 
global wtd hemisphere mean_temp_WB hits_covid  increase_deaths_sm 
global mask wm_a



collapse (mean) $ind $avoidances $wtd $mask tfreq17_m tfreq17 tfreq17_m_o age, by(country_enc $t) 

label values tfreq17_m tfreq17_m

summ tfreq17 if tfreq17>0 & tfreq17_m_o <=7, detail
global mean = r(p50)
gen tfreq17_c = tfreq17 - $mean
gen tfreq17_c2 = tfreq17_c*tfreq17_c

save "$path\Yougov_pseudo_panel_main.dta", replace
