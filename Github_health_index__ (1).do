****************************************************************************************************************************************************
**********************************************************What Works Centre for Wellbeing *********************************************************
**************************************************Wellbeing and Health Index Components analysis - 2015-2021 ***************************************
**********************************************************Simona Tenaglia - October 2023************************************************************
****************************************************************************************************************************************************

**Version 1.0  - Stata 14

**This do file run an analysis of some components of the Health index, namely subjective wellbeing variables and physical and mental health indicators**
** that compose the Health index. The analysis is conducted using the following steps: descriptive analysis, correlation analysis, and regression     **
** analysis. Data from the Office for National Statistics (ONS) are used to run this analysis.

**********************************************************The Health Index **************************************************************************
** The Health Index provides a single value for health in England, covering  the 9 regions  and 307 local authorities each year starting from 2015  ** 
** to 2021. This allows users to understand any changes over time or differences between areas. The Health Index encompasses three main domains:    **
** Healthy People, Healthy Lives,and Healthy places. Each domains consists of several subdomains, resulting in a total of 56 indicators.            **                                       
** For further information on the Health Index and the specific indicators within each domain, refer to the following ONS documentation             ** 
** https://www.ons.gov.uk/peoplepopulationandcommunity/healthandsocialcare/healthandwellbeing/methodologies/healthindexindicatorsanddefinitions     **
** For further information on the methodology for building the Health Index refer to the following ONS documentation                                **
** https://www.ons.gov.uk/peoplepopulationandcommunity/healthandsocialcare/healthandwellbeing/methodologies/healthindexmethodsanddevelopment2015to2019

