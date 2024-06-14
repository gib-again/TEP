
cd "C:\Users\Gib99\Documents\Unam\TEP.\Base de datos"
ssc install outreg2
ssc install reghdfe
ssc install xttest3


/*////////////// Sección ingreso medio per cápita ////////////////

///// Importación de las bases de datos y preparación ////////
import excel "PIB/ICTP 2010.xlsx", sheet ("Hoja1") firstrow clear
rename (ICTPC Clavedemunicipio)  (ICTP2010 clvmun),  replace
save "PIB/ICTP2010.dta", replace

import excel "PIB/ICTP 2015.xlsx", sheet ("Hoja1") firstrow clear
rename (ICTPC Clavedemunicipio)  (ICTP2015 clvmun),  replace
save "PIB/ICTP2015.dta", replace

import excel "PIB/ICTP 2020.xlsx", sheet ("Hoja1") firstrow clear 
rename (Ingresocorrientetotalpercápi Clavedemunicipio)  (ICTP2020 clvmun),  replace
replace ICTP2020 = "" if ICTP2020 == "n.d."
destring ICTP2020, replace
save "PIB/ICTP2020.dta", replace

/// Combinación 

use "PIB/ICTP2020.dta", clear
merge 1:1 clvmun using "PIB/ICTP2015.dta"
drop _merge
merge 1:1 clvmun using "PIB/ICTP2010.dta"
drop _merge Clavedeentidad

// Procesamiento de base ///
reshape long ICTP, i(clvmun) j(year)
expand 5 if (year == 2010 | year == 2015) , generate (new)
expand 4 if (year == 2020) , generate (_new)
replace new = 1 if _new == 1
drop _new
sort clvmun year new 
replace year = year[_n-1]+1 if new == 1
replace ICTP = . if new == 1

/////// Interpolación /////
by clvmun: ipolate ICTP year, generate(_ICTP) epolate
drop ICTP new
rename  _ICTP ICTP , replace


 generate cve_ent = substr(clvmun, 1, 2)
 generate cve_mun = substr(clvmun, 3, 3)
//save "PIB/ICTP2010_2020.dta", replace
 keep if (year >= 2013 & year <=2023)
 save "PIB/ICTP2013_2023.dta", replace

*/

///////////////////// Sección población municipal ////////////

