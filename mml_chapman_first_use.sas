﻿options nodate; 
ods noproctitle; 

***********************************************************************************************************************************************
************************************************FIRST USE ANALYSIS*****************************************************************************
***********************************************************************************************************************************************

importing data for first use of marijuana; 

proc import out = first1
 	datafile = "C:\Users\niwi8\OneDrive - cumc.columbia.edu\Practicum\MML_analysis\MML_chapman_index\data\NSDUH\first_use\first_use_2003_2016.xlsx"
	dbms = xlsx replace; 
	getnames = yes; 
	sheet = "12-17"; 
run; 

proc import out = first2
	datafile = "C:\Users\niwi8\OneDrive - cumc.columbia.edu\Practicum\MML_analysis\MML_chapman_index\data\NSDUH\first_use\first_use_2003_2016.xlsx"
	dbms = xlsx replace; 
	getnames = yes; 
	sheet = "18-25"; 
run; 

proc import out = first3
	datafile = "C:\Users\niwi8\OneDrive - cumc.columbia.edu\Practicum\MML_analysis\MML_chapman_index\data\NSDUH\first_use\first_use_2003_2016.xlsx"
	dbms = xlsx replace; 
	getnames = yes; 
	sheet = "26+"; 
run; 

*stacking data; 

data first_use_wide; 
	set first1 first2 first3; 
	if state = "" | state = "District of Columbia" then delete; 
run; 

*tranposing data; 

proc sort data = first_use_wide; 
	by state age_grp; 
run; 

proc transpose data = first_use_wide out = first_use
		(drop = _LABEL_ rename = (col1 = use)); 
	by state age_grp; 
	var estimate_2003 estimate_2004 estimate_2005 estimate_2006 estimate_2007 
		estimate_2008 estimate_2009 estimate_2010 estimate_2011 estimate_2012 
		estimate_2013 estimate_2014 estimate_2015 estimate_2016; 
run; 

data first_use; 
	set first_use; 
	drop _NAME_; 
	year = input(transtrn(_NAME_, "estimate_", ""), 5.); 
run; 

*creating abbreviation; 

data first_use; 
	set first_use; 
	if state = 'Alabama' then abbrev = 'AL'; 
	if state = 'Alaska' then abbrev = 'AK'; 
	if state = 'Arizona' then abbrev = 'AZ'; 
	if state = 'Arkansas' then abbrev = 'AR'; 
	if state = 'California' then abbrev = 'CA'; 
	if state = 'Colorado' then abbrev = 'CO'; 
	if state = 'Connecticut' then abbrev = 'CT'; 
	if state = 'Delaware' then abbrev = 'DE'; 
	if state = 'Florida' then abbrev = 'FL'; 
	if state = 'Georgia' then abbrev = 'GA'; 
	if state = 'Hawaii' then abbrev = 'HI'; 
	if state = 'Idaho' then abbrev = 'ID'; 
	if state = 'Illinois' then abbrev = 'IL'; 
	if state = 'Indiana' then abbrev = 'IN'; 
	if state = 'Iowa' then abbrev = 'IA'; 
	if state = 'Kansas' then abbrev = 'KS'; 
	if state = 'Kentucky' then abbrev = 'KY'; 
	if state = 'Louisiana' then abbrev = 'LA'; 
	if state = 'Maine' then abbrev = 'ME'; 
	if state = 'Maryland' then abbrev = 'MD'; 
	if state = 'Massachusetts' then abbrev = 'MA'; 
	if state = 'Michigan' then abbrev = 'MI'; 
	if state = 'Minnesota' then abbrev = 'MN'; 
	if state = 'Mississippi' then abbrev = 'MS'; 
	if state = 'Missouri' then abbrev = 'MO'; 
	if state = 'Montana' then abbrev = 'MT'; 
	if state = 'Nebraska' then abbrev = 'NE'; 
	if state = 'Nevada' then abbrev = 'NV'; 
	if state = 'New Hampshire' then abbrev = 'NH'; 
	if state = 'New Jersey' then abbrev = 'NJ'; 
	if state = 'New Mexico' then abbrev = 'NM'; 
	if state = 'New York' then abbrev = 'NY'; 
	if state = 'North Carolina' then abbrev = 'NC'; 
	if state = 'North Dakota' then abbrev = 'ND'; 
	if state = 'Ohio' then abbrev = 'OH'; 
	if state = 'Oklahoma' then abbrev = 'OK'; 
	if state = 'Oregon' then abbrev = 'OR'; 
	if state = 'Pennsylvania' then abbrev = 'PA'; 
	if state = 'Rhode Island' then abbrev = 'RI'; 
	if state = 'South Carolina' then abbrev = 'SC'; 
	if state = 'South Dakota' then abbrev = 'SD'; 
	if state = 'Tennessee' then abbrev = 'TN'; 
	if state = 'Texas' then abbrev = 'TX'; 
	if state = 'Utah' then abbrev = 'UT'; 
	if state = 'Vermont' then abbrev = 'VT'; 
	if state = 'Virginia' then abbrev = 'VA'; 
	if state = 'Washington' then abbrev = 'WA'; 
	if state = 'West Virginia' then abbrev = 'WV'; 
	if state = 'Wisconsin' then abbrev = 'WI'; 
	if state = 'Wyoming' then abbrev = 'WY'; 
