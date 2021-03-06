*an_tablecontent_SENSANtable

*SENSITIVITY ANALYSES / POST HOC ANALYSES

*************************************************************************
*Purpose: Create content that is ready to paste into a pre-formatted Word 
* shell table containing minimally and fully-adjusted HRs for risk factors
* of interest, across 4 outcomes (hosp, death, itu, death/itu composite)
*
*Requires: final analysis dataset (cr_analysis_dataset.dta)
*
*Coding: Krishnan Bhaskaran
*
*Date drafted: 18/4/2020
*************************************************************************



***********************************************************************************************************************
*Generic code to ouput the HRs across outcomes for all levels of a particular variables, in the right shape for table
cap prog drop outputHRsforvar
prog define outputHRsforvar
syntax, variable(string) min(real) max(real) 
forvalues i=`min'/`max'{
local endwith "_tab"

local outcome onscoviddeath
local modeltype fulladj

foreach antype of any primary earlycens ccbmismok adjethnic {

if "`antype'" == "primary" local filestem "./output/models/an_multivariate_cox_models_cpnsdeath_MAINFULLYADJMODEL"
if "`antype'" == "earlycens" local filestem "./output/models/an_sensan_earlieradmincensoring_cpnsdeath_MAINFULLYADJMODEL"
if "`antype'" == "ccbmismok" local filestem "./output/models/an_sensan_CCbmiandsmok_cpnsdeath_MAINFULLYADJMODEL"
if "`antype'" == "adjethnic" local filestem "./output/models/an_sensan_CCethnicity_cpnsdeath_MAINFULLYADJMODEL"
	
		local noestimatesflag 0 /*reset*/

		if "`antype'"=="adjethnic" local endwith "_n"

		***********************
		*1) GET THE RIGHT ESTIMATES INTO MEMORY
		
		*FOR AGEGROUP - need to use the separate univariate/multivariate model fitted with age group rather than spline
		*FOR ETHNICITY - use the separate complete case multivariate model
		*FOR REST - use the "main" multivariate model
		if "`variable'"=="agegroup" {
					if "`antype'"=="adjethnic" cap estimates use `filestem'_agegroup_bmicat_CCeth
						else cap estimates use `filestem'_agegroup_bmicat_noeth
				if _rc!=0 local noestimatesflag 1
				}

		else if "`variable'"=="ethnicity" {
				cap estimates use `filestem'_agespline_bmicat_CCeth  
				if _rc!=0 local noestimatesflag 1
			}			

		else {
				if "`antype'"=="adjethnic" cap estimates use `filestem'_agespline_bmicat_CCeth  
					else cap estimates use `filestem'_agespline_bmicat_noeth  
				if _rc!=0 local noestimatesflag 1
			}
		
		***********************
		*2) WRITE THE HRs TO THE OUTPUT FILE
		
		if `noestimatesflag'==0{
			cap lincom `i'.`variable', eform
			if _rc==0 file write tablecontents %4.2f (r(estimate)) (" (") %4.2f (r(lb)) ("-") %4.2f (r(ub)) (")") `endwith'
				else file write tablecontents %4.2f ("ERR IN MODEL") `endwith'
			}
			else file write tablecontents %4.2f ("DID NOT FIT") `endwith' 
			
		
	} /*outcomes*/
} /*variable levels*/

end
***********************************************************************************************************************
*Generic code to write a full row of "ref category" to the output file
cap prog drop refline
prog define refline
file write tablecontents ("1.00 (ref)") _tab ("1.00 (ref)") _tab ("1.00 (ref)") _tab ("1.00 (ref)") _tab ("1.00 (ref)") _tab ("1.00 (ref)") _n
end
***********************************************************************************************************************

*MAIN CODE TO PRODUCE TABLE CONTENTS

cap file close tablecontents
file open tablecontents using ./output/an_tablecontent_SENSANtable.txt, t w replace 

*Age group
outputHRsforvar, variable("agegroup") min(1) max(2)
refline
outputHRsforvar, variable("agegroup") min(4) max(6)
file write tablecontents _n _n

*Sex 
refline
outputHRsforvar, variable("male") min(1) max(1)
file write tablecontents _n _n

*BMI
refline
outputHRsforvar, variable("obese4cat") min(2) max(4)
file write tablecontents _n _n

*Smoking
refline
outputHRsforvar, variable("smoke_nomiss") min(2) max(3)
file write tablecontents _n _n

*Ethnicity
refline
outputHRsforvar, variable("ethnicity") min(2) max(5)
file write tablecontents _n _n

*IMD
refline
outputHRsforvar, variable("imd") min(2) max(5)
file write tablecontents _n _n

*BP/hypertension
refline
outputHRsforvar, variable("htdiag_or_highbp") min(1) max(1)
file write tablecontents _n _n

outputHRsforvar, variable("chronic_respiratory_disease") min(1) max(1)
file write tablecontents _n	_n		
outputHRsforvar, variable("asthmacat") min(2) max(3)			
file write tablecontents _n	
outputHRsforvar, variable("chronic_cardiac_disease") min(1) max(1)
file write tablecontents _n	_n		
outputHRsforvar, variable("diabcat") min(2) max(4)
file write tablecontents _n	_n		
outputHRsforvar, variable("cancer_exhaem_cat") min(2) max(4)
file write tablecontents _n	_n		
outputHRsforvar, variable("cancer_haem_cat") min(2) max(4)			
file write tablecontents _n				
outputHRsforvar, variable("chronic_liver_disease") min(1) max(1)			
file write tablecontents _n	
outputHRsforvar, variable("stroke_dementia") min(1) max(1)			
file write tablecontents _n	
outputHRsforvar, variable("other_neuro") min(1) max(1)			
file write tablecontents _n	
outputHRsforvar, variable("chronic_kidney_disease") min(1) max(1)			
file write tablecontents _n	
outputHRsforvar, variable("organ_transplant") min(1) max(1)			
file write tablecontents _n	
outputHRsforvar, variable("spleen") min(1) max(1)
file write tablecontents _n	
outputHRsforvar, variable("ra_sle_psoriasis") min(1) max(1)
file write tablecontents _n	
outputHRsforvar, variable("other_immunosuppression") min(1) max(1)			



file close tablecontents