/*/Estandarización del formato 


import delimited "Poblacion\Pob 2010.csv", varnames(1) clear
drop if clvmun == "" | (length(clvmun) < 5 | length(clvmun) > 10)
drop hombre mujer
destring total, replace ignore(",")
generate year = 2010
save "Poblacion\Pob2010.dta", replace

	//Hay manipulación previa en RStudio 
use "Poblacion\Pob2015_2030.dta", clear
sort clvmun year
save "Poblacion\Pob2015_2030.dta", replace

 // Combinación de bases 
 append using "Poblacion\Pob2010.dta"
 sort clvmun year
 expand 5 if (year == 2010) , generate (new)
 sort clvmun year new
 replace year = year[_n-1]+1 if new == 1
 replace total = . if new == 1
 
 // Interpolación
 by clvmun: ipolate total year, generate(_total)
 drop total new
 rename  _total poblacion , replace
 
 generate cve_ent = substr(clvmun, 1, 2)
 generate cve_mun = substr(clvmun, 3, 3)
 
 drop (ID_ENTIDAD ID_MUNICIPIO)
 //save "Poblacion\Pob2010_2030.dta", replace
 
 keep if (year >= 2013 & year <=2023)
 save "Poblacion\Pob2013_2023.dta", replace
 
 */
 
 
 ////////// Sección Corrupción y percepción de calidad /////////////////
 
 // 2013 // 
 import dbase "ENCIG\encig13\Encig2013_01.DBF", clear
 sort ENT CON V_SEL N_HOG R_ELE
 generate pob_18 = 1
 gen clvmun = ENT+MUN
 
 destring P4_1A P4_2A P4_3A P4_4A P4_5A P4_1B P4_2B P4_3B P4_4B P4_5B P3_2 P3_3_8 FAC_P18, replace
  
 // Generación de variable dummy en casos de corrupción frecuente o muy frecuente en Estado
 generate I3_2 = 0
 replace I3_2 = 1 if (P3_2 == 1 | P3_2 == 2)
 replace P3_2 = . if P3_2 == 9
 // Generación de variable dummy en casos de corrupción frecuente o muy frecuente en Municipio
 generate I3_3_8 = 0
 replace I3_3_8 = 1 if (P3_3_8 == 1 | P3_3_8 == 2)
 replace P3_3_8 = . if (P3_3_8 == 9)
 
 // Generacion de variable dummy en casos de estar satisfecho o muy satisfecho con los servicios públicos de la ciudad
 gen I4_1A = 1 if (P4_1A >= 1 & P4_1A <= 2)
 gen I4_2A = 1 if (P4_2A >= 1 & P4_2A <= 2)
 gen I4_3A = 1 if (P4_3A >= 1 & P4_3A <= 2)
 gen I4_4A = 1 if (P4_4A >= 1 & P4_4A <= 2)
 gen I4_5A = 1 if (P4_5A >= 1 & P4_5A <= 2)
 
 // Eliminación de preguntas no respondidas
 replace P4_1A = . if (P4_1A == 9)
 replace P4_2A = . if (P4_2A == 9)
 replace P4_3A = . if (P4_3A == 9)
 replace P4_4A = . if (P4_4A == 9)
 replace P4_5A = . if (P4_5A == 9)
 
 // Generacion de variable dummy con total de calificaiones emitidas
 gen I4_1B = 1 if (P4_1B >= 1 & P4_1B <= 10)
 gen I4_2B = 1 if (P4_2B >= 1 & P4_2B <= 10)
 gen I4_3B = 1 if (P4_3B >= 1 & P4_3B <= 10)
 gen I4_4B = 1 if (P4_4B >= 1 & P4_4B <= 10)
 gen I4_5B = 1 if (P4_5B >= 1 & P4_5B <= 10)
 
 // Eliminación de calificaciones no emitidas
 replace P4_1B = . if (P4_1B > 11)
 replace P4_2B = . if (P4_2B > 11)
 replace P4_3B = . if (P4_3B > 11)
 replace P4_4B = . if (P4_4B > 11)
 replace P4_5B = . if (P4_5B > 11)
 
 // Elimienación de opiniones no emitidas
 replace P4_1A = . if (P4_1A > 7)
 replace P4_2A = . if (P4_2A > 7)
 replace P4_3A = . if (P4_3A > 7)
 replace P4_4A = . if (P4_4A > 7)
 replace P4_5A = . if (P4_5A > 7)
 
	//Abrimos la base de datos auxiliar las estimaciones que ehmos obtenido	
	/*///////// Pruebas de hipotesis a nivel municipal  //////////
	*Usamos como unidad primaria de muestreo el upm y el tamaño de localidad como el estrato
	svyset UPM [pw=FAC_P18], strata(EST) singleunit(certainty) vce(linearized)
	svyset UPM [pw=FAC_P18], strata(EST) vce(linearized)

	
	*Sin desagregación
	qui svy, over(ENT): mean P4_1B P4_2B P4_3B P4_4B P4_5B
	estat cv
	putexcel set `filename_save_gen', replace
	matrix b = r(cv)'
	putexcel A1 = "Indice"
	putexcel B1 = "CV"
	putexcel A2 = matrix(b), rownames  nformat(number_d2)
 */
 
 // Multiplicación por factores de expansión
 collapse (sum) pob_18 I4_1A I4_2A I4_3A I4_4A I4_5A I4_1B I4_2B I4_3B I4_4B I4_5B P4_1B P4_2B P4_3B P4_4B P4_5B I3_2 I3_3_8 (count) P4_1A P4_2A P4_3A P4_4A P4_5A P3_2 P3_3_8 [fweight = FAC_P18], by (ENT MUN) 
 
 //Generacion de calificaciones medias a nivel municipio
 gen P4_1 = (P4_1B/I4_1B)
 gen P4_3 = (P4_2B/I4_2B)
 gen P4_4 = (P4_3B/I4_3B)
 gen P4_5 = (P4_4B/I4_4B)
 gen P4_6 = (P4_5B/I4_5B)
 
  //Generación de porcentajes de satisfacción a nivel municipio
 gen P4_1a = (I4_1A/P4_1A)*100
 gen P4_2a = (I4_2A/P4_2A)*100
 gen P4_3a = (I4_3A/P4_3A)*100
 gen P4_4a = (I4_4A/P4_4A)*100
 gen P4_5a = (I4_5A/P4_5A)*100
 
 // Generacion de porcentaje de población insatisfecha con servicios
 gen P3_X = ((I3_2 + I3_3_8)/ (P3_2 + P3_3_8)*100)
 gen P4_X = ((I4_1A + I4_2A + I4_3A + I4_4A + I4_5A) / (P4_1A + P4_2A + P4_3A + P4_4A + P4_5A)) *100
 
 gen aP3_2 = (I3_2/P3_2)*100
 gen aP3_3_8 = (I3_3_8/P3_3_8)*100
 
 drop P3_2 P3_3_8 P4_1A P4_2A P4_3A P4_4A P4_5A P4_1B P4_2B P4_3B P4_4B P4_5B I4_1A I4_2A I4_3A I4_4A I4_5A I4_1B I4_2B I4_3B I4_4B I4_5B I3_2 I3_3_8 pob_18
 rename (aP3_2 aP3_3_8) (P3_2 P3_3_8)
 generate year = 2013
 
 save "ENCIG/T2013.dta", replace
 
 
 
 // 2015 // 
 import dbase "ENCIG\encig15\Encig2015_01.DBF", clear
 sort ENT UPM V_SEL
 generate pob_18 = 1
 destring P4_1A P4_2A P4_3A P4_4A P4_5A P4_6A P4_1B P4_2B P4_3B P4_4B P4_5B P4_6B P3_2 P3_3_8 FAC_P18, replace
  
 // Generación de variable dummy en casos de corrupción frecuente o muy frecuente en Estado
 generate I3_2 = 0
 replace I3_2 = 1 if (P3_2 == 1 | P3_2 == 2)
 replace P3_2 = . if P3_2 == 9
 // Generación de variable dummy en casos de corrupción frecuente o muy frecuente en Municipio
 generate I3_3_8 = 0
 replace I3_3_8 = 1 if (P3_3_8 == 1 | P3_3_8 == 2)
 replace P3_3_8 = . if (P3_3_8 == 9)
 
 // Generacion de variable dummy en casos de estar satisfecho o muy satisfecho con los servicios públicos de la ciudad
 gen I4_1A = 1 if (P4_1A >= 1 & P4_1A <= 2)
 gen I4_2A = 1 if (P4_2A >= 1 & P4_2A <= 2)
 gen I4_3A = 1 if (P4_3A >= 1 & P4_3A <= 2)
 gen I4_4A = 1 if (P4_4A >= 1 & P4_4A <= 2)
 gen I4_5A = 1 if (P4_5A >= 1 & P4_5A <= 2)
 gen I4_6A = 1 if (P4_6A >= 1 & P4_6A <= 2)
 
 // Eliminación de preguntas no respondidas
 replace P4_1A = . if (P4_1A == 9)
 replace P4_2A = . if (P4_2A == 9)
 replace P4_3A = . if (P4_3A == 9)
 replace P4_4A = . if (P4_4A == 9)
 replace P4_5A = . if (P4_5A == 9)
 replace P4_6A = . if (P4_6A == 9)
 
 // Generacion de variable dummy con total de calificaiones emitidas
 gen I4_1B = 1 if (P4_1B >= 1 & P4_1B <= 10)
 gen I4_2B = 1 if (P4_2B >= 1 & P4_2B <= 10)
 gen I4_3B = 1 if (P4_3B >= 1 & P4_3B <= 10)
 gen I4_4B = 1 if (P4_4B >= 1 & P4_4B <= 10)
 gen I4_5B = 1 if (P4_5B >= 1 & P4_5B <= 10)
 gen I4_6B = 1 if (P4_6B >= 1 & P4_6B <= 10)
 
 // Eliminación de calificaciones no emitidas
 replace P4_1B = . if (P4_1B > 11)
 replace P4_2B = . if (P4_2B > 11)
 replace P4_3B = . if (P4_3B > 11)
 replace P4_4B = . if (P4_4B > 11)
 replace P4_5B = . if (P4_5B > 11)
 replace P4_6B = . if (P4_6B > 11)
 
 
 // Multiplicación por factores de expansión
  collapse (sum) pob_18 I4_1A I4_2A I4_3A I4_4A I4_5A I4_6A I4_1B I4_2B I4_3B I4_4B I4_5B I4_6B P4_1B P4_2B P4_3B P4_4B P4_5B P4_6B I3_2 I3_3_8 (count) P4_1A P4_2A P4_3A P4_4A P4_5A P4_6A P3_2 P3_3_8 [fweight = FAC_P18], by (ENT MUN) 