run;

*reordering variables; 

data first_use; 
	retain abbrev state year age_grp use; 
	set first_use;  
run; 

*adding Chapman index info from past_month dataset;

proc sort data = first_use; 
	by abbrev year; 
run; 

proc sort data = past_month; 
	by abbrev year; 
run; 

data first_use;
   merge first_use past_month (drop = state year use);
   by abbrev;
run;

*adding info for new states; 

data first_use_newStates; 
	set first_use; 
	if abbrev in ("ND" "FL" "OH" "PA")
		then ever_pass = 1; 
	if abbrev = "ND" and year < 2016 then law_status = 0; 
	if abbrev = "FL" and year < 2016 then law_status = 0; 
	if abbrev = "OH" and year < 2016 then law_status = 0; 
	if abbrev = "PA" and year < 2016 then law_status = 0; 
	if ever_pass = 1 and law_status = 0 then mml_pass = "before"; 
		else if ever_pass = 1 and law_status = 1 then mml_pass = "after"; 
		else if ever_pass = 0 then mml_pass = "never"; 
run;

*after vs. before: first use; 

ods pdf file = "C:\Users\niwi8\OneDrive - cumc.columbia.edu\Practicum\MML_analysis\MML_chapman_index\reports\first_use\first_use_2003_2016_noChapman.pdf" style = journal2; 

proc mixed data = first_use;
	title "First use of marijuana: Cubic spline, age";
	class abbrev age_grp mml_pass; 
	model use = yearcont yearcont*yearcont yearcont*yearcont*yearcont
				yearsp*yearsp*yearsp
				age_grp*yearcont age_grp*yearcont*yearcont age_grp*yearcont*yearcont*yearcont
				age_grp*yearsp*yearsp*yearsp
				age_grp mml_pass age_grp*mml_pass / solution dfm = bw; 
	random abbrev / group = age_grp;
	lsmeans age_grp*mml_pass / pdiff cl; 
	estimate "Age 12-17: After to Before" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 1 -1 0 0 0 0 0 0 0;
	estimate "Age 18-25: After to Before" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 0 0 0 1 -1 0 0 0 0;
	estimate "Age 26+: After to Before" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 0 0 0 0 0 0 1 -1 0;
run; 

ods pdf close; 

*after vs. before (including new states): first use; 

ods pdf file = "C:\Users\niwi8\OneDrive - cumc.columbia.edu\Practicum\MML_analysis\MML_chapman_index\reports\first_use\new_states_first_use_2003_2016_noChapman.pdf" style = journal2;


