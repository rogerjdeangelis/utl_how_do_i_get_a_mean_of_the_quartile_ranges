How do I get a Mean of the Quartile Ranges

Dumb example but still comprehensive.

 1.  SAS/IML/R or WPS/PROC R
 2.  WPS/SAS base  (exactly the same output)

Interesting note
    SAS ranks start with 0
    R starts with 1?

see
https://goo.gl/tNX8y9
https://communities.sas.com/t5/Base-SAS-Programming/How-do-I-get-a-Mean-of-the-Quartile-Range/m-p/428983

see
https://stackoverflow.com/questions/19598544/compute-the-average-for-quantiles
Matthew Plourde profile
https://stackoverflow.com/users/433829/matthew-plourde

INPUT
=====

SD1.HAVE total obs=100

  Obs      X    |    RULES
                |
    1      1    |    Slice have into quarters and
    2      2    |    compute the average of each quarters observartions
    3      3    |
    4      4    |    Using the young Gauss formula to check
   ...    ..    |
                |    (26*12 + 13)/25  = 13 = q1 mean
   98     98    |    (76*12 + 38)/25  = 38 = q2 mean
   99     99    |
  100    100    |    Q1 Add pairs (1+25) + (2+24) ... (12+14) + 13)odd man out) /25 =13


PROCESS
========

  WPS/PROC R

    qs <- quantile(have$X, seq(from = 0, to = .99, by = 0.25));
    want<-(have$X, findInterval(have$X, qs), mean);

  WPS/SAS Base

    proc format;
        value Rank
          0-24    = "Q1"  /* SAS has ranks starting at 0 */
          25-49   = "Q2"
          50-74   = "Q3"
          75-100  = "Q4" ;
    run;quit;

    proc rank data=sd1.have out=intermediate groups=100 ;
      var x;    /* variable on which to group */
      ranks rank_x;  /* name of variable to contain groups 0,1,...,k-1 */
    run;quit;

    proc summary data=intermediate n mean maxdec=2 nway;
        format rank_x Rank.;
        Class rank_x ;
        Var x;
        output out=wrk.want_basewps(drop=_:) mean=;
    run;quit;

OUTPUT
======

 WPS/PROC R

   WORK.WANT_PROCR total obs=1

      V1    V2    V3    V4

      13    38    63    88


  WPS/SAS Base (same output)

   WANT_BASE total obs=4

      RANK_X     X

         0      13
        25      38
        50      63
        75      88


*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.have;
  do x=1 to 100;
    output;
  end;
run;quit;

*____
|  _ \
| |_) |
|  _ <
|_| \_\

;

%utl_submit_wps64('
libname sd1 sas7bdat "d:/sd1";
options set=R_HOME "C:/Program Files/R/R-3.3.2";
libname wrk sas7bdat "%sysfunc(pathname(work))";
proc r;
submit;
source("C:/Program Files/R/R-3.3.2/etc/Rprofile.site", echo=T);
library(haven);
have<-read_sas("d:/sd1/have.sas7bdat");
qs <- quantile(have$X, seq(from = 0, to = .99, by = 0.25));
want<-t(tapply(have$X, findInterval(have$X, qs), mean));
endsubmit;
import r=want data=wrk.want_procR;
run;quit;
');

proc print data=want_procR width=min;
run;quit;

*                      __               _
__      ___ __  ___   / /__  __ _ ___  | |__   __ _ ___  ___
\ \ /\ / / '_ \/ __| / / __|/ _` / __| | '_ \ / _` / __|/ _ \
 \ V  V /| |_) \__ \/ /\__ \ (_| \__ \ | |_) | (_| \__ \  __/
  \_/\_/ | .__/|___/_/ |___/\__,_|___/ |_.__/ \__,_|___/\___|
         |_|
;

%utl_submit_wps64('
libname sd1 sas7bdat "d:/sd1";
libname wrk sas7bdat "%sysfunc(pathname(work))";
proc format;
    value Rank
      0-24    = "Q1"  /* SAS has ranks starting at 0 */
      25-49   = "Q2"
      50-74   = "Q3"
      75-100  = "Q4" ;
run;quit;

proc rank data=sd1.have out=intermediate groups=100 ;
  var x;    /* variable on which to group */
  ranks rank_x;  /* name of variable to contain groups 0,1,...,k-1 */
run;quit;

proc summary data=intermediate n mean maxdec=2 nway;
    format rank_x Rank.;
    Class rank_x ;
    Var x;
    output out=wrk.want_basewps(drop=_:) mean=;
run;quit;
');

proc print data=want_basewps width=min;
run;quit;