//Generacion de calificaciones medias a nivel municipio
 gen P4_1 = (P4_1B/I4_1B)
 gen P4_2 = (P4_2B/I4_2B)
 gen P4_3 = (P4_3B/I4_3B)
 gen P4_4 = (P4_4B/I4_4B)
 gen P4_5 = (P4_5B/I4_5B)
 gen P4_6 = (P4_6B/I4_6B)
 
 //Generación de porcentajes de satisfacción a nivel municipio
 gen P4_1a = (I4_1A/P4_1A)*100
 gen P4_2a = (I4_2A/P4_2A)*100
 gen P4_3a = (I4_3A/P4_3A)*100
 gen P4_4a = (I4_4A/P4_4A)*100
 gen P4_5a = (I4_5A/P4_5A)*100
 gen P4_6a = (I4_6A/P4_6A)*100
 
 // Generacion de porcentaje de población insatisfecha con servicios
 gen P3_X = ((I3_2 + I3_3_8)/ (P3_2 + P3_3_8)*100)
 gen P4_X = ((I4_1A + I4_2A + I4_3A + I4_4A + I4_5A + I4_6A) / (P4_1A + P4_2A + P4_3A + P4_4A + P4_5A + P4_6A)) *100
 
 gen aP3_2 = (I3_2/P3_2)*100
 gen aP3_3_8 = (I3_3_8/P3_3_8)*100
 
 drop P3_2 P3_3_8 P4_1A P4_2A P4_3A P4_4A P4_5A P4_6A P4_1B P4_2B P4_3B P4_4B P4_5B P4_6B I4_1A I4_2A I4_3A I4_4A I4_5A I4_6A I4_1B I4_2B I4_3B I4_4B I4_5B I4_6B I3_2 I3_3_8 pob_18
 rename (aP3_2 aP3_3_8) (P3_2 P3_3_8)
 
 generate year = 2015
 
 save "ENCIG/T2015.dta", replace
 
 
 // 2017 // 
 import dbase "ENCIG\encig17\Encig2017_01.dbf", clear
 sort ENT UPM V_SEL
 generate pob_18 = 1
 destring P4_1A P4_2A P4_3A P4_4A P4_5A P4_6A P4_1B P4_2B P4_3B P4_4B P4_5B P4_6B P3_2 P3_3_8 FAC_P18, replace
  
 // Generación de variable dummy en casos de corrupción frecuente o muy frecuente en Estado
 generate I3_2 = 0
 replace I3_2 = 1 if (P3_2 == 1 | P3_2 == 2)
 replace P3_2 = . if P3_2 == 9
 // Generación de variable dummy en casos de corrupción frecuente o muy frecuente en Municipio
 generate I3_3_8 = 0
 replace I3_3_8 = 1 if (P3_3_8 == 1 | P3_3_8 == 2)
 replace P3_3_8 = . if (P3_3_8 == 9)
 
 // Generacion de variable dummy en casos de estar insatisfecho o muy insatisfecho con los servicios públicos de la ciudad
  gen I4_1A = 1 if (P4_1A >= 1 & P4_1A <= 2)
 gen I4_2A = 1 if (P4_2A >= 1 & P4_2A <= 2)
 gen I4_3A = 1 if (P4_3A >= 1 & P4_3A <= 2)
 gen I4_4A = 1 if (P4_4A >= 1 & P4_4A <= 2)
 gen I4_5A = 1 if (P4_5A >= 1 & P4_5A <= 2)
 gen I4_6A = 1 if (P4_6A >= 1 & P4_6A <= 2)
 
 // Eliminación de preguntas no respondidas
 replace P4_1A = . if (P4_1A == 9)
 replace P4_2A = . if (P4_2A == 9)
 replace P4_3A = . if (P4_3A == 9)
 replace P4_4A = . if (P4_4A == 9)
 replace P4_5A = . if (P4_5A == 9)
 replace P4_6A = . if (P4_6A == 9)
 
 // Generacion de variable dummy con total de calificaiones emitidas
 gen I4_1B = 1 if (P4_1B >= 1 & P4_1B <= 10)
 gen I4_2B = 1 if (P4_2B >= 1 & P4_2B <= 10)
 gen I4_3B = 1 if (P4_3B >= 1 & P4_3B <= 10)
 gen I4_4B = 1 if (P4_4B >= 1 & P4_4B <= 10)
 gen I4_5B = 1 if (P4_5B >= 1 & P4_5B <= 10)
 gen I4_6B = 1 if (P4_6B >= 1 & P4_6B <= 10)
 
 // Eliminación de calificaciones no emitidas
 replace P4_1B = . if (P4_1B > 11)
 replace P4_2B = . if (P4_2B > 11)
 replace P4_3B = . if (P4_3B > 11)
 replace P4_4B = . if (P4_4B > 11)
 replace P4_5B = . if (P4_5B > 11)
 replace P4_6B = . if (P4_6B > 11)
 
 // Multiplicación por factores de expansión
  collapse (sum) pob_18 I4_1A I4_2A I4_3A I4_4A I4_5A I4_6A I4_1B I4_2B I4_3B I4_4B I4_5B I4_6B P4_1B P4_2B P4_3B P4_4B P4_5B P4_6B I3_2 I3_3_8 (count) P4_1A P4_2A P4_3A P4_4A P4_5A P4_6A P3_2 P3_3_8 [fweight = FAC_P18], by (ENT MUN) 

//Generacion de calificaciones medias a nivel municipio
 gen P4_1 = (P4_1B/I4_1B)
 gen P4_2 = (P4_2B/I4_2B)
 gen P4_3 = (P4_3B/I4_3B)
 gen P4_4 = (P4_4B/I4_4B)
 gen P4_5 = (P4_5B/I4_5B)
 gen P4_6 = (P4_6B/I4_6B)
 
  //Generación de porcentajes de satisfacción a nivel municipio
 gen P4_1a = (I4_1A/P4_1A)*100
 gen P4_2a = (I4_2A/P4_2A)*100
 gen P4_3a = (I4_3A/P4_3A)*100
 gen P4_4a = (I4_4A/P4_4A)*100
 gen P4_5a = (I4_5A/P4_5A)*100
 gen P4_6a = (I4_6A/P4_6A)*100
 
 // Generacion de porcentaje de población insatisfecha con servicios
 gen P3_X = ((I3_2 + I3_3_8)/ (P3_2 + P3_3_8)*100)
 gen P4_X = ((I4_1A + I4_2A + I4_3A + I4_4A + I4_5A + I4_6A) / (P4_1A + P4_2A + P4_3A + P4_4A + P4_5A + P4_6A)) *100
 
 gen aP3_2 = (I3_2/P3_2)*100
 gen aP3_3_8 = (I3_3_8/P3_3_8)*100
 
 drop P3_2 P3_3_8 P4_1A P4_2A P4_3A P4_4A P4_5A P4_6A P4_1B P4_2B P4_3B P4_4B P4_5B P4_6B I4_1A I4_2A I4_3A I4_4A I4_5A I4_6A I4_1B I4_2B I4_3B I4_4B I4_5B I4_6B I3_2 I3_3_8 pob_18
 rename (aP3_2 aP3_3_8) (P3_2 P3_3_8)
 
 generate year = 2017
 
 save "ENCIG/T2017.dta", replace
 
  // 2019 // 
 import dbase "ENCIG\encig19\Encig2019_01.dbf", clear
 sort ENT UPM V_SEL
 generate pob_18 = 1