proc mixed data = first_use_newStates;
	title "First use of marijuana (including new states): Cubic spline, age";
	class abbrev age_grp mml_pass; 
	model use = yearcont yearcont*yearcont yearcont*yearcont*yearcont
				yearsp*yearsp*yearsp
				age_grp*yearcont age_grp*yearcont*yearcont age_grp*yearcont*yearcont*yearcont
				age_grp*yearsp*yearsp*yearsp
				age_grp mml_pass age_grp*mml_pass / solution dfm = bw; 
	random abbrev / group = age_grp;
	*lsmeans age_grp*mml_pass / pdiff cl;
	estimate "Age 12-17: After to Before" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 1 -1 0 0 0 0 0 0 0;
	estimate "Age 18-25: After to Before" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 0 0 0 1 -1 0 0 0 0;
	estimate "Age 26+: After to Before" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 0 0 0 0 0 0 1 -1 0;
run;

ods pdf close;

*overall restrictiveness model: first use; 

ods pdf file = "C:\Users\niwi8\OneDrive - cumc.columbia.edu\Practicum\MML_analysis\MML_chapman_index\reports\first_use\first_use_2003_2016_overall_Chapman.pdf" style = journal2;

proc mixed data = first_use; 
	title "First use of marijuna: Cubic spline, age, binary MML Chapman index";
	class abbrev age_grp mml_pass restrict; 
	model use = yearcont yearcont*yearcont yearcont*yearcont*yearcont
				yearsp*yearsp*yearsp
				age_grp*yearcont age_grp*yearcont*yearcont age_grp*yearcont*yearcont*yearcont
				age_grp*yearsp*yearsp*yearsp
				age_grp mml_pass restrict 
				age_grp*restrict mml_pass*restrict age_grp*mml_pass age_grp*mml_pass*restrict / solution ddfm = bw; 
	random abbrev / group = age_grp; 
	*lsmeans age_grp*mml_pass*restrict / pdiff cl; 
	estimate "Age 12-17: After to Before, High Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 1 -1 0 0 0 0 0 0 0 
				mml_pass*restrict 1 0 -1 0 0 
				age_grp*mml_pass*restrict 1 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 / cl;
	estimate "Age 12-17: After to Before, Low Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 1 -1 0 0 0 0 0 0 0 
				mml_pass*restrict 0 1 0 -1 0 
				age_grp*mml_pass*restrict 0 1 0 -1 0 0 0 0 0 0 0 0 0 0 0 / cl;
	estimate "Age 18-25: After to Before, High Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 0 0 0 1 -1 0 0 0 0 
				mml_pass*restrict 1 0 -1 0 0 
				age_grp*mml_pass*restrict 0 0 0 0 0 1 0 -1 0 0 0 0 0 0 0 / cl; 
	estimate "Age 18-25: After to Before, Low Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 0 0 0 1 -1 0 0 0 0
				mml_pass*restrict 0 1 0 -1 0
				age_grp*mml_pass*restrict 0 0 0 0 0 0 1 0 -1 0 0 0 0 0 0 / cl; 
	estimate "Age 26+: After to Before, High Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 0 0 0 0 0 0 1 -1 0
				mml_pass*restrict 1 0 -1 0 0
				age_grp*mml_pass*restrict 0 0 0 0 0 0 0 0 0 0 1 0 -1 0 0 / cl; 
	estimate "Age 26+: After to Before, Low Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 0 0 0 0 0 0 1 -1 0
				mml_pass*restrict 0 1 0 -1 0
				age_grp*mml_pass*restrict 0 0 0 0 0 0 0 0 0 0 0 1 0 -1 0 / cl; ; 
run;

ods pdf close; 

*overall restrictiveness (including new states): first use; 

ods pdf file = "C:\Users\niwi8\OneDrive - cumc.columbia.edu\Practicum\MML_analysis\MML_chapman_index\reports\first_use\new_states_first_use_2003_2016_overall_Chapman.pdf" style = journal2;

