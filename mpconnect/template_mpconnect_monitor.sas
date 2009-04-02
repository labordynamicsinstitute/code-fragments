/* $Id$ */
/* $URL$ */
/* $Author$ */
options mprint mlogic symbolgen sascmd='sas -cpucount 1 -work ~/tmp' autosignon;

/*============================================================*/
/* Spawns off MP/Connect jobs, keeping track of what was      */
/* spawned off, and collects them. Monitoring is at fixed     */
/* granularity, but can be modified on the fly. Note that     */
/* if the checking is TOO fast, jobs may be submitted multiple*/
/* times!                                                     */
/*                                                            */
/* Parameters:
     maxjobs - how many jobs to keep running at the same time
     frequency - how frequently to check jobs
     mpconnect - if using MP/Connect (instead of sequential)
*/
/*============================================================*/

%macro rloop(maxjobs=2,frequency=30,mpconnect=yes);

%if ( "&maxjobs." = "1" ) %then %let mpconnect=no;
%else %let mpconnect=&mpconnect.;

%let thisdir=%sysget(PWD);
%let mywork=%sysfunc(pathname(work));

%put thisdir=&thisdir.;
%put mywork=&mywork.;

/*============================================================*/
/* Where to store the local metadata                          */
/*============================================================*/

%let metadir=&thisdir.;
%put metadir=&metadir.;
libname metadata "&metadir.";
libname metaread "&metadir." access=readonly;

/*============================================================*/
/* start the meta database n-dimensional                      */
/* Additional job parameters could be stuck in there,             
   and a more convenient job identifier if too many params    
   If only using a single job database, this needs to be fully
   expanded, and all parameters available here. In this setup,
   this database is accessible by all MP/Connect jobs, so
   job parameters do NOT need to be pushed via SYSLPUT. Use 
   METAREAD when only wanting to query, to minize the likelihood
   of any write conflict, and use PROC SQL for better record-
   level control. If too many jobs are likely to enter into 
   conflict, modify this program to spawn off a SAS/Share 
   server instead. */
/*============================================================*/

data METADATA.metadata;
     length mpconnect $ 3;
     do i = 1 to 5;
        do j = 1 to 4;
	completed=.;
	running=.;
	jobid=.;
	label i = "Parameter i"
              j = "Parameter j"
	      completed = "Has job completed? miss/0/1"
	      running = "Is job running? miss/0/1"
	      jobid = "Unix job id"
	      start_time = "Start time of job"
	      end_time = "End time of job"
	      mpconnect = "MP/Connect job: yes/no"
	      ;
	start_time=.;
	end_time=.;      
	mpconnect="";
	output;
	end;
     end;
run;

/*============================================================*/
/* tuning the process via another metadata database.
   This can be changed during the running of the process      */
/*============================================================*/

data METADATA.metadata_ctrl;
     length parameter value $ 30 ;
     parameter="maxjobs";
     value="&maxjobs.";
     output;

     parameter="mpconnect";
     value="&mpconnect.";
     output;

     parameter="frequency";
     value="&frequency.";
     output;
run;

/*============================================================*/
/* We write out two little utility programs that can be used
   to tune the scheduling.*/
/*============================================================*/
data _null_;
     file "&thisdir./modify_metadata_ctrl.sas" ;
put "/* This file can be used to finetune the scheduling */ ";
put "/* Use wisely! */";
put "libname here '.';                                    ";
put "data here.metadata_ctrl;";
put "modify here.metadata_ctrl(where=(parameter='maxjobs'));";
put "value='12';";
put "run;";
run;

data _null_;
     file "&thisdir./modify_metadata.sas" ;
put "/* This file can be used to reset a job's status */ ";
put "/* Use wisely! */";
put "libname here '.';                                    ";
put "data here.metadata;";
put "modify here.metadata(where=(i=1 and j=1));";
put "completed=.;";
put "running=.;";
put "run;";
run;

/*============================================================*/
/* To cleanly lock the database. From
   http://www.lexjansen.com/pharmasug/2005/posters/po33.pdf
*/
/*============================================================*/
%include "&thisdir./trylock.sas";

/*============================================================*/
/* For completeness, we also have a complementary macro       */
/*============================================================*/
%include "&thisdir./unlock.sas";


/*============================================================*/
/* Now run through the database, check against number of
   maxjobs, and spawn off any difference                      */
/*============================================================*/
%let jobs_running=1;

%do %while ( &jobs_running. = 1 );