destring P4_1A P4_2A P4_3A P4_4A P4_5A P4_6A P4_1B P4_2B P4_3B P4_4B P4_5B P4_6B P3_2 P3_3_8 FAC_P18, replace
  
 // Generación de variable dummy en casos de corrupción frecuente o muy frecuente en Estado
 generate I3_2 = 0
 replace I3_2 = 1 if (P3_2 == 1 | P3_2 == 2)
 replace P3_2 = . if P3_2 == 9
 // Generación de variable dummy en casos de corrupción frecuente o muy frecuente en Municipio
 generate I3_3_8 = 0
 replace I3_3_8 = 1 if (P3_3_8 == 1 | P3_3_8 == 2)
 replace P3_3_8 = . if (P3_3_8 == 9)
 
 // Generacion de variable dummy en casos de estar insatisfecho o muy insatisfecho con los servicios públicos de la ciudad
 gen I4_1A = 1 if (P4_1A >= 1 & P4_1A <= 2)
 gen I4_2A = 1 if (P4_2A >= 1 & P4_2A <= 2)
 gen I4_3A = 1 if (P4_3A >= 1 & P4_3A <= 2)
 gen I4_4A = 1 if (P4_4A >= 1 & P4_4A <= 2)
 gen I4_5A = 1 if (P4_5A >= 1 & P4_5A <= 2)
 gen I4_6A = 1 if (P4_6A >= 1 & P4_6A <= 2)
 
 // Eliminación de preguntas no respondidas
 replace P4_1A = . if (P4_1A == 9)
 replace P4_2A = . if (P4_2A == 9)
 replace P4_3A = . if (P4_3A == 9)
 replace P4_4A = . if (P4_4A == 9)
 replace P4_5A = . if (P4_5A == 9)
 replace P4_6A = . if (P4_6A == 9)
 
 // Generacion de variable dummy con total de calificaiones emitidas
 gen I4_1B = 1 if (P4_1B >= 1 & P4_1B <= 10)
 gen I4_2B = 1 if (P4_2B >= 1 & P4_2B <= 10)
 gen I4_3B = 1 if (P4_3B >= 1 & P4_3B <= 10)
 gen I4_4B = 1 if (P4_4B >= 1 & P4_4B <= 10)
 gen I4_5B = 1 if (P4_5B >= 1 & P4_5B <= 10)
 gen I4_6B = 1 if (P4_6B >= 1 & P4_6B <= 10)
 
 // Eliminación de calificaciones no emitidas
 replace P4_1B = . if (P4_1B > 11)
 replace P4_2B = . if (P4_2B > 11)
 replace P4_3B = . if (P4_3B > 11)
 replace P4_4B = . if (P4_4B > 11)
 replace P4_5B = . if (P4_5B > 11)
 replace P4_6B = . if (P4_6B > 11)
 
 // Multiplicación por factores de expansión
  collapse (sum) pob_18 I4_1A I4_2A I4_3A I4_4A I4_5A I4_6A I4_1B I4_2B I4_3B I4_4B I4_5B I4_6B P4_1B P4_2B P4_3B P4_4B P4_5B P4_6B I3_2 I3_3_8 (count) P4_1A P4_2A P4_3A P4_4A P4_5A P4_6A P3_2 P3_3_8 [fweight = FAC_P18], by (ENT MUN) 

//Generacion de calificaciones medias a nivel municipio
 gen P4_1 = (P4_1B/I4_1B)
 gen P4_2 = (P4_2B/I4_2B)
 gen P4_3 = (P4_3B/I4_3B)
 gen P4_4 = (P4_4B/I4_4B)
 gen P4_5 = (P4_5B/I4_5B)
 gen P4_6 = (P4_6B/I4_6B)
 
  //Generación de porcentajes de satisfacción a nivel municipio
 gen P4_1a = (I4_1A/P4_1A)*100
 gen P4_2a = (I4_2A/P4_2A)*100
 gen P4_3a = (I4_3A/P4_3A)*100
 gen P4_4a = (I4_4A/P4_4A)*100
 gen P4_5a = (I4_5A/P4_5A)*100
 gen P4_6a = (I4_6A/P4_6A)*100
 
 // Generacion de porcentaje de población insatisfecha con servicios
 gen P3_X = ((I3_2 + I3_3_8)/ (P3_2 + P3_3_8)*100)
 gen P4_X = ((I4_1A + I4_2A + I4_3A + I4_4A + I4_5A + I4_6A) / (P4_1A + P4_2A + P4_3A + P4_4A + P4_5A + P4_6A)) *100
 
 gen aP3_2 = (I3_2/P3_2)*100
 gen aP3_3_8 = (I3_3_8/P3_3_8)*100
 
 drop P3_2 P3_3_8 P4_1A P4_2A P4_3A P4_4A P4_5A P4_6A P4_1B P4_2B P4_3B P4_4B P4_5B P4_6B I4_1A I4_2A I4_3A I4_4A I4_5A I4_6A I4_1B I4_2B I4_3B I4_4B I4_5B I4_6B I3_2 I3_3_8 pob_18
 rename (aP3_2 aP3_3_8) (P3_2 P3_3_8)
 
 generate year = 2019
 
 save "ENCIG/T2019.dta", replace
 
 
 
   // 2021 // 
 import dbase "ENCIG\encig21\Encig2021_01.dbf", clear
 sort ENT UPM V_SEL
 generate pob_18 = 1
 destring P4_1A P4_2A P4_3A P4_4A P4_5A P4_6A P4_1B P4_2B P4_3B P4_4B P4_5B P4_6B P3_2 P3_3_8 FAC_P18, replace
  
 // Generación de variable dummy en casos de corrupción frecuente o muy frecuente en Estado
 generate I3_2 = 0
 replace I3_2 = 1 if (P3_2 == 1 | P3_2 == 2)
 replace P3_2 = . if P3_2 == 9
 // Generación de variable dummy en casos de corrupción frecuente o muy frecuente en Municipio
 generate I3_3_8 = 0
 replace I3_3_8 = 1 if (P3_3_8 == 1 | P3_3_8 == 2)
 replace P3_3_8 = . if (P3_3_8 == 9)
 
 // Generacion de variable dummy en casos de estar insatisfecho o muy insatisfecho con los servicios públicos de la ciudad
 gen I4_1A = 1 if (P4_1A >= 1 & P4_1A <= 2)
 gen I4_2A = 1 if (P4_2A >= 1 & P4_2A <= 2)
 gen I4_3A = 1 if (P4_3A >= 1 & P4_3A <= 2)
 gen I4_4A = 1 if (P4_4A >= 1 & P4_4A <= 2)
 gen I4_5A = 1 if (P4_5A >= 1 & P4_5A <= 2)
 gen I4_6A = 1 if (P4_6A >= 1 & P4_6A <= 2)
 
 // Eliminación de preguntas no respondidas
 replace P4_1A = . if (P4_1A == 9)
 replace P4_2A = . if (P4_2A == 9)
 replace P4_3A = . if (P4_3A == 9)
 replace P4_4A = . if (P4_4A == 9)
 replace P4_5A = . if (P4_5A == 9)
 replace P4_6A = . if (P4_6A == 9)
 
 // Generacion de variable dummy con total de calificaiones emitidas
 gen I4_1B = 1 if (P4_1B >= 1 & P4_1B <= 10)
 gen I4_2B = 1 if (P4_2B >= 1 & P4_2B <= 10)
 gen I4_3B = 1 if (P4_3B >= 1 & P4_3B <= 10)
 gen I4_4B = 1 if (P4_4B >= 1 & P4_4B <= 10)
 gen I4_5B = 1 if (P4_5B >= 1 & P4_5B <= 10)
 gen I4_6B = 1 if (P4_6B >= 1 & P4_6B <= 10)
 
 // Eliminación de calificaciones no emitidas
 replace P4_1B = . if (P4_1B > 11)
 replace P4_2B = . if (P4_2B > 11)
 replace P4_3B = . if (P4_3B > 11)
 replace P4_4B = . if (P4_4B > 11)
 replace P4_5B = . if (P4_5B > 11)
 replace P4_6B = . if (P4_6B > 11)
 
 // Multiplicación por factores de expansión
  collapse (sum) pob_18 I4_1A I4_2A I4_3A I4_4A I4_5A I4_6A I4_1B I4_2B I4_3B I4_4B I4_5B I4_6B P4_1B P4_2B P4_3B P4_4B P4_5B P4_6B I3_2 I3_3_8 (count) P4_1A P4_2A P4_3A P4_4A P4_5A P4_6A P3_2 P3_3_8 [fweight = FAC_P18], by (ENT MUN) 