proc mixed data = first_use_newStates; 
	title "First use of marijuana (including new states): Cubic spline, age, binary MML Chapman index";
	class abbrev age_grp mml_pass restrict; 
	model use = yearcont yearcont*yearcont yearcont*yearcont*yearcont
				yearsp*yearsp*yearsp
				age_grp*yearcont age_grp*yearcont*yearcont age_grp*yearcont*yearcont*yearcont
				age_grp*yearsp*yearsp*yearsp
				age_grp mml_pass restrict 
				age_grp*restrict mml_pass*restrict age_grp*mml_pass age_grp*mml_pass*restrict / solution ddfm = bw; 
	random abbrev / group = age_grp; 
	*lsmeans age_grp*mml_pass*restrict / pdiff cl; 
	estimate "Age 12-17: After to Before, High Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 1 -1 0 0 0 0 0 0 0 
				mml_pass*restrict 1 0 -1 0 0 0
				age_grp*mml_pass*restrict 1 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 / cl;
	estimate "Age 12-17: After to Before, Low Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 1 -1 0 0 0 0 0 0 0 
				mml_pass*restrict 0 1 0 0 -1 0
				age_grp*mml_pass*restrict 0 1 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 / cl;
	estimate "Age 18-25: After to Before, High Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 0 0 0 1 -1 0 0 0 0 
				mml_pass*restrict 1 0 -1 0 0 0
				age_grp*mml_pass*restrict 0 0 0 0 0 0 1 0 -1 0 0 0 0 0 0 0 0 0 / cl; 
	estimate "Age 18-25: After to Before, Low Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 0 0 0 1 -1 0 0 0 0
				mml_pass*restrict 0 1 0 0 -1 0
				age_grp*mml_pass*restrict 0 0 0 0 0 0 0 1 0 0 -1 0 0 0 0 0 0 0 / cl; 
	estimate "Age 26+: After to Before, High Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 0 0 0 0 0 0 1 -1 0
				mml_pass*restrict 1 0 -1 0 0 0
				age_grp*mml_pass*restrict 0 0 0 0 0 0 0 0 0 0 0 0 1 0 -1 0 0 0 / cl; 
	estimate "Age 26+: After to Before, Low Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 0 0 0 0 0 0 1 -1 0
				mml_pass*restrict 0 1 0 0 -1 0
				age_grp*mml_pass*restrict 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 -1 0 / cl; ; 
run;

ods pdf close; 

*initiation binary model: first use; 

ods pdf file = "C:\Users\niwi8\OneDrive - cumc.columbia.edu\Practicum\MML_analysis\MML_chapman_index\reports\first_use\first_use_2003_2016_binary_initiation.pdf" style = journal2;

