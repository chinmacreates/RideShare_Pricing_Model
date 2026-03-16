/********************************************************************************
						Rideshare Predictive Regression
							A pricing model analysis
********************************************************************************/

/*Step 1- Feature Engineering */
/* Filter and Clean the Data */
PROC SQL;
Create Table Rideshare_C as
	Select*
	From MKTG525.RIDESHARE
	WHERE distance <= 7.83 /*outliers located past these points */
	AND surgeMultiplier <= 1.36
;
Quit;

/* Recoding variables */
PROC SQL;
Create Table Rideshare_R as 
	Select dateTime, hour, day, price, distance, surgeMultiplier, temperature, 
		precipProbability, humidity, windSpeed, windGust, ozone, /* selects these columns */
/* Month dummy variables */
        CASE WHEN month = 8  THEN 1 ELSE 0 END AS August,
        CASE WHEN month = 9  THEN 1 ELSE 0 END AS September,
        CASE WHEN month = 10 THEN 1 ELSE 0 END AS October,
        CASE WHEN month = 11 THEN 1 ELSE 0 END AS November,
        CASE WHEN month = 12 THEN 1 ELSE 0 END AS December,
	
/*creating dummy variables for categorical variables */
		CASE When weekday= 'Sun' then 1 else 0 end as Sunday,
		CASE When weekday= 'Thur' then 1 else 0 end as Thursday, 
		CASE When weekday= 'Wed' then 1 else 0 end as Wednesday, 
		CASE When weekday= 'Fri' then 1 else 0 end as Friday,
		CASE When weekday NOT IN ('Sun','Mon','Thur','Fri') THEN 1 ELSE 0 END AS Other_Weekday,
		
		CASE When source= 'North Station' then 1 else 0 end as North_Station_s, 
		CASE When source= 'Theatre District' then 1 else 0 end as Theatre_District_s, 
		CASE When source= 'West End' then 1 else 0 end as West_End_s, 
		CASE When source= 'Beacon Hill' then 1 else 0 end as Beacon_Hill_s, 
		CASE When source= 'Haymarket Square' then 1 else 0 end as Haymarket_Square_s, 
		CASE When source= 'Fenway' then 1 else 0 end as Fenway_s, 
		CASE When source= 'North End' then 1 else 0 end as North_End_s, 
		CASE WHEN source NOT IN ('North Station','Theatre District','West End','Beacon Hill', 'Haymarket Square','Fenway','North End') 
		THEN 1 ELSE 0 END AS Other_Source,
		
		CASE When destination= 'North End' then 1 else 0 end as North_End_d, 
		CASE When destination= 'Haymarket Square' then 1 else 0 end as Haymarket_Square_d, 
		CASE When destination= 'Northeastern University' then 1 else 0 end as Northeastern_University_d, 
		CASE When destination= 'Fenway' then 1 else 0 end as Fenway_d, 
		CASE When destination= 'North Station' then 1 else 0 end as North_Station_d, 
		CASE When destination= 'Theatre District' then 1 else 0 end as Theatre_District_d, 
		CASE When destination= 'Beacon Hill' then 1 else 0 end as Beacon_Hill_d, 
		CASE WHEN destination NOT IN ('North End','Northeastern University','Fenway','Beacon Hill', 'Haymarket Square','Theatre District','North Station') 
		THEN 1 ELSE 0 END AS Other_Destination,
		
		CASE When rideshare= 'Uber' then 1 else 0 end as Uber,
		CASE When rideshare = 'Lyft' then 1 else 0 end as Lyft,
		
		CASE When rideCategory= 'Lyft' then 1 else 0 end as Lyft_c, 
		CASE When rideCategory= 'Black' then 1 else 0 end as Black, 
		CASE When rideCategory= 'Black SUV' then 1 else 0 end as Black_SUV, 
		CASE When rideCategory= 'Uber Pool' then 1 else 0 end as Uber_Pool, 
		CASE When rideCategory= 'WAV' then 1 else 0 end as WAV,
		CASE WHEN rideCategory NOT IN ('Uber','Lyft','Black','Black SUV', 'Uber Pool','WAV') 
		THEN 1 ELSE 0 END AS Other_rideCategory,
		
		CASE When weather= 'cloudy' then 1 else 0 end as cloudy, 
		CASE When weather= 'partly-cloudy-night' then 1 else 0 end as partly_cloudy_night, 
		CASE When weather= 'partly-cloudy-day' then 1 else 0 end as partly_cloudy_day,
		CASE WHEN weather NOT IN ('cloudy','partly-cloudy-night','partly-cloudy-day') 
		THEN 1 ELSE 0 END AS Other_weather

FROM RIDESHARE_C;
Quit;

/* Step 2 - Feature Selection */

/*Correlation Analysis of independent variables with the dependent variable*/
	ods noproctitle;
ods graphics / imagemap=on;

proc corr data=RIDESHARE_R pearson nosimple noprob plots=none;
	var dateTime hour day August September October November December distance surgeMultiplier temperature 
		precipProbability humidity windSpeed windGust ozone Sunday Thursday Wednesday 
		Friday Other_Weekday North_Station_s Theatre_District_s West_End_s Beacon_Hill_s 
		Haymarket_Square_s Fenway_s North_End_s Other_Source North_End_d Haymarket_Square_d 
		Northeastern_University_d Fenway_d North_Station_d Theatre_District_d 
		Beacon_Hill_d Other_Destination Uber Lyft Lyft_c Black Black_SUV Uber_Pool WAV Other_rideCategory cloudy 
		partly_cloudy_night partly_cloudy_day Other_weather;
	with price;
run;


/* Correlation Analysis of independent variables */
ods noproctitle;
ods graphics / imagemap=on;

proc corr data=RIDESHARE_R pearson nosimple noprob plots=none;
	var October November distance ;
	
run;


/* Step 3- Model building & Model validation */
/*Regression Analysis */

/* None */
ods noproctitle;
ods graphics / imagemap=on;
filename sfile '/home/u64333303/score.sas';

proc glmselect data=RIDESHARE_R;
	partition fraction(validate=0.3);
	model price=distance November / selection=none;
	score out=work.rideshare_none_stats predicted residual;
	code file=sfile;
run;

filename sfile CLEAR;

/* Forward selection */
ods noproctitle;
ods graphics / imagemap=on;
filename sfile '/home/u64333303/score.sas';

proc glmselect data=RIDESHARE_R plots=(criterionpanel);
	partition fraction(validate=0.3);
	model price=distance November / selection=forward

(select=sbc) hierarchy=single;
	score out=work.rideshare_bw_stats predicted residual;
	code file=sfile;
run;

filename sfile CLEAR;

/* Backward Elimination */
ods noproctitle;
ods graphics / imagemap=on;
filename sfile '/home/u64333303/score.sas';

proc glmselect data=RIDESHARE_R plots=(criterionpanel);
	partition fraction(validate=0.3);
	model price=distance November / selection=backward

(select=sbc) hierarchy=single;
	score out=work.rideshare_bw_stats predicted residual;
	code file=sfile;
run;

filename sfile CLEAR;

/* Stepwise */
ods noproctitle;
ods graphics / imagemap=on;
filename sfile '/home/u64333303/score.sas';

proc glmselect data=RIDESHARE_R plots=(criterionpanel);
	partition fraction(validate=0.3);
	model price=distance November / selection=stepwise

(select=sbc) hierarchy=single;
	score out=work.rideshare_sw_stats predicted residual;
	code file=sfile;
run;

filename sfile CLEAR;