***************************************************** ******The Health Index datasets******************************************************************         
** Data Source: The data used in this analysis are downloaded from the ONS website. Two Excel files were utilized:                                   **
** 1. one containing the score data for the 56 indicators for the years 2015 to 2021 for all England, the nine regions and 307 local authoritie      **                                            *
** (https://www.ons.gov.uk/peoplepopulationandcommunity/healthandsocialcare/healthandwellbeing/datasets/healthindexscoresengland)                    **
** 2.a second file containing the underlying data for 307 local authorities                                                                          **
** (https://www.ons.gov.uk/peoplepopulationandcommunity/healthandsocialcare/healthandwellbeing/datasets/healthindexunderlyingdataengland)            **

*******************************************************************************************************************************************************
clear all
set more off, perm     /// not to pause or display a -more- message. The option perm means the -more- setting is remembered and become the default setting.

**Set working directory
cd "C:\health_index"

************************************************************Descriptives Analys**************************************************************************
**Importing and Appending Data
** This section of the code imports the data files containing the indicators for the health index and appends them to create a comprehensive dataset. 
**2021
import excel "C:\health_index\healthindexscoresengland.xlsx", sheet("Table_3_2021_Index") cellrange(A6:BX347) firstrow
gen year=2021
gen id=_n
save "C:\health_index\Table_3_2021_Index.dta", replace
**2020
clear all
import excel "C:\health_index\healthindexscoresengland.xlsx", sheet("Table_4_2020_Index") cellrange(A5:BX346) firstrow
gen year=2020
gen id=_n
save "C:\health_index\Table_4_2020_Index.dta", replace
**2019
clear all
import excel "C:\health_index\healthindexscoresengland.xlsx",  sheet("Table_5_2019_Index") cellrange(A5:BX346) firstrow clear
gen year=2019
gen id=_n
save "C:\health_index\Table_5_2019_Index.dta", replace
**2018
clear all
import excel "C:\health_index\healthindexscoresengland.xlsx", sheet("Table_6_2018_Index") cellrange(A5:BX346) firstrow
gen year=2018
gen id=_n
save "C:\health_index\Table_6_2018_Index.dta", replace
**2017
clear all
import excel "C:\health_index\healthindexscoresengland.xlsx", sheet("Table_7_2017_Index") cellrange(A5:BX346) firstrow
gen year=2017
gen id=_n
save "C:\health_index\Table_7_2017_Index.dta", replace
**2016
clear all
import excel "C:\health_index\healthindexscoresengland.xlsx", sheet("Table_8_2016_Index") cellrange(A5:BX346) firstrow
gen year=2016
gen id=_n
save "C:\health_index\Table_8_2016_Index.dta", replace
**2015
clear all
import excel "C:\health_index\healthindexscoresengland.xlsx", sheet("Table_9_2015_Index") cellrange(A5:BX346) firstrow
gen year=2015
gen id=_n
save "C:\health_index\Table_9_2015_Index.dta", replace

**append datasets
clear all
use "C:\health_index\Table_9_2015_Index.dta"
append using "C:\health_index\Table_8_2016_Index.dta" "C:\health_index\Table_7_2017_Index.dta" ///
"C:\health_index\Table_6_2018_Index.dta" "C:\health_index\Table_5_2019_Index.dta"  ///
"C:\health_index\Table_4_2020_Index.dta" "C:\health_index\Table_3_2021_Index.dta"

****************************************************************Descriptives Analysis**************************************************************
**This part of the analysis is run using data on indicators for England and the 9 regions over the period 2015-2021
**We do graphs for Subjective Wellbeing variables for 9 regions and England over 2015-2021
**Selection of data for 9 regions and England 
keep if AreaTypeNote3 == "Region" | AreaTypeNote3 == "Country"
**graphs for variations in domain index over years 2015-2021 for England 
twoway (line HealthyPeopleDomain year if AreaTypeNote3=="Country", lpattern(solid)) (line HealthyLivesDomain year if AreaTypeNote3=="Country", lpattern(solid)) ///
 (line HealthyPlacesDomain year if AreaTypeNote3=="Country", lpattern(solid)), ylabel(, labsize(small)) xtitle(year) xlabel(, labsize(small)) title(Health and domain index England 2015-2021) ///
 legend(size(small)) graphregion(fcolor(white))
**selection of England observations
keep if AreaTypeNote3=="Country"
** calculate variation for Healthy people, Healthy lives and Healthy places domain index over years 2015-2021 for England
local domains "HealthyPeopleDomain HealthyLivesDomain HealthyPlacesDomain"
local count = 1

foreach domain in `domains' {
    gen diff_percent_`domain' = (`domain' - `domain'[_n-1]) /`domain'[_n-1] * 100
    
    twoway line `domain' year || bar diff_percent_`domain' year, bcolor("58 183 185") ylabel(, labsize(small))  xtitle(year) xlabel(, labsize(small))  xlabel(#7) legend(size(small)) graphregion(fcolor(white))

    * Save the graph
    graph save "C:\graph`count'.png", replace
    local ++count
}
******************************************Commands to produce graphs with year-on-year % change of indicator *******************************************
**calculate year-on-year variations for each  indicators
drop AreaName AreaCode id
rename Sexuallytransmittedinfections Sexuallytransminf
foreach var in DisabilityPe1 FrailtyPe1 Childrenssocialemotionaland MentalhealthconditionsPe2 SelfharmPe2 SuicidesPe2 AvoidablemortalityPe3 InfantmortalityPe3 LifeexpectancyPe3 ///
MortalityfromallcausesPe3 Activitiesinlifeareworthwhil FeelingsofanxietyPe4 HappinessPe4 LifesatisfactionPe4 CancerPe5 CardiovascularconditionsPe5 DementiaPe5 KidneyandliverdiseasePe5 ///
DiabetesPe5 MusculoskeletalconditionsPe5 RespiratoryconditionsPe5 AlcoholmisuseL1 DrugmisuseL1 HealthyeatingL1 PhysicalactivityL1 SedentarybehaviourL1 Sexuallytransminf SmokingL1  ///
EarlyyearsdevelopmentL2 PupilabsencesL2 PupilattainmentL2 TeenagepregnancyL2 Youngpeopleineducationemplo HighbloodpressureL3 LowbirthweightL3 Overweightandobesityinadults ///
Overweightandobesityinchildr CancerscreeningattendanceL4 ChildvaccinationcoverageL4 PrivateoutdoorspacePl1  DistancetoGPservicesPl2 DistancetopharmaciesPl2 ///
Distancetosportsorleisurefa InternetaccessPl2 PatientsofferedacceptableGPp LowlevelcrimePl3 PersonalcrimePl3 ChildpovertyPl4 JobrelatedtrainingPl4 UnemploymentPl4 WorkplacesafetyPl4 ///
 AirpollutionPl5 HouseholdovercrowdingPl5 NoisecomplaintsPl5 RoadsafetyPl5 RoughsleepingPl5{
    gen `var'_var = .
}

*Calculate year-on-year percentage change for a list of indicators for the years 2016-2021.
local variables DisabilityPe1 FrailtyPe1 Childrenssocialemotionaland MentalhealthconditionsPe2 SelfharmPe2 SuicidesPe2 AvoidablemortalityPe3 InfantmortalityPe3 LifeexpectancyPe3 ///
MortalityfromallcausesPe3 Activitiesinlifeareworthwhil FeelingsofanxietyPe4 HappinessPe4 LifesatisfactionPe4 CancerPe5 CardiovascularconditionsPe5 DementiaPe5 KidneyandliverdiseasePe5 ///
DiabetesPe5 MusculoskeletalconditionsPe5 RespiratoryconditionsPe5 AlcoholmisuseL1 DrugmisuseL1 HealthyeatingL1 PhysicalactivityL1 SedentarybehaviourL1 Sexuallytransminf SmokingL1  ///
 EarlyyearsdevelopmentL2 PupilabsencesL2 PupilattainmentL2 TeenagepregnancyL2 Youngpeopleineducationemplo HighbloodpressureL3 LowbirthweightL3 Overweightandobesityinadults ///
 Overweightandobesityinchildr CancerscreeningattendanceL4 ChildvaccinationcoverageL4 PrivateoutdoorspacePl1  DistancetoGPservicesPl2 DistancetopharmaciesPl2 ///
 Distancetosportsorleisurefa InternetaccessPl2 PatientsofferedacceptableGPp LowlevelcrimePl3 PersonalcrimePl3 ChildpovertyPl4 JobrelatedtrainingPl4 UnemploymentPl4 WorkplacesafetyPl4 ///
 AirpollutionPl5 HouseholdovercrowdingPl5 NoisecomplaintsPl5 RoadsafetyPl5 RoughsleepingPl5
foreach var of local variables {
    forvalues y = 2016/2021 {
        replace `var'_var = ((`var' - `var'[_n-1]) / `var'[_n-1]) * 100 if year == `y'
    }
}
* Get the full list of variables
unab allvars : _all