/*--------------------------------------------------*/
/* check how many jobs are running */
/*--------------------------------------------------*/

/* make a copy so it doesn't change on us */

%trylock(member=METAREAD.metadata);
data metadata_tmp;
     set METAREAD.metadata(where=(running=1));
run;
%unlock(member=METAREAD.metadata);

%let fileid=%sysfunc(open(WORK.metadata_tmp(where=(running=1))));
%let NObs=%sysfunc(attrn(&fileid,NLOBSF));
%let fileid=%sysfunc(close(&fileid)); 

%put %upcase(info)::: &NObs jobs appear to be running.;

%let fileid=%sysfunc(open(WORK.metadata_tmp(where=(running=1 and end_time ne .))));
%let NObs=%sysfunc(attrn(&fileid,NLOBSF));
%let fileid=%sysfunc(close(&fileid)); 

%put %upcase(info)::: &NObs jobs may have completed. Checking.;


%if ( &NObs. > 0 ) %then %do;
    /*--------------------------------------------------*/
    /* we need to update the metadata. Two options:
         verifying output, or having the spawned-off 
         job write directly to the metadata. In this 
         example, we choose the latter. */ 
    /*--------------------------------------------------*/
   
   %do pickup = 1 %to &NObs.;

       %put %upcase(info)::: checking for output of job &pickup. of &NObs.;

       data _null_;
            set WORK.metadata_tmp(where=(running=1 and end_time ne .) obs=&pickup.);
	    if _n_ = &pickup.;
            call symput('i',trim(left(i)));
            call symput('j',trim(left(j)));
	    call symput('_mpconnect',trim(left(mpconnect)));
       put "%upcase(info)::: Job &pickup of &NObs. "  i= j= "has completed " completed=;
       run;

       
       /* get log files if the job was spawned off  using mpconnect */
        %if ( &_mpconnect = yes ) %then %do;
           WAITFOR run&i.&j.;
           RGET run&i.&j.;
           SIGNOFF run&i.&j.;
        %end;

	%trylock(member=METADATA.metadata);

	proc sql;
	    update METADATA.metadata
	    set
            running=0, jobid=., mpconnect=''
            where (i=&i. and j=&j.)
	    ;
	    update METADATA.metadata
	    set
	       completed = 1 
	    /* this will be set to zero if failed */
            where (i=&i. and j=&j. and  completed = .)
	    ;
	quit;

	%unlock(member=METADATA.metadata);
       
   %end; /* end pickup */
%end; /* end NOBS>0 */

/*============================================================*/
/* We've checked all running jobs, updated the database.      
   Let's check again, to find out how many jobs to spawn off. */
/*============================================================*/
/* check how many jobs are running */

%let fileid=%sysfunc(open(METADATA.metadata(where=(running=1))));
%let runningNObs=%sysfunc(attrn(&fileid,NLOBSF));
%let fileid=%sysfunc(close(&fileid)); 

%put %upcase(info)::: &runningNObs jobs still running.;

/*============================================================*/
/* We again check against our ctrl parameters 
   to pick up any changes                */
/*============================================================*/

data _null_;
     set METADATA.metadata_ctrl;
     call symput(trim(left(parameter)),trim(left(value)));
     put "%upcase(info)::: Current parameters:" parameter "=" value;
run;

%if ( &maxjobs. < &runningNObs. ) %then %do;

    /* warn the user somehow. For example, by writing to log */
    %put %upcase(warn)::: There are only &maxjobs. allowed to be running.;
    %put %upcase(warn)::: Please make certain that this is expected.;
    %let newjobs=0;

%end;
%else %let newjobs=%eval(&maxjobs.-&runningNObs.);

/*============================================================*/
/* We have identified the number of jobs that we can run      */
/* Now we check if we have any jobs left to spawn             */
/*============================================================*/

%let fileid=%sysfunc(open(METADATA.metadata(where=(completed  ne 1 and
running ne 1))));
%let availNObs=%sysfunc(attrn(&fileid,NLOBSF));
%let fileid=%sysfunc(close(&fileid)); 

%put %upcase(info)::: &availNObs jobs available for submission.;
%put %upcase(info)::: &newjobs can be submitted at this time.;


/*============================================================*/
/* Now we spawn them off                                      */
/*============================================================*/

%if ( &availNObs. = 0 and &runningNObs. = 0 ) %then %let jobs_running=0;

