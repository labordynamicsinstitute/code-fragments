options msglevel=i;

data data1;
input a b ;
cards;
1 1.1
1 1.2
1 1.3
2 2.1
2 2.2
3 3.1
4 4.1
4 4.2
4 4.3
4 4.4
;

data data2;
input a c $;
cards;
1 Number1
4 Number4
2 Number2
3 Number3
;


title1 "Testing different double sets";
title2 "Data1: Large master data set";
proc print data=data1;

title2 "Data2: small lookup data set";
proc print data=data2;

proc datasets lib=work;
modify data1;
index create a;
modify data2;
index create a;
run;

title2 "----- first test -----";
data test;
set data2;
    set data1 key=a;
run;

proc print data=test;
run;

title2 "-----  second test  -----";

data test;
set data2;
    set data1 key=a/unique;
run;

proc print data=test;
run;

title2 "-----  third test  -----";

data test;
set data2;
do while ( _iorc_ =0 );
    set data1 key=a;
    output;
end;
if _iorc_ ne 0 then do;
    _error_ =0;
    delete;
end;
run;

proc print data=test;
run;

title2 "-----  fourth test  -----";

data test;
set data2;
continue=0;
do while ( continue=0 );
    set data1 key=a;
    if _iorc_ = 0 then do;
	output;
	end;
    else do;
       _error_=0;
       continue=1;
    end;
end;
run;

proc print data=test;
run;