proc mixed data = first_use; 
	title "First use of marijuana: Cubic spline, age, binary initiation MML Chapman index";
	class abbrev age_grp mml_pass init_binary; 
	model use = yearcont yearcont*yearcont yearcont*yearcont*yearcont
				yearsp*yearsp*yearsp
				age_grp*yearcont age_grp*yearcont*yearcont age_grp*yearcont*yearcont*yearcont
				age_grp*yearsp*yearsp*yearsp
				age_grp mml_pass init_binary 
				age_grp*init_binary mml_pass*init_binary age_grp*mml_pass age_grp*mml_pass*init_binary / solution ddfm = bw; 
	random abbrev / group = age_grp; 
	*lsmeans age_grp*mml_pass*init_binary / pdiff cl; 
	estimate "Age 12-17: After to Before, High Initiation Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 1 -1 0 0 0 0 0 0 0 
				mml_pass*init_binary 1 0 -1 0 0 
				age_grp*mml_pass*init_binary 1 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 / cl;
	estimate "Age 12-17: After to Before, Low Initiation Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 1 -1 0 0 0 0 0 0 0 
				mml_pass*init_binary 0 1 0 -1 0 
				age_grp*mml_pass*init_binary 0 1 0 -1 0 0 0 0 0 0 0 0 0 0 0 / cl;
	estimate "Age 18-25: After to Before, High Initiation Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 0 0 0 1 -1 0 0 0 0 
				mml_pass*init_binary 1 0 -1 0 0 
				age_grp*mml_pass*init_binary 0 0 0 0 0 1 0 -1 0 0 0 0 0 0 0 / cl; 
	estimate "Age 18-25: After to Before, Low Initiation Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 0 0 0 1 -1 0 0 0 0
				mml_pass*init_binary 0 1 0 -1 0
				age_grp*mml_pass*init_binary 0 0 0 0 0 0 1 0 -1 0 0 0 0 0 0 / cl; 
	estimate "Age 26+: After to Before, High Initiation Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 0 0 0 0 0 0 1 -1 0
				mml_pass*init_binary 1 0 -1 0 0
				age_grp*mml_pass*init_binary 0 0 0 0 0 0 0 0 0 0 1 0 -1 0 0 / cl; 
	estimate "Age 26+: After to Before, Low Initiation Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 0 0 0 0 0 0 1 -1 0
				mml_pass*init_binary 0 1 0 -1 0
				age_grp*mml_pass*init_binary 0 0 0 0 0 0 0 0 0 0 0 1 0 -1 0 / cl; ; 
run;

ods pdf close; 

*initiation binary model (including new states): first use;

ods pdf file = "C:\Users\niwi8\OneDrive - cumc.columbia.edu\Practicum\MML_analysis\MML_chapman_index\reports\first_use\new_states_first_use_2003_2016_initiation_Chapman.pdf" style = journal2;

proc mixed data = first_use_newStates; 
	title "First use of marijuana (including new states): Cubic spline, age, binary initiation MML Chapman index";
	class abbrev age_grp mml_pass init_binary; 
	model use = yearcont yearcont*yearcont yearcont*yearcont*yearcont
				yearsp*yearsp*yearsp
				age_grp*yearcont age_grp*yearcont*yearcont age_grp*yearcont*yearcont*yearcont
				age_grp*yearsp*yearsp*yearsp
				age_grp mml_pass init_binary 
				age_grp*init_binary mml_pass*init_binary age_grp*mml_pass age_grp*mml_pass*init_binary / solution ddfm = bw; 
	random abbrev / group = age_grp; 
	*lsmeans age_grp*mml_pass*init_binary / pdiff cl; 
	estimate "Age 12-17: After to Before, High Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 1 -1 0 0 0 0 0 0 0 
				mml_pass*init_binary 1 0 -1 0 0 0
				age_grp*mml_pass*init_binary 1 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 / cl;
	estimate "Age 12-17: After to Before, Low Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 1 -1 0 0 0 0 0 0 0 
				mml_pass*init_binary 0 1 0 0 -1 0
				age_grp*mml_pass*init_binary 0 1 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 / cl;
	estimate "Age 18-25: After to Before, High Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 0 0 0 1 -1 0 0 0 0 
				mml_pass*init_binary 1 0 -1 0 0 0
				age_grp*mml_pass*init_binary 0 0 0 0 0 0 1 0 -1 0 0 0 0 0 0 0 0 0 / cl; 
	estimate "Age 18-25: After to Before, Low Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 0 0 0 1 -1 0 0 0 0
				mml_pass*init_binary 0 1 0 0 -1 0
				age_grp*mml_pass*init_binary 0 0 0 0 0 0 0 1 0 0 -1 0 0 0 0 0 0 0 / cl; 
	estimate "Age 26+: After to Before, High Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 0 0 0 0 0 0 1 -1 0
				mml_pass*init_binary 1 0 -1 0 0 0
				age_grp*mml_pass*init_binary 0 0 0 0 0 0 0 0 0 0 0 0 1 0 -1 0 0 0 / cl; 
	estimate "Age 26+: After to Before, Low Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 0 0 0 0 0 0 1 -1 0
				mml_pass*init_binary 0 1 0 0 -1 0
				age_grp*mml_pass*init_binary 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 -1 0 / cl; ; 