//Generacion de calificaciones medias a nivel municipio
 gen P4_1 = (P4_1B/I4_1B)
 gen P4_2 = (P4_2B/I4_2B)
 gen P4_3 = (P4_3B/I4_3B)
 gen P4_4 = (P4_4B/I4_4B)
 gen P4_5 = (P4_5B/I4_5B)
 gen P4_6 = (P4_6B/I4_6B)
 
  //Generación de porcentajes de satisfacción a nivel municipio
 gen P4_1a = (I4_1A/P4_1A)*100
 gen P4_2a = (I4_2A/P4_2A)*100
 gen P4_3a = (I4_3A/P4_3A)*100
 gen P4_4a = (I4_4A/P4_4A)*100
 gen P4_5a = (I4_5A/P4_5A)*100
 gen P4_6a = (I4_6A/P4_6A)*100
 
 // Generacion de porcentaje de población insatisfecha con servicios
 gen P3_X = ((I3_2 + I3_3_8)/ (P3_2 + P3_3_8)*100)
 gen P4_X = ((I4_1A + I4_2A + I4_3A + I4_4A + I4_5A + I4_6A) / (P4_1A + P4_2A + P4_3A + P4_4A + P4_5A + P4_6A)) *100
 
 gen aP3_2 = (I3_2/P3_2)*100
 gen aP3_3_8 = (I3_3_8/P3_3_8)*100
 
 drop P3_2 P3_3_8 P4_1A P4_2A P4_3A P4_4A P4_5A P4_6A P4_1B P4_2B P4_3B P4_4B P4_5B P4_6B I4_1A I4_2A I4_3A I4_4A I4_5A I4_6A I4_1B I4_2B I4_3B I4_4B I4_5B I4_6B I3_2 I3_3_8 pob_18
 rename (aP3_2 aP3_3_8) (P3_2 P3_3_8)
 generate year = 2021
 save "ENCIG/T2021.dta", replace
 
 // 2023 //
 import dbase "ENCIG\encig23\encig2023_01_sec1_A_3_4_5_8_9_10.dbf", clear
 rename (CVE_ENT CVE_MUN) (ENT MUN), rename
 sort ENT UPM V_SEL
 generate pob_18 = 1 
destring P4_1A P4_2A P4_3A P4_4A P4_5A P4_6A P4_1B P4_2B P4_3B P4_4B P4_5B P4_6B P3_2 P3_3_08 FAC_P18, replace
  
 // Generación de variable dummy en casos de corrupción frecuente o muy frecuente en Estado
 generate I3_2 = 0
 replace I3_2 = 1 if (P3_2 == 1 | P3_2 == 2)
 replace P3_2 = . if P3_2 == 9
 // Generación de variable dummy en casos de corrupción frecuente o muy frecuente en Municipio
 generate I3_3_8 = 0
 replace I3_3_8 = 1 if (P3_3_08 == 1 | P3_3_08 == 2)
 replace P3_3_08 = . if (P3_3_08 == 9)
 
 // Generacion de variable dummy en casos de estar insatisfecho o muy insatisfecho con los servicios públicos de la ciudad
 gen I4_1A = 1 if (P4_1A >= 1 & P4_1A <= 2)
 gen I4_2A = 1 if (P4_2A >= 1 & P4_2A <= 2)
 gen I4_3A = 1 if (P4_3A >= 1 & P4_3A <= 2)
 gen I4_4A = 1 if (P4_4A >= 1 & P4_4A <= 2)
 gen I4_5A = 1 if (P4_5A >= 1 & P4_5A <= 2)
 gen I4_6A = 1 if (P4_6A >= 1 & P4_6A <= 2)
 
 // Eliminación de preguntas no respondidas
 replace P4_1A = . if (P4_1A == 9)
 replace P4_2A = . if (P4_2A == 9)
 replace P4_3A = . if (P4_3A == 9)
 replace P4_4A = . if (P4_4A == 9)
 replace P4_5A = . if (P4_5A == 9)
 replace P4_6A = . if (P4_6A == 9)
 
 // Generacion de variable dummy con total de calificaiones emitidas
 gen I4_1B = 1 if (P4_1B >= 1 & P4_1B <= 10)
 gen I4_2B = 1 if (P4_2B >= 1 & P4_2B <= 10)
 gen I4_3B = 1 if (P4_3B >= 1 & P4_3B <= 10)
 gen I4_4B = 1 if (P4_4B >= 1 & P4_4B <= 10)
 gen I4_5B = 1 if (P4_5B >= 1 & P4_5B <= 10)
 gen I4_6B = 1 if (P4_6B >= 1 & P4_6B <= 10)
 
 // Eliminación de calificaciones no emitidas
 replace P4_1B = . if (P4_1B > 11)
 replace P4_2B = . if (P4_2B > 11)
 replace P4_3B = . if (P4_3B > 11)
 replace P4_4B = . if (P4_4B > 11)
 replace P4_5B = . if (P4_5B > 11)
 replace P4_6B = . if (P4_6B > 11)
 
 // Multiplicación por factores de expansión
  collapse (sum) pob_18 I4_1A I4_2A I4_3A I4_4A I4_5A I4_6A I4_1B I4_2B I4_3B I4_4B I4_5B I4_6B P4_1B P4_2B P4_3B P4_4B P4_5B P4_6B I3_2 I3_3_8 (count) P4_1A P4_2A P4_3A P4_4A P4_5A P4_6A P3_2 P3_3_08 [fweight = FAC_P18], by (ENT) 