* Create the list of the first 74 variables
forvalues i=1/74 {
    local droplist "`droplist' `:word `i' of `allvars'"
}

* Drop the specified variables
drop `droplist'
**transpose the dataset and drop the first observation (row) from the dataset
xpose, clear
drop in 1
*input a list of variable names into a string variable named variable_name
input str50 variable_name
DisabilityPe1
FrailtyPe1
Childrenssocialemotionaland
MentalhealthconditionsPe2
SelfharmPe2
SuicidesPe2
AvoidablemortalityPe3
InfantmortalityPe3
LifeexpectancyPe3
MortalityfromallcausesPe3
Activitiesinlifeareworthwhil
FeelingsofanxietyPe4
HappinessPe4
LifesatisfactionPe4
CancerPe5
CardiovascularconditionsPe5
DementiaPe5
KidneyandliverdiseasePe5
DiabetesPe5
MusculoskeletalconditionsPe5
RespiratoryconditionsPe5
AlcoholmisuseL1
DrugmisuseL1
HealthyeatingL1
PhysicalactivityL1
SedentarybehaviourL1
Sexuallytransminf
SmokingL1
EarlyyearsdevelopmentL2
PupilabsencesL2
PupilattainmentL2
TeenagepregnancyL2
Youngpeopleineducationemplo
HighbloodpressureL3
LowbirthweightL3
Overweightandobesityinadults
Overweightandobesityinchildr
CancerscreeningattendanceL4
ChildvaccinationcoverageL4
PrivateoutdoorspacePl1
DistancetoGPservicesPl2
DistancetopharmaciesPl2
Distancetosportsorleisurefa
InternetaccessPl2
PatientsofferedacceptableGPp
LowlevelcrimePl3
PersonalcrimePl3
ChildpovertyPl4
JobrelatedtrainingPl4
UnemploymentPl4
WorkplacesafetyPl4
AirpollutionPl5
HouseholdovercrowdingPl5
NoisecomplaintsPl5
RoadsafetyPl5
RoughsleepingPl5
end
**generating new variable names by appending the year to the original variable names
local year = 2016

forval i = 2/7 {
    local new_varname v`i'
    
    // Append a letter or underscore to the year
    local new_varname `new_varname'_`year'

    rename v`i' `new_varname'
    
    local ++year
}
**sort data to do a bar graph for % variation year on year of 56 indicators
foreach var in v7_2021 v6_2021 v5_2021 {
    // Sort the dataset by the current variable
    sort `var'

    // Generate the bar graph for the current variable
    graph bar (asis) `var', over(variable_name, sort(`var') descending) ///
    bar(1, color("58 183 185")) graphregion(color(white)) ///
    ytitle("% change 2020-2021") ytitle(, size(small))
	// Display the graph
    graph display
}

**reload the data because we kept only data for Country 
clear all
use "C:\health_index\Table_9_2015_Index.dta"
append using "C:\health_index\Table_8_2016_Index.dta" "C:\health_index\Table_7_2017_Index.dta" ///
"C:\health_index\Table_6_2018_Index.dta" "C:\health_index\Table_5_2019_Index.dta"  ///
"C:\health_index\Table_4_2020_Index.dta" "C:\health_index\Table_3_2021_Index.dta"