run;

ods pdf close; 

*quantity binary model: first use; 

ods pdf file = "C:\Users\niwi8\OneDrive - cumc.columbia.edu\Practicum\MML_analysis\MML_chapman_index\reports\first_use\first_use_2003_2016_binary_quantity.pdf" style = journal2;

proc mixed data = first_use; 
	title "First use of marijuana: Cubic spline, age, binary quantity MML Chapman index";
	class abbrev age_grp mml_pass quant_binary; 
	model use = yearcont yearcont*yearcont yearcont*yearcont*yearcont
				yearsp*yearsp*yearsp
				age_grp*yearcont age_grp*yearcont*yearcont age_grp*yearcont*yearcont*yearcont
				age_grp*yearsp*yearsp*yearsp
				age_grp mml_pass quant_binary 
				age_grp*quant_binary mml_pass*quant_binary age_grp*mml_pass age_grp*mml_pass*quant_binary / solution ddfm = bw outpm = pred; 
	random abbrev / group = age_grp;
	*lsmeans age_grp*mml_pass*quant_binary / pdiff cl; 
	estimate "AGE 12-17: After to Before, High Quantity Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 1 -1 0 0 0 0 0 0 0 
				mml_pass*quant_binary 1 0 -1 0 0 
				age_grp*mml_pass*quant_binary 1 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 / cl;
	estimate "AGE 12-17: After to Before, Low Quantity Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 1 -1 0 0 0 0 0 0 0 
				mml_pass*quant_binary 0 1 0 -1 0 
				age_grp*mml_pass*quant_binary 0 1 0 -1 0 0 0 0 0 0 0 0 0 0 0 / cl;
	estimate "AGE 18-25: After to Before, High Quantity Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 0 0 0 1 -1 0 0 0 0 
				mml_pass*quant_binary 1 0 -1 0 0 
				age_grp*mml_pass*quant_binary 0 0 0 0 0 1 0 -1 0 0 0 0 0 0 0 / cl; 
	estimate "AGE 18-25: After to Before, Low Quantity Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 0 0 0 1 -1 0 0 0 0 
				mml_pass*quant_binary 0 1 0 -1 0
				age_grp*mml_pass*quant_binary 0 0 0 0 0 0 1 0 -1 0 0 0 0 0 0 / cl; 
	estimate "Age 26+: After to Before, High Quantity Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 0 0 0 0 0 0 1 -1 0
				mml_pass*quant_binary 1 0 -1 0 0
				age_grp*mml_pass*quant_binary 0 0 0 0 0 0 0 0 0 0 1 0 -1 0 0 / cl; 
	estimate "Age 26+: After to Before, Low Quantity Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 0 0 0 0 0 0 1 -1 0
				mml_pass*quant_binary 0 1 0 -1 0
				age_grp*mml_pass*quant_binary 0 0 0 0 0 0 0 0 0 0 0 1 0 -1 0 / cl; ; 
run; 

ods pdf close; 

*quantity binary model (including new states): past month use; 

ods pdf file = "C:\Users\niwi8\OneDrive - cumc.columbia.edu\Practicum\MML_analysis\MML_chapman_index\reports\first_use\new_states_first_use_2003_2016_quantity_Chapman.pdf" style = journal2;

