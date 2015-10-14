/* A program to map stuff in SAS */
/* author: Lars Vilhuber */

%include "brewer.sas";

/* prepare data */
data mydata;
	/* use county level, all demo groups, all industries */
	set OUTPUTS.qwi_us_wia_county(rename=(county=county_char state=state_char));

  /* compute any variables here */
	eb2=(e+b)/2;
	wrr = ( a + s ) /eb2 * 100;
	label wrr ="Worker reallocation rate";

  /* convert county and state to numeric for merge */
	county=county_char*1;
	state=state_char*1;

	/* exclude some states - for cleaner mapping of continental 48 */
	if state not in ( 2, 15, 72);
run;

/* prepare merge */
proc sort data=mydata;
by state county;

/* use SAS provided "shape" files */
proc sort data=maps.counties out=counties;
by state county;
run;

/* this part is just to see if we cover all the relevant geo entities */
data test;
	merge mydata(keep=wrr state county in=a)
	counties(in=b);
	by state county;
	_merge=a+2*b;
run;

proc freq;
table _merge;
run;

/* project it nicely */
proc gproject data=maps.counties(where=(state not in (2, 15, 72))) out=counties_proj
  parallel1 = 35 parallel2=50 project=albers;
  id state county;
run;

goptions reset=all device=png gsfname=gout xpixels=1600 ypixels=800;
filename gout "graphs/mygraph.png";

proc gmap map=counties_proj data=mydata(where=(wrr ne .));
title "Worker reallocation rates by county";
id state county;
choro wrr/levels=10;
run;