foreach indicator in HealthyPeopleDomain PersonalwellbeingPe LifesatisfactionPe4 HappinessPe4 Activitiesinlifeareworthwhil FeelingsofanxietyPe4 MortalityPe MentalhealthPe PhysicalhealthconditionsPe DifficultiesindailylifePe{
    // line graph for the current indicator over 9 regions and years 2015-2021
    twoway (line `indicator' year if AreaName=="London") ///
           (line `indicator' year if AreaName=="North East") ///
           (line `indicator' year if AreaName=="East of England") ///
           (line `indicator' year if AreaName=="North West") ///
           (line `indicator' year if AreaName=="South East") ///
           (line `indicator' year if AreaName=="South West") ///
           (line `indicator' year if AreaName=="West Midlands") ///
           (line `indicator' year if AreaName=="East Midlands") ///
           (line `indicator' year if AreaName=="Yorkshire and The Humber") ///
           (line `indicator' year if AreaName=="ENGLAND"), ///
           ytitle("`indicator' index") ytitle(, size(small)) ylabel(, labsize(small)) xlabel(, labsize(small)) xlabel(#7, valuelabel) ///
           legend(order(1 "London" 2 "North East" 3 "East of England" 4 "North West" 5 "South East" 6 "South West" 7 "West Midlands" 8 "East Midlands" 9 "Yorkshire and The Humber" 10 "ENGLAND") size(small)) ///
           graphregion(color(white))
		   // Save the graph in the C:\health_index directory
    local graph_path "C:\health_index\graph_`indicator'.png"
    graph export "`graph_path'", replace
}
**keep only values for 9 regions
keep if AreaTypeNote3 == "Region" 
** bar graphs for mortality subdomain indicators  for years  2019, 2020 and 2021 for 9 regions
foreach yr in 2021 2020 2019{
    graph bar (asis) MortalityfromallcausesPe3 LifeexpectancyPe3 InfantmortalityPe3 AvoidablemortalityPe3 if year==`yr', over(AreaName) ///
    graphregion(color(white)) title(Mortality indicators `yr', size(small)) ylabel(, labsize(small) angle(45)) asyvars bar(1, color("58 183 185")) ///
    bar(2, color("0 52 66")) bar(3, color("247 147 33")) bar(4, color("219 120 168")) legend(order(1 "Mortality from all causes" 2 "Life expectancy" 3 "Infant mortality" 4 "Avoidable mortality") size(small)) ///
    graphregion(color(white))
        * Save the graph
    graph save "C:\Mortality_Indicators_`yr'.png", replace
}
** bar graph for mental health subdomain indicators  for years  2019, 2020 and 2021 for 9 regions
foreach yr in 2021 2020 2019 {
    graph bar (asis) Childrenssocialemotionaland MentalhealthconditionsPe2 SelfharmPe2 SuicidesPe2 if year==`yr',  over(AreaName) ///
    graphregion(color(white)) title(Mental Health indicators `yr', size(small)) ylabel(, labsize(small))  asyvars bar(1, color("58 183 185")) bar(2, color("0 52 66")) bar(3, color("247 147 33")) bar(4, color("219 120 168")) ///
    legend(order(1 "Children social emotional and mental health" 2 "Mental health conditions" 3 "Self_harm" 4 "Suicides") size(small)) ///
    graphregion(color(white))
        * Save the graph
    graph save "C:\Mental_Health_Indicators_`yr'.png", replace
}
** bar graph for physical health conditions subdomain indicators  for years  2019, 2020 and 2021 for 9 regions
foreach yr in 2021 2020 2019 {
    graph bar (asis) CancerPe5 CardiovascularconditionsPe5 DementiaPe5 DiabetesPe5 KidneyandliverdiseasePe5 MusculoskeletalconditionsPe5 RespiratoryconditionsPe5 if year==`yr', over(AreaName) ///
    graphregion(color(white)) title(Physical health conditions indicators `yr', size(small)) ylabel(, labsize(small)) asyvars ///
    bar(1, color("58 183 185")) bar(2, color("0 52 66")) bar(3, color("247 147 33")) bar(4, color("219 120 168")) ///
    bar(5, color("140 196 59")) bar(6, color("62 199 244")) bar(7, color("136 136 136")) ///
    legend(order(1 "Cancer" 2 "Cardiovascular conditions" 3 "Dementia" 4 "Diabetes" 5 "Kidney and liver diseases" 6 "Musculoskeletal conditions" 7 "Respiratory conditions") size(small)) ///
    graphregion(color(white))
        * Save the graph
    graph save "C:\Physical_Health_Indicators_`yr'.png", replace
}

** bar graph for difficulties in daily life subdomain indicators  2021
foreach yr in 2021 2020 2019 {
    graph bar (asis) DisabilityPe1 FrailtyPe1 if year==`yr', over(AreaName) ///
    graphregion(color(white)) title(Difficulties in daily life indicators `yr', size(small)) ylabel(, labsize(small)) asyvars bar(1, color("58 183 185")) bar(2, color("0 52 66")) ///
    legend(order(1 "Disability" 2 "Frailty") size(small)) graphregion(color(white))
    * Save the graph
    graph save "C:\Difficulties_Indicators_`yr'.png", replace
}

***********************************************************************Correlations analysis*********************************************
**The correlation and reggression analysis is run on underlying data. 
**The following commands prepare the dataset before running the analysis
foreach yr in 2015 2016 2017 2018 2019 2020 2021{
    clear
    import excel "C:\healthindexunderlyingdataenglandcanscreenfix.xlsx", sheet ("Table_2_Underlying_data") cellrange(A4:G1048576) firstrow

    **Clean Areaname
    foreach char in "-" "'" "," " " "." {
        replace Areaname = subinstr(Areaname, "`char'", "", .)
    }
    replace Areaname = "BPC" if Areaname == "BournemouthChristchurchandPoole"


    * Select observation for the year in the current loop iteration
    keep if Year == `yr'

    * Data manipulation
	**drop non necessary variables
    drop  Numerator Denominator Areacode
	**put each indicators on each rows 
	reshape wide Value, i(Indicatorname) j(Areaname) string
	**transpose the dataset to get indicators  by columns
	sxpose2, clear firstnames varname force
	**rename the column with the name of each indicators
	rename  _var1 Worthwhile
	rename _var2 Air_pollution
	rename _var3 Alcohol_misuse
	rename _var4 Avoidable_mortality
	rename _var6 Cancer_screening_attendance
	rename _var7 Cardiovascular_conditions
	rename _var8 Child_poverty
	rename _var9 Child_vaccination_coverage
	rename _var10 Childrenemotionalmentalhealth
	rename _var14 Distance_GP_services
	rename _var15 Distance_pharmacies
	rename _var16 Distance_sportleisure_facilities
	rename _var17 Drug_misuse
	rename _var18 Early_years_development
	rename _var19 Anxiety
	rename _var22 Healthy_eating
	rename _var23 High_blood_pressure
	rename _var24 Household_overcrowding
	rename _var25 Infant_mortality
	rename _var26 Internet_access
	rename _var27 Jobrelated_training
	rename _var28 Kidney_liver_disease
	rename _var29 Life_expectancy
	rename _var30 Satisfaction
	rename _var31 Low_birth_weight
	rename _var32 Lowlevel_crime
	rename _var33 Mental_health_conditions
	rename _var34 Mortality_from_allcauses
	rename _var35 Musculoskeletal_conditions
	rename _var36 Noise_complaints
	rename _var37 Overweight_obesity_inadults
	rename _var38 Overweight_obesity_inchildren
	rename _var39 PatientsacceptableGP_appoint
	rename _var40 Personal_crime
	rename _var41 Physical_activity
	rename _var42 Private_outdoor_space
	rename _var43 Pupil_absences
	rename _var44 Pupil_attainment
	rename _var45 Respiratory_conditions
	rename _var46 Road_safety
	rename _var47 Rough_sleeping
	rename _var48 Sedentary_behaviour
	rename _var49 Self_harm
	rename _var50 Sexually_transmitted_infections
	rename _var53 Teenage_pregnancy
	rename _var55 Workplace_safety
	rename _var56 Youngpeople_educ_empl_apprent
	rename _varname Areaname
    * Create variable year and id
    gen year = `yr'
    gen id = _n
    * Save the dataset
    save "C\underlying_data`yr'.dta", replace
}

**append data to create a unique dataset
use "C\underlying_data2015.dta", clear
append using "C\underlying_data2016.dta" "C\underlying_data2017.dta" "C\underlying_data2018.dta" ///
"C\underlying_data2019.dta" "C\underlying_data2020.dta" "C\underlying_data2021.dta"

drop if id=308
**destring variables
destring   Worth Air_pollution Alcohol_misuse Avoidable_mortality Cancer Cancer_screening_attendance Cardiovascular_conditions ///
Child_poverty Child_vaccination_coverage Childrenemotionalmentalhealth Diabetes Dementia Disability Distance_GP_services ///
Distance_pharmacies Distance_sportleisure_facilities Drug_misuse Early_years_development Anxiety Frailty Happiness High_blood_pressure ///
Healthy_eating Household_overcrowding Infant_mortality Internet_access Jobrelated_training Kidney_liver_disease Life_expectancy  ///
Satisfaction Low_birth_weight Lowlevel_crime Mortality_from_allcauses Mental_health_conditions Musculoskeletal_conditions Noise_complaints ///
Overweight_obesity_inadults Overweight_obesity_inchildren PatientsacceptableGP_appoint Physical_activity Private_outdoor_space Pupil_absences ///
Pupil_attainment Respiratory_conditions Road_safety Rough_sleeping Sedentary_behaviour Sexually_transmitted_infections Self_harm Suicides Smoking ///
Teenage_pregnancy Unemployment Workplace_safety Youngpeople_educ_empl_apprent, replace

****************************************************************Correlation analysis**********************************************************************************
**calculate correlations matrix and create heatmaps for subjective wellebing variables and Healthy people and Healthy lives domains' indicators 
local list1 "Satisfaction Happiness Worthwhile Anxiety Disability Frailty"
local list2 "Satisfaction Happiness Worthwhile Anxiety Childrenemotionalmentalhealth Mental_health_conditions Self_harm Suicides"
local list3 "Satisfaction Happiness Worthwhile Anxiety Avoidable_mortality Infant_mortality Mortality_from_allcauses Life_expectancy"
local list4 "Satisfaction Happiness Worthwhile Anxiety Cancer Cardiovascular_conditions Dementia Diabetes Kidney_liver_disease Musculoskeletal_conditions Respiratory_conditions"
local list5 "Satisfaction Happiness Worthwhile Anxiety Alcohol_misuse Healthy_eating Physical_activity Sedentary_behaviour Sexually_transmitted_infections Drug_misuse Smoking"
local list6 "Satisfaction Happiness Worthwhile Anxiety Early_years_development Pupil_absences Pupil_attainment Teenage_pregnancy Youngpeople_educ_empl_apprent"
local list7 "Satisfaction Happiness Worthwhile Anxiety High_blood_pressure Low_birth_weight Overweight_obesity_inadults Overweight_obesity_inchildren"
local list8 "Satisfaction Happiness Worthwhile Anxiety Cancer_screening_attendance Child_vaccination_coverage"

local i = 1

foreach varlist in "`list1'" "`list2'" "`list3'" "`list4'" "`list5'" "`list6'" "`list7'" "`list8'" {
    pwcorr `varlist', star(.05)
    matrix corrmatrix = r(C) 

    ** create heatplot
    heatplot corrmatrix, values(format(%4.3f) size(vsmall)) legend(on) xlabel(,labsize(vsmall) angle(45)) ylabel(,labsize(vsmall)) graphregion(fcolor(white))

    ** Save the heatmap
    graph save "C\heatmap`i'.png", replace
    local ++i
}

*****************************************************************Regression analysis with underlying data**************************************************************
*****************************************************************************Test for normality************************************************************************
** This section of the code is dedicated to testing the normality of dependent variables in the dataset. The Shapiro-Wilk test (swilk) is used for this purpose. The **
**test assesses whether the distribution of each variable can be considered as normally distributed. The local macro 'variables' is defined to include the variables **
**Satisfaction, Happiness, Worthwhile, and Anxiety. The foreach loop then iterates over each of these variables, applying the Shapiro-Wilk test to them individually. **
** Results from this test provide insights into the distribution characteristics of these variables

** create local for loop to run normality test
local variables Satisfaction Happiness Worthwhile Anxiety

foreach var of local variables {
    swilk `var'
}
*****************************************************************Test for multicollinearity of regressors*************************************************************
** This section performs a multicollinearity test on sets of regressors. Multicollinearity is present when regressors are highly correlated, which can impact the   **
**reliability of the model's coefficients. Two local macros 'list1' and 'list2' are created, each containing a different set of variables. The 'collin' command is  **
**then used to assess multicollinearity among these variables. This is done by calculating measures like the Variance Inflation Factor (VIF) which help in          **
** identifying the presence and severity of multicollinearity.

**create locals for loop to run multicollinearity test
local list1 "Disability Frailty Childrenemotionalmentalhealth Mental_health_conditions Self_harm Suicides Avoidable_mortality Infant_mortality Life_expectancy Mortality_from_allcauses Cancer Cardiovascular_conditions Diabetes Kidney_liver_disease Musculoskeletal_conditions Respiratory_conditions"
local list2 "Alcohol_misuse Drug_misuse Healthy_eating Physical_activity Sedentary_behaviour Sexually_transmitted_infections Smoking Early_years_development Pupil_absences Pupil_attainment Teenage_pregnancy Youngpeople_educ_empl_apprent High_blood_pressure Low_birth_weight Overweight_obesity_inadults Overweight_obesity_inchildren Cancer_screening_attendance Child_vaccination_coverage"

foreach varlist in "`list1'" "`list2'" {
    collin `varlist'
}
******************************************************************First regression with all variables *****************************************************************
**Healthy people domain regression analysis
**state it is a panel
xtset id year
**Create a macro to store the names of the dependent variables
local depvars "Satisfaction Happiness Worthwhile Anxiety"
**Loop over the dependent variables
foreach x of local depvars {
    xtreg `x' Disability Frailty Children_mental_health Mental_health_conditions Self_harm Suicides Avoidable_mortality Infant_mortality Life_expectancy Mortality_from_allcauses  ///
	  Cancer Cardiovascular_conditions Diabetes Kidney_liver_disease Musculoskeletal_conditions Respiratory_conditions , fe 
    * Export the regression results to Excel
    outreg2 using "C:\Regression_Results_healthypeople_`x'.xlsx", replace
}
*Healthy lives domain regression analysis
**state it is a panel
xtset id year
**Create a macro to store the names of the dependent variables
local depvars "Satisfaction Happiness Worthwhile Anxiety"
**Loop over the dependent variables
foreach x of local depvars {
    xtreg `x' Alcohol_misuse Drug_misuse Healthy_eating Physical_activity Sedentary_behaviour Sexually_transmitted_infections Smoking Early_years_development ///
	Pupil_absences Pupil_attainment Teenage_pregnancy Youngpeople_educ_empl_apprent High_blood_pressure Low_birth_weight Overweight_obesity_inadults ///
	Overweight_obesity_inchildren Cancer_screening_attendance Child_vaccination_coverage , fe 
    * Export the regression results to Excel
    outreg2 using "C:\Regression_Results_healthylives`x'.xlsx", replace
}
***********************************************************Second regression controlling for heteroskedasticity*****************************************************
**Healthy people domain regression analysis
**state it is a panel
xtset id year
**Create a macro to store the names of the dependent variables
local depvars "Satisfaction Happiness Worthwhile Anxiety" 
**Loop over the dependent variables
foreach x of local depvars {
    xtreg `x' Disability Frailty Children_mental_health Mental_health_conditions Self_harm Suicides Avoidable_mortality Infant_mortality Life_expectancy Mortality_from_allcauses  ///
	  Cancer Cardiovascular_conditions Diabetes Kidney_liver_disease Musculoskeletal_conditions Respiratory_conditions , fe robust
    * Export the regression results to Excel
    outreg2 using "C:\Regression_Results_healthypeopleRobust_`x'.xlsx", replace
}
**Healthy lives
**Create a macro to store the names of the dependent variables
local depvars "Satisfaction Happiness Worthwhile Anxiety"
**Loop over the dependent variables
foreach x of local depvars {
    xtreg `x' Alcohol_misuse Drug_misuse Healthy_eating Physical_activity Sedentary_behaviour Sexually_transmitted_infections Smoking Early_years_development ///
	Pupil_absences Pupil_attainment Teenage_pregnancy Youngpeople_educ_empl_apprent High_blood_pressure Low_birth_weight Overweight_obesity_inadults ///
	Overweight_obesity_inchildren Cancer_screening_attendance Child_vaccination_coverage , fe robust
    * Export the regression results to Excel
    outreg2 using "C:\Regression_Results_healthylivesRobust`x'.xlsx", replace
}
**************************************************************Third regression with log-linear model****************************************************************
**create log of wellbeing variables
gen ln_Satisfaction = ln(Satisfaction)
gen ln_Happiness = ln(Happiness)
gen ln_Worthwhile = ln(Worthwhile)
gen ln_Anxiety = ln(Anxiety)
**Healthy people domain regression analysis
**state it is a panel
xtset id year
**Create a macro to store the names of the dependent variables
local depvars "ln_Satisfaction ln_Happiness ln_Worthwhile ln_Anxiety"
**Loop over the dependent variables
foreach x of local depvars {
   xtreg `x' Disability Frailty Children_mental_health Mental_health_conditions Self_harm Suicides Avoidable_mortality Infant_mortality Life_expectancy Mortality_from_allcauses  ///
	  Cancer Cardiovascular_conditions Diabetes Kidney_liver_disease Musculoskeletal_conditions Respiratory_conditions , fe robust
	* Export the regression results to Excel
    outreg2 using "C:\Regression_Results_healthypeopleLoglinear_`x'.xlsx", replace
}

**Healthy lives domain regression analysis
**state it is a panel
xtset id year
**Create a macro to store the names of the dependent variables
local depvars "ln_Satisfaction ln_Happiness ln_Worthwhile ln_Anxiety"
**Loop over the dependent variables
foreach x of local depvars {
	xtreg `x' Alcohol_misuse Drug_misuse Healthy_eating Physical_activity Sedentary_behaviour Sexually_transmitted_infections Smoking Early_years_development ///
	Pupil_absences Pupil_attainment Teenage_pregnancy Youngpeople_educ_empl_apprent High_blood_pressure Low_birth_weight Overweight_obesity_inadults ///
	Overweight_obesity_inchildren Cancer_screening_attendance Child_vaccination_coverage , fe robust
    * Export the regression results to Excel
    outreg2 using "C:\Regression_Results_healthylivesLoglinear`x'.xlsx", replace
}
****************************************************Regressions corrected for multicollinearity********************************************************************************
***************************************************************First regression ***********************************************************************************************
**Healthy people domain regression analysis
**state it is a panel
xtset id year
**Create a macro to store the names of the dependent variables
local depvars "Satisfaction Happiness Worthwhile Anxiety"
**Loop over the dependent variables
foreach x of local depvars {
    xtreg `x' Disability Frailty Children_mental_health Mental_health_conditions Self_harm Suicides  Infant_mortality  Mortality_from_allcauses    ///
	  Cancer Cardiovascular_conditions Diabetes Kidney_liver_disease Musculoskeletal_conditions  , fe 
    * Export the regression results to Excel
    outreg2 using "C:\Regression_Results_healthypeople_multicoll`x'.xlsx", replace
}
**Healthy lives domain regression analysis
**state it is a panel
xtset id year
**Create a macro to store the names of the dependent variables
xtset id year
local depvars "Satisfaction Happiness Worthwhile Anxiety"
**Loop over the dependent variables
foreach x of local depvars {
    xtreg `x' Alcohol_misuse Drug_misuse Healthy_eating Physical_activity  Sexually_transmitted_infections Smoking Early_years_development ///
	Pupil_absences Pupil_attainment Teenage_pregnancy Youngpeople_educ_empl_apprent High_blood_pressure Low_birth_weight Overweight_obesity_inadults ///
	Overweight_obesity_inchildren Cancer_screening_attendance Child_vaccination_coverage , fe 
    * Export the regression results to Excel
    outreg2 using "C:\Regression_Results_healthylives_multicoll`x'.xlsx", replace
}
***************************************************************Second regression ******************************************************************
**Healthy people domain regression analysis
**state it is a panel
xtset id year
**Create a macro to store the names of the dependent variables
local depvars "Satisfaction Happiness Worthwhile Anxiety"
**Loop over the dependent variables
xtset id year
local depvars "Satisfaction Happiness Worthwhile Anxiety"
**Loop over the dependent variables
foreach x of local depvars {
    xtreg `x' Disability Frailty Children_mental_health Mental_health_conditions Self_harm Suicides   Infant_mortality  Mortality_from_allcauses    ///
	  Cancer Cardiovascular_conditions Diabetes Kidney_liver_disease Musculoskeletal_conditions  , fe robust
    * Export the regression results to Excel
    outreg2 using "C:\Regression_Results_healthypeople_multicollRobust`x'.xlsx", replace 
}
**Healthy lives domain regression analysis
**state it is a panel
xtset id year
**Create a macro to store the names of the dependent variables
local depvars "Satisfaction Happiness Worthwhile Anxiety"
**Loop over the dependent variables
foreach x of local depvars {
    xtreg `x' Alcohol_misuse Drug_misuse Healthy_eating Physical_activity  Sexually_transmitted_infections Smoking Early_years_development ///
	Pupil_absences Pupil_attainment Teenage_pregnancy Youngpeople_educ_empl_apprent High_blood_pressure Low_birth_weight Overweight_obesity_inadults ///
	Overweight_obesity_inchildren Cancer_screening_attendance Child_vaccination_coverage , fe robust
    * Export the regression results to Excel
    outreg2 using "C:\Regression_Results_healthylives_multicollRobust`x'.xlsx", replace
}
**************************************************************Third regression with log-linear model****************************************************************
**create log of wellbeing variables
gen ln_Satisfaction = ln(Satisfaction)
gen ln_Happiness = ln(Happiness)
gen ln_Worthwhile = ln(Worthwhile)
gen ln_Anxiety = ln(Anxiety)
**Healthy people domain regression analysis
**state it is a panel
xtset id year
**Create a macro to store the names of the dependent variables
local depvars "ln_Satisfaction ln_Happiness ln_Worthwhile ln_Anxiety"
**Loop over the dependent variables

foreach x of local depvars {
    xtreg `x' Disability Frailty Children_mental_health Mental_health_conditions Self_harm Suicides   Infant_mortality  Mortality_from_allcauses    ///
	  Cancer Cardiovascular_conditions Diabetes Kidney_liver_disease Musculoskeletal_conditions  , fe robust
    * Export the regression results to Excel
    outreg2 using "C:\Regression_Results_healthypeople_multicollLoglinear`x'.xlsx", replace
}

**Healthy lives domain regression analysis
**state it is a panel
xtset id year
**Create a macro to store the names of the dependent variablesxtset id year
local depvars "ln_Satisfaction ln_Happiness ln_Worthwhile ln_Anxiety"
**Loop over the dependent variables
foreach x of local depvars {
    xtreg `x' Alcohol_misuse Drug_misuse Healthy_eating Physical_activity  Sexually_transmitted_infections Smoking Early_years_development ///
	Pupil_absences Pupil_attainment Teenage_pregnancy Youngpeople_educ_empl_apprent High_blood_pressure Low_birth_weight Overweight_obesity_inadults ///
	Overweight_obesity_inchildren Cancer_screening_attendance Child_vaccination_coverage , fe robust
    * Export the regression results to Excel
    outreg2 using "C:\Regression_Results_healthylives_multicollLoglinear`x'.xlsx", replace
}