proc mixed data = first_use_newStates; 
	title "First use of marijuana (including new states): Cubic spline, age, binary quantity MML Chapman index";
	class abbrev age_grp mml_pass quant_binary; 
	model use = yearcont yearcont*yearcont yearcont*yearcont*yearcont
				yearsp*yearsp*yearsp
				age_grp*yearcont age_grp*yearcont*yearcont age_grp*yearcont*yearcont*yearcont
				age_grp*yearsp*yearsp*yearsp
				age_grp mml_pass quant_binary 
				age_grp*quant_binary mml_pass*quant_binary age_grp*mml_pass age_grp*mml_pass*quant_binary / solution ddfm = bw; 
	random abbrev / group = age_grp; 
	*lsmeans age_grp*mml_pass*quant_binary / pdiff cl; 
	estimate "Age 12-17: After to Before, High Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 1 -1 0 0 0 0 0 0 0 
				mml_pass*quant_binary 1 0 -1 0 0 0
				age_grp*mml_pass*quant_binary 1 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 / cl;
	estimate "Age 12-17: After to Before, Low Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 1 -1 0 0 0 0 0 0 0 
				mml_pass*quant_binary 0 1 0 0 -1 0
				age_grp*mml_pass*quant_binary 0 1 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 / cl;
	estimate "Age 18-25: After to Before, High Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 0 0 0 1 -1 0 0 0 0 
				mml_pass*quant_binary 1 0 -1 0 0 0
				age_grp*mml_pass*quant_binary 0 0 0 0 0 0 1 0 -1 0 0 0 0 0 0 0 0 0 / cl; 
	estimate "Age 18-25: After to Before, Low Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 0 0 0 1 -1 0 0 0 0
				mml_pass*quant_binary 0 1 0 0 -1 0
				age_grp*mml_pass*quant_binary 0 0 0 0 0 0 0 1 0 0 -1 0 0 0 0 0 0 0 / cl; 
	estimate "Age 26+: After to Before, High Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 0 0 0 0 0 0 1 -1 0
				mml_pass*quant_binary 1 0 -1 0 0 0
				age_grp*mml_pass*quant_binary 0 0 0 0 0 0 0 0 0 0 0 0 1 0 -1 0 0 0 / cl; 
	estimate "Age 26+: After to Before, Low Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 0 0 0 0 0 0 1 -1 0
				mml_pass*quant_binary 0 1 0 0 -1 0
				age_grp*mml_pass*quant_binary 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 -1 0 / cl; ; 
run;

ods pdf close; 

*distribution binary model: first use; 

ods pdf file = "C:\Users\niwi8\OneDrive - cumc.columbia.edu\Practicum\MML_analysis\MML_chapman_index\reports\first_use\first_use_2003_2016_binary_distribution.pdf" style = journal2;

proc mixed data = first_use; 
	title "First use of marijuana: Cubic spline, age, binary distribution MML Chapman index";
	class abbrev age_grp mml_pass dist_binary; 
	model use = yearcont yearcont*yearcont yearcont*yearcont*yearcont
				yearsp*yearsp*yearsp
				age_grp*yearcont age_grp*yearcont*yearcont age_grp*yearcont*yearcont*yearcont
				age_grp*yearsp*yearsp*yearsp
				age_grp mml_pass dist_binary 
				age_grp*dist_binary mml_pass*dist_binary age_grp*mml_pass age_grp*mml_pass*dist_binary / solution ddfm = bw outpm = pred; 
	random abbrev / group = age_grp;
	*lsmeans age_grp*mml_pass*dist_binary / pdiff cl; 
	estimate "Age 12-17: After to Before, High Distribution Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 1 -1 0 0 0 0 0 0 0 
				mml_pass*dist_binary 1 0 -1 0 0 
				age_grp*mml_pass*dist_binary 1 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 / cl;
	estimate "Age 12-17: After to Before, Low Distribution Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 1 -1 0 0 0 0 0 0 0 
				mml_pass*dist_binary 0 1 0 -1 0 
				age_grp*mml_pass*dist_binary 0 1 0 -1 0 0 0 0 0 0 0 0 0 0 0 / cl;
	estimate "Age 18-25: After to Before, High Distribution Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 0 0 0 1 -1 0 0 0 0 
				mml_pass*dist_binary 1 0 -1 0 0 
				age_grp*mml_pass*dist_binary 0 0 0 0 0 1 0 -1 0 0 0 0 0 0 0 / cl; 
	estimate "Age 18-25: After to Before, Low Distribution Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 0 0 0 1 -1 0 0 0 0 
				mml_pass*dist_binary 0 1 0 -1 0
				age_grp*mml_pass*dist_binary 0 0 0 0 0 0 1 0 -1 0 0 0 0 0 0 / cl; 
	estimate "Age 26+: After to Before, High Distribution Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 0 0 0 0 0 0 1 -1 0
				mml_pass*dist_binary 1 0 -1 0 0
				age_grp*mml_pass*dist_binary 0 0 0 0 0 0 0 0 0 0 1 0 -1 0 0 / cl; 
	estimate "Age 26+: After to Before, Low Distribution Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 0 0 0 0 0 0 1 -1 0
				mml_pass*dist_binary 0 1 0 -1 0
				age_grp*mml_pass*dist_binary 0 0 0 0 0 0 0 0 0 0 0 1 0 -1 0 / cl; ; 