%if ( &newjobs > 0 and &availNObs > 0 ) %then %do;
       proc datasets library=work nolist;
       delete spawn;
       quit;
       

       %trylock(member=METAREAD.metadata);
       data WORK.spawn;
            set METAREAD.metadata(where=
		(running ne 1 
			 and completed ne 1 
			 and completed ne 0) 
		obs=&newjobs.);
		submitted=0;
		call symput('spawnmax',_n_);
       run;
       %unlock(member=METAREAD.metadata);

       /* run through the spawn dataset */
       %do spawn=1 %to &spawnmax.;
       
       data _null_;
	    set WORK.spawn(where=(submitted=0) obs=1);
	    call symput('i',trim(left(i)));
	    call symput('j',trim(left(j)));
	    /* pull any other info out here as well */
	    put "%upcase(info)::: Submitting job " i= j=;
       run;

        %if ( &mpconnect = yes ) %then %do;
            /*---------- SIGNON ----------*/
            SIGNON run&i.&j.;
            %syslput thisdir=%QUOTE(&thisdir.)/REMOTE=run&i.&j.;
            %syslput metadir=%QUOTE(&metadir.)/REMOTE=run&i.&j.;
            %syslput mpconnect=&mpconnect./REMOTE=run&i.&j.;
            %syslput i=&i./REMOTE=run&i.&j.;
            %syslput j=&j./REMOTE=run&i.&j.;
	    %syslput mywork=%QUOTE(&mywork.)/REMOTE=run&i.&j.;
            RSUBMIT run&i.&j. WAIT=NO;
            options obs=max;
	    libname METADATA "&metadir";
            %include "&thisdir./trylock.sas";
            %include "&thisdir./unlock.sas";
        %end; /* end of mpconnect config */

data _null_;
        file "/ramdisk/job_i&i._j&j..alive";
	put "alive: j=&j. i=&i. thisdir=&thisdir. mywork=&mywork.";
run;

	proc printto log="/ramdisk/job_i&i._j&j..log" new;
	run;

	/* update metadata, after a random wait */
	data _null_;
	sleeping=ranuni(int(datetime()))*10;
	put "%upcase(info)::: " sleeping=;
	why=sleep(sleeping,1);
	run;

	%trylock(member=METADATA.metadata);

	proc sql;
	     update METADATA.metadata
	     set
	     start_time=datetime(),
	     end_time=.,
	     running=1,
	     completed=.,
	     jobid=&sysjobid.,
	     mpconnect="&mpconnect."
            where (i=&i. and j=&j.)
	    ;
       quit;

	%unlock(member=METADATA.metadata);

data one;
        do i =1 to 10000;
	do j=1 to &j.*100;
        k=ranuni(today());
        output;
        end;
	end;
run;

proc sort data=one out=two;
by k;
run;



      /* update the metadata with the end time */
	/* capture error */
        %let obs_option=%sysfunc(getoption(obs)); 
	options obs=max;

	data _null_;
	sleeping=ranuni(int(datetime()))*10;
	put "%upcase(info)::: " sleeping=;
	why=sleep(sleeping,1);
	run;
	%trylock(member=METADATA.metadata);

       %if ( &obs_option. = 0 ) %then %do;

       proc sql;
	    update METADATA.metadata
	    set
              completed=0 ,
	      end_time=datetime()
            where (i=&i. and j=&j.)
	    ;
       quit;

       %end;
       %else %do;
       proc sql;
            update METADATA.metadata
	    set end_time=datetime()
            where (i=&i. and j=&j.)
	    ;
	    quit;

       %end;

	%unlock(member=METADATA.metadata);

	proc printto log=log;
	run;

        %if ( &mpconnect = yes ) %then %do;
            ENDRSUBMIT;
        %end; /* end of mpconnect config */

	/* end of spawn */

	data WORK.spawn;
	     modify WORK.spawn(where=(i=&i. and j=&j.));
	     submitted=1;
	     run;

        %end; /* end spawn */

%end; /* end of newjobs>0 */

%if ( &jobs_running. = 1 ) %then %do;
%put %upcase(info)::: Sleeping for &frequency. seconds;


data _null_;
     i=sleep(&frequency.,1);
     run;
%end; /* end of  %if ( &jobs_running. = 1 ) */


%end; /* end of  %while ( &jobs_running. = 1 ) */

%put %upcase(info)::: Ending processing,  &availNObs jobs available for submission.;

%mend;

%rloop(maxjobs=3,frequency=10);

proc print data=METADATA.metadata;
format start_time end_time datetime18.;
run;