//Generacion de calificaciones medias a nivel municipio
 gen P4_1 = (P4_1B/I4_1B)
 gen P4_2 = (P4_2B/I4_2B)
 gen P4_3 = (P4_3B/I4_3B)
 gen P4_4 = (P4_4B/I4_4B)
 gen P4_5 = (P4_5B/I4_5B)
 gen P4_6 = (P4_6B/I4_6B)
 
  //Generación de porcentajes de satisfacción a nivel municipio
 gen P4_1a = (I4_1A/P4_1A)*100
 gen P4_2a = (I4_2A/P4_2A)*100
 gen P4_3a = (I4_3A/P4_3A)*100
 gen P4_4a = (I4_4A/P4_4A)*100
 gen P4_5a = (I4_5A/P4_5A)*100
 gen P4_6a = (I4_6A/P4_6A)*100
 
 // Generacion de porcentaje de población insatisfecha con servicios
 gen P3_X = ((I3_2 + I3_3_8)/ (P3_2 + P3_3_08)*100)
 gen P4_X = ((I4_1A + I4_2A + I4_3A + I4_4A + I4_5A + I4_6A) / (P4_1A + P4_2A + P4_3A + P4_4A + P4_5A + P4_6A)) *100
 
 gen aP3_2 = (I3_2/P3_2)*100
 gen aP3_3_8 = (I3_3_8/P3_3_08)*100
 
 drop P3_2 P3_3_08 P4_1A P4_2A P4_3A P4_4A P4_5A P4_6A P4_1B P4_2B P4_3B P4_4B P4_5B P4_6B I4_1A I4_2A I4_3A I4_4A I4_5A I4_6A I4_1B I4_2B I4_3B I4_4B I4_5B I4_6B I3_2 I3_3_8 pob_18
 rename (aP3_2 aP3_3_8) (P3_2 P3_3_8)
 
 generate year = 2023
 
 save "ENCIG/T2023.dta", replace
 
 
 //// Appender 
 use "ENCIG/T2023.dta", clear
 append  using "ENCIG/T2021"
 append using "ENCIG/T2019"
 append using "ENCIG/T2017"
 append using "ENCIG/T2015"
 append using "ENCIG/T2013"
 
 rename (ENT MUN) (cve_ent cve_mun)
 order cve_ent cve_mun year 
 
 sort cve_ent cve_mun year 
 save "ENCIG/T2013_2023", replace
 
 */
 
 /*
 //////// Sección educación /////////////////
 
 // Datos 2020
 import excel "Educacion/RESULTADOS 2020" , sheet("Sheet1") firstrow clear 
 rename (ent mun AP2020) (cve_ent cve_mun escolaridad)
 destring escolaridad, replace
 tostring cve_ent, format("%02.0f") replace 
 tostring cve_mun, format("%03.0f") replace 
 gen year = 2020
 gen clvmun = cve_ent + cve_mun
 keep cve_ent cve_mun clvmun escolaridad year
 save "Educacion/RESULTADOS 2020.dta", replace
 
 // Datos 2015
 import delimited "Educacion/RESULTADOS 2015.csv", clear
 rename (ent mun anios) (cve_ent cve_mun escolaridad)
 tostring cve_ent, format("%02.0f") replace 
 tostring cve_mun, format("%03.0f") replace 
 gen clvmun = cve_ent + cve_mun
 keep cve_ent cve_mun clvmun escolaridad year
 save "Educacion/RESULTADOS 2015.dta", replace
 
 // Datos 2010
 import delimited "Educacion/RESULTADOS 2010.csv", clear
 rename (ent mun anios) (cve_ent cve_mun escolaridad)
 tostring cve_ent, format("%02.0f") replace 
 tostring cve_mun, format("%03.0f") replace 
 gen clvmun = cve_ent + cve_mun
 keep cve_ent cve_mun clvmun escolaridad year
 save "Educacion/RESULTADOS 2010.dta", replace
 
	/* // Creador de base en formato wide
	 merge 1:1 cve_ent cve_mun using "Educacion/RESULTADOS 2015.dta"
	 drop _merge
	 merge 1:1 cve_ent cve_mun using "Educacion/RESULTADOS 2020.dta"
	 drop year 
	 order cve_ent cve_mun clvmun escolaridad10 escolaridad15 escolaridad20 
	 save "Educacion/RESULTADOS_wide.dta", replace
	 */

 append using "Educacion/RESULTADOS 2015.dta"
 append using "Educacion/RESULTADOS 2020.dta"
 
 // Interpolación de datos
	expand 5 if (year == 2010 | year == 2015) , generate (new)
	expand 4 if (year == 2020) , generate (_new)
	replace new = 1 if _new == 1
	drop _new
	sort clvmun year new 
	replace year = year[_n-1]+1 if new == 1
	replace escolaridad = . if new == 1