run; 

ods pdf close;

*distribution binary model (including new states): first use; 

ods pdf file = "C:\Users\niwi8\OneDrive - cumc.columbia.edu\Practicum\MML_analysis\MML_chapman_index\reports\first_use\new_states_first_use_2003_2016_distribution_Chapman.pdf" style = journal2;

proc mixed data = first_use_newStates; 
	title "First use of marijuana (including new states): Cubic spline, age, binary distribution MML Chapman index";
	class abbrev age_grp mml_pass dist_binary; 
	model use = yearcont yearcont*yearcont yearcont*yearcont*yearcont
				yearsp*yearsp*yearsp
				age_grp*yearcont age_grp*yearcont*yearcont age_grp*yearcont*yearcont*yearcont
				age_grp*yearsp*yearsp*yearsp
				age_grp mml_pass dist_binary 
				age_grp*dist_binary mml_pass*dist_binary age_grp*mml_pass age_grp*mml_pass*dist_binary / solution ddfm = bw; 
	random abbrev / group = age_grp; 
	*lsmeans age_grp*mml_pass*dist_binary / pdiff cl; 
	estimate "Age 12-17: After to Before, High Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 1 -1 0 0 0 0 0 0 0 
				mml_pass*dist_binary 1 0 -1 0 0 0
				age_grp*mml_pass*dist_binary 1 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 / cl;
	estimate "Age 12-17: After to Before, Low Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 1 -1 0 0 0 0 0 0 0 
				mml_pass*dist_binary 0 1 0 0 -1 0
				age_grp*mml_pass*dist_binary 0 1 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 / cl;
	estimate "Age 18-25: After to Before, High Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 0 0 0 1 -1 0 0 0 0 
				mml_pass*dist_binary 1 0 -1 0 0 0
				age_grp*mml_pass*dist_binary 0 0 0 0 0 0 1 0 -1 0 0 0 0 0 0 0 0 0 / cl; 
	estimate "Age 18-25: After to Before, Low Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 0 0 0 1 -1 0 0 0 0
				mml_pass*dist_binary 0 1 0 0 -1 0
				age_grp*mml_pass*dist_binary 0 0 0 0 0 0 0 1 0 0 -1 0 0 0 0 0 0 0 / cl; 
	estimate "Age 26+: After to Before, High Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 0 0 0 0 0 0 1 -1 0
				mml_pass*dist_binary 1 0 -1 0 0 0
				age_grp*mml_pass*dist_binary 0 0 0 0 0 0 0 0 0 0 0 0 1 0 -1 0 0 0 / cl; 
	estimate "Age 26+: After to Before, Low Restrictiveness" 
				mml_pass 1 -1 0 
				age_grp*mml_pass 0 0 0 0 0 0 1 -1 0
				mml_pass*dist_binary 0 1 0 0 -1 0
				age_grp*mml_pass*dist_binary 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 -1 0 / cl; ; 
run;

ods pdf close; 
