/*------------------------------------
		Rideshare EDA
-------------------------------------*/

/* Summary Statistics */

ods noproctitle;
ods graphics / imagemap=on;

proc means data=MKTG525.RIDESHARE chartype mean std min max median n nmiss 
		vardef=df q1 q3 qmethod=os;
	var dateTime hour day month price distance surgeMultiplier temperature 
		precipProbability humidity windSpeed windGust ozone;
run;

proc univariate data=MKTG525.RIDESHARE vardef=df noprint;
	var dateTime hour day month price distance surgeMultiplier temperature 
		precipProbability humidity windSpeed windGust ozone;
	histogram dateTime hour day month price distance surgeMultiplier temperature 
		precipProbability humidity windSpeed windGust ozone / normal(noprint);
run;

/* Frequency distribution */

proc freq data=MKTG525.RIDESHARE order=freq;
	tables weekday source destination rideshare rideCategory weather / missing 
		plots=(freqplot cumfreqplot);
run;