/////// Interpolación /////
	by clvmun: ipolate escolaridad year, generate(_escolaridad) epolate
	drop escolaridad new
	rename  _escolaridad escolaridad , replace
	replace escolaridad = escolaridad[_n-1] if missing(escolaridad) & year >= 2021
	
	// Acotación y guardado
 keep if (year >= 2013 & year <=2023)
 
 save "Educacion/ESCOLARIDAD_13_23.dta", replace
 
 */
 /*
 ////// Sección zonas metropolitanas ///////////
 
 import delimited "Poblacion/ZM_2015.csv", clear
 tostring cve_ent, format("%02.0f") replace 
 tostring cve_mun, format("%03.0f") replace 
 tostring clvmun, format("%05.0f") replace 
 save "Poblacion/ZM_2015.dta", replace

 */ 
 
 /*//// Deflactor ///////////////7
 import delimited "PIB/IPC.csv", clear
 keep if (year >= 2013 & year <=2023) 
 save "PIB/IPC.dta", replace
 */
 
 ///////////// Unificación de las bases de datos //////////////////
 
 import delimited "Predial\Transparencia.csv", clear
 tostring cve_ent, format("%02.0f") replace 
 tostring cve_mun, format("%03.0f") replace 

 //Correción de datos en base transparencia
 replace monto_predial = "" if (monto_predial == "No disponible " | monto_predial == "No disponible")
 replace cuentas_pagadas = "" if (cuentas_pagadas == "No disponible " | cuentas_pagadas == "No disponible")
 destring (cuentas_pagadas monto_predial), replace
 
 // Unión con bases de datos adicionales
 merge m:m cve_ent cve_mun year using "PIB/ICTP2013_2023.dta"
 drop _merge Entidadfederativa Municipio
 merge m:m cve_ent cve_mun year using "Poblacion\Pob2013_2023.dta"
 drop _merge
 merge m:m cve_ent cve_mun year using "Predial/efipem13_22.dta"
 drop _merge
 merge m:m cve_ent cve_mun year using "ENCIG/T2013_2023.dta"
 drop _merge
 merge m:m cve_ent cve_mun using "Poblacion/ZM_2015.dta"
 drop _merge
 merge m:m cve_ent cve_mun using "Educacion/ESCOLARIDAD_10_20.dta"
 drop _merge
 merge m:m year using "PIB/IPC.dta"
 
 //Se usarán cifras 2022 para 2023 debido a la falta de siponibilidad de información financiera para 2023
 drop if clvmun == "" 
 sort clvmun year 
 
 by clvmun: replace monto_predial = monto_predial[_n-1] if missing(monto_predial) & year >= 2022
 by clvmun: replace cuentas_pagadas = cuentas_pagadas[_n-1] if missing(cuentas_pagadas) & year >= 2022
 by clvmun: replace Impuesto_predial_efipem = Impuesto_predial_efipem[_n-1] if missing(Impuesto_predial_efipem) & year >= 2022
 by clvmun: replace Participaciones_federales = Participaciones_federales[_n-1] if missing(Participaciones_federales) & year >= 2022
 by clvmun: replace Aportaciones = Aportaciones[_n-1] if missing(Aportaciones) & year >= 2022
 
 drop if (cve_ent == "09") // Se eliminan los datos 2022 y CDMX debido a diferencias en la normatividad
 
 
 duplicates list cve_ent cve_mun year
 duplicates drop cve_ent cve_mun year, force
 
 sort cve_ent cve_mun year
 
 keep year clvmun cve_ent cve_mun ent municipio cuentas_pagadas Total_ingresos Impuestos Contribuciones_de_Mejoras Derechos Productos Aprovechamientos Otros_ingresos Financiamiento Disponibilidad_inicial monto_predial Aportaciones Participaciones_federales escolaridad ICTP P3_2 P3_3_8 P4_1a P4_2a P4_3a P4_4a P4_5a P3_2 P3_3_8 P4_1 P4_2 P4_3 P4_4 P4_5 P4_6 P3_X P4_X P3_2 P3_3_8 poblacion ipc_18 cve_zm nom_zm _merge Impuesto_predial_efipem
 
 order year clvmun cve_ent cve_mun ent municipio cuentas_pagadas monto_predial Impuesto_predial_efipem Total_ingresos Impuestos Contribuciones_de_Mejoras Derechos Productos Aprovechamientos Otros_ingresos Financiamiento Disponibilidad_inicial Aportaciones Participaciones_federales escolaridad ICTP P3_2 P3_3_8 P4_1 P4_2 P4_3 P4_4 P4_5 P4_6 P3_X P4_X P3_2 P3_3_8 poblacion ipc_18 cve_zm nom_zm _merge
 
 
 /*/Totales nacionales  
 collapse (sum) Total_ingresos monto_predial Impuesto_predial_efipem Impuestos Contribuciones_de_Mejoras Derechos Productos Aprovechamientos Otros_ingresos Financiamiento Disponibilidad_inicial cuentas_pagadas Aportaciones Participaciones_federales poblacion (first) ipc_18, by(year)
 
 gen Total_ingresos_r = (Total_ingresos/ipc_18)*100
 gen Impuestos_r = (Impuestos/ipc_18)*100
 gen Impuesto_predial_efipem_r = (Impuesto_predial_efipem/ipc_18)*100
 gen Contribuciones_de_Mejoras_r = (Contribuciones_de_Mejoras/ipc_18)*100
 gen Derechos_r = (Derechos/ipc_18)*100
 gen Productos_r = (Productos/ipc_18)*100
 gen Aprovechamientos_r = (Aprovechamientos/ipc_18)*100
 gen Otros_ingresos_r = (Otros_ingresos/ipc_18)*100
 gen Financiamiento_r = (Financiamiento/ipc_18)*100
 gen Disponibilidad_inicial_r = (Disponibilidad_inicial/ipc_18)*100 
 gen monto_predial_r = (monto_predial/ipc_18)*100
 gen Aportaciones_r = (Aportaciones/ipc_18)*100
 gen Participaciones_r = (Participaciones_federales/ipc_18)*100
 
 gen monto_predial_porT = (monto_predial_r/Total_ingresos_r)*100
 gen Impuesto_predial_efipem_porT = (Impuesto_predial_efipem_r/Total_ingresos_r)*100
 gen Aportaciones_porT = (Aportaciones_r/Total_ingresos_r)*100
 gen Participaciones_porT = (Participaciones_r/Total_ingresos_r)*100
 gen Impuestos_porT = (Impuestos_r/Total_ingresos_r)*100
 gen Contribuciones_de_Mejoras_porT = (Contribuciones_de_Mejoras_r/Total_ingresos_r)*100
 gen Derechos_porT = (Derechos_r/Total_ingresos_r)*100
 gen Productos_porT = (Productos_r/Total_ingresos_r)*100
 gen Aprovechamientos_porT = (Aprovechamientos_r/Total_ingresos_r)*100
 gen Otros_ingresos_porT = (Otros_ingresos_r/Total_ingresos_r)*100
 gen Financiamiento_porT = (Financiamiento_r/Total_ingresos_r)*100
 gen Disponibilidad_inicial_porT = (Disponibilidad_inicial_r/Total_ingresos_r)*100
 
 gen monto_predial_rpcap = ((monto_predial /ipc_18)*100) / poblacion
 gen Aportaciones_rpcap = ((Aportaciones / ipc_18)*100) / poblacion
 gen Participaciones_rpcap = ((Participaciones_federales / ipc_18)*100) / poblacion
 gen cuentas_pagadas_pcap = (cuentas_pagadas / poblacion)
 gen monto_predial_pcap = (monto_predial) / poblacion
 
 
 save "Base_Nacional.dta", replace
 
*/ 
 
 
// Deflactactor y per capita
 gen monto_predial_rpcap = (monto_predial / ipc_18)*100 / poblacion
 gen Aportaciones_r = (Aportaciones / ipc_18)*100 
 gen Participaciones_r = (Participaciones_federales / ipc_18)*100 
 gen Aportaciones_rpcap = (Aportaciones / ipc_18)*100 / poblacion
 gen Participaciones_rpcap = (Participaciones_federales / ipc_18)*100 / poblacion
 gen cuentas_pagadas_pcap = (cuentas_pagadas / poblacion)
 gen ICTP_r = (ICTP / ipc_18)*100
 
  gen monto_predial_rpcap_l = log(monto_predial_rpcap)
 gen ICTP_r_l = log(ICTP_r)
 gen Aportaciones_rpcap_l = log(Aportaciones_rpcap)
 gen Participaciones_rpcap_l = log(Participaciones_rpcap)
 gen cuentas_pagadas_pcap_l = log(cuentas_pagadas_pcap)
 gen escolaridad_l = log(escolaridad)
 gen cuentas_pagadas_l = log(cuentas_pagadas)
 
 save "Base_Completa.dta", replace
 
 
 
 /////////////////////////////////////////// Modelos econometricos
 
 use "Base_Completa.dta", clear
 destring cve_ent, replace 
 

 reg monto_predial_rpcap ICTP_r Aportaciones_rpcap Participaciones_rpcap escolaridad cuentas_pagadas_l P3_2 P3_3_8 P4_1a P4_2a P4_3a P4_4a P4_5a	//Modelo 2 
 outreg2 using myreg.doc, replace ctitle(Modelo 1)
 
 reg monto_predial_rpcap ICTP_r Aportaciones_rpcap Participaciones_rpcap escolaridad cuentas_pagadas_l  P3_X P4_X
 outreg2 using myreg.doc, append ctitle(Modelo 2)
 
 estat hettest
 estat  ovtest
 //sktest res
 
 // Eliminado debido a falta de sustento teorico y dificil analisis de resultados
 //reg monto_predial_rpcap_l ICTP_r_l Aportaciones_rpcap_l Participaciones_rpcap_l escolaridad cuentas_pagadas_pcap										//Modelo X
 //reg monto_predial_rpcap_l ICTP_r_l Aportaciones_rpcap_l Participaciones_rpcap_l escolaridad cuentas_pagadas_pcap P3_2 P3_3_8 P4_1 P4_2 P4_3 P4_4 P4_5 P4_6 //Modelo X

 
 ///////////Efectos fijos set
 
 use "Base_Completa.dta", clear

 encode clvmun, gen(con_cod)
 xtset con_cod year
 sort clvmun year

 //Bateria de Modelos de Efectos Fijos:
 //xtreg monto_predial_rpcap ICTP_r Aportaciones_rpcap Participaciones_rpcap escolaridad cuentas_pagadas_l, fe robust // Modelo 3
 //xtreg monto_predial_rpcap ICTP_r Aportaciones_rpcap Participaciones_rpcap escolaridad cuentas_pagadas_l i.year, fe robust // Modelo 4
 
 // xtreg monto_predial_rpcap P3_2 P3_3_8 P4_1 P4_2 P4_3 P4_4 P4_5 P4_6, fe robust  *Bajo R2 (0.035) coef no consistentes 
 
 xtreg monto_predial_rpcap ICTP_r Aportaciones_rpcap Participaciones_rpcap escolaridad cuentas_pagadas_l P3_2 P3_3_8, fe robust // Modelo 5
 outreg2 using fex.doc, replace ctitle(Modelo 4) addtext(EF Municipales, YES)
 
 
 xtreg monto_predial_rpcap ICTP_r Aportaciones_rpcap Participaciones_rpcap escolaridad cuentas_pagadas_l P3_2 P3_3_8 i.year, fe robust // Modelo 6
 outreg2 using fex.doc, append ctitle(Modelo 5) keep(ICTP_r Aportaciones_rpcap Participaciones_rpcap escolaridad cuentas_pagadas_l P3_2 P3_3_8) addtext(EF Municipales, YES, EF Temporales, YES)
 
 //Estrellas de la corona
 xtreg monto_predial_rpcap ICTP_r Aportaciones_rpcap Participaciones_rpcap escolaridad cuentas_pagadas_l P3_2 P3_3_8 P4_1 P4_2 P4_3 P4_4 P4_5, fe // Modelo 7
 outreg2 using fex.doc, append ctitle(Modelo 6) addtext(EF Municipales, YES)
 xtreg monto_predial_rpcap ICTP_r Aportaciones_rpcap Participaciones_rpcap escolaridad cuentas_pagadas_l P3_2 P3_3_8 P4_1a P4_2a P4_3a P4_4a P4_5a i.year, fe robust //Modelo 8
 
 outreg2 using fex.doc, append ctitle(Modelo 7) keep(ICTP_r Aportaciones_rpcap Participaciones_rpcap escolaridad cuentas_pagadas_l P3_2 P3_3_8 P4_1 P4_2 P4_3 P4_4 P4_5) addtext(EF Municipales, YES, EF Temporales, YES)
 
 //Heterocedasticidad reducida
 xtreg monto_predial_rpcap ICTP_r Aportaciones_rpcap Participaciones_rpcap escolaridad cuentas_pagadas_l P3_X P4_X, fe robust // Modelo 5 
 outreg2 using fex.doc, append ctitle(Modelo 8) addtext(EF Municipales, YES)

 xtreg monto_predial_rpcap ICTP_r Aportaciones_rpcap Participaciones_rpcap escolaridad cuentas_pagadas_l P3_X P4_X i.year, fe robust // Modelo 5
 outreg2 using fex.doc, append ctitle(Modelo 9) keep(ICTP_r Aportaciones_rpcap Participaciones_rpcap escolaridad cuentas_pagadas_l P3_X P4_X) addtext(EF Municipales, YES, EF Temporales, YES)

 
   /*/TEST
 xtreg monto_predial_rpcap ICTP_r Aportaciones_rpcap Participaciones_rpcap escolaridad cuentas_pagadas P3_2 P3_3_8 P4_1 P4_3 P4_4 P4_5 P4_6, fe // Modelo 7
 xtreg monto_predial_rpcap ICTP_r Aportaciones_rpcap Participaciones_rpcap escolaridad cuentas_pagadas P3_2 P3_3_8 P4_1 P4_3 P4_4 P4_5 P4_6 i.year, fe robust //Modelo 8

  */
  
 
 /* // Se omite la regresión empleando el porcentaje de personas con satisfacción alta o muy alta con los servicios públicos debido a que: si bien el R2 incrementa marginalmente, 
 	// el signo de los ecoeficientes deja de ser consistente, y estos mismos dejan de ser significativos en los casos donde coinciden con la teoria. 
 
 //Estrellas de la corona
 xtreg monto_predial_rpcap ICTP_r Aportaciones_rpcap Participaciones_rpcap cuentas_pagadas_pcap escolaridad P3_2 P3_3_8 P4a_1 P4a_2 P4a_3 P4a_4 P4a_5 P4a_6 , fe // Modelo 9
 xtreg monto_predial_rpcap ICTP_r Aportaciones_rpcap Participaciones_rpcap cuentas_pagadas_pcap escolaridad P3_2 P3_3_8 P4a_1 P4a_2 P4a_3 P4a_4 P4a_5 P4a_6 i.year, fe robust //Modelo 10
*/	
   
 
 
 
 /*
 4_4_1 Nivel de satisfacción con el agua potable en la vivienda
4_4_2 Nivel de satisfacción con el drenaje y alcantarillado
4_4_3 Nivel de satisfacción con el alumbrado público 
4_4_4 Nivel de satisfacción con los parques y jardines de la ciudad
4_4_5 Nivel de satisfacción con el servicio de recolección de basura
4_4_6 Nivel de satisfacción con la policía de la ciudad
3_2 Percepción general de la corrupción en el estado
3_3_8 Percepción de corrupción en las presidencias municipales
*/
 
 
 
 
 
 
 
 
 
 
 