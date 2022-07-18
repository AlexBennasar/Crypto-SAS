/*----------------------------------------------------------------------------------*
   ************************************************************
   *** Copyright 2022, Alex Bennasar.  All rights reserved. ***
   ************************************************************
   
   SEVERAL MACROS FOR CREATING AND MANAGING A KEY SCHEDULE, AS DEFINED 
   IN THE AES
   			                 
   DEPENDENCIES: All the files under Crypto-SAS/Hexadecimal
   				 Files:
   				 	Crypto-SAS/AES/Basic-Algorithm/Transformations.sas 
   				 	Crypto-SAS/AES/Basic-Algorithm/AESUtils.sas
               
   PROGRAM HISTORY:
   
   Date        Programmer        Description
   ---------   ---------------   ----------------------------------------------------
   04JUL2022   Alex Bennasar     Original version  
   18JUL2022   Alex Bennasar     Bug correction in %getRoundKey. Macrovar i is now local
*-----------------------------------------------------------------------------------*/

%macro doKeyExpansion(key);
	%local nk nb nr i temp afterRotWord afterSubWord rCon afterXOrWithRCon wAnt k 
		keySchedule op1;
	%let nk=%getNk(%superq(key));
	%let nb=%getNb();
	%let nr=%getNr(%superq(key));
	%let keySchedule=%upcase(%qsubstr(&key, 1, 8));

	/* First Nk-1 keys are extracted directly from the AES key */
	%do i=1 %to %eval(&nk-1);
		%let keySchedule=&keySchedule. %upcase(%qsubstr(&key, 8*&i+1, 8));
	%end;

	/* Rest of the keys are computed using keys previously read/generated */
	%do i=&nk %to %eval(&nb*(&nr+1)-1);
		%let temp=%scan(&keySchedule, &i);
		%let rCon=%getRcon(&i, &nk, &nb, &nr);
		%let afterRotWord=;
		%let afterSubWord=;
		%let afterXOrWithRCon=;
		%let wAnt=%scan(&keySchedule, %eval(&i-&nk+1));

		%if &nk=8 and %sysfunc(mod(&i, 4))=0 and not %isHex(&rCon) %then
			%let afterSubWord=%subWordAES(&temp);
		%else %if %isHex(&rCon) %then
			%do;
				%let afterRotWord=%rotWordAES(&temp);
				%let afterSubWord=%subWordAES(&afterRotWord);
				%let afterXOrWithRCon=%xOR(&afterSubWord, &rCon);
			%end;
		%let op1=%sysfunc(coalescec(&afterXOrWithRCon, &afterSubWord, &temp));
		%let k=%xOR(&op1,&wAnt);
		%let keySchedule=&keySchedule. &k;
	%end;
	&keySchedule
%mend;

%macro getRoundKey(keySchedule,round);
	%local roundKey i;
	
	%do i=1 %to 4;
		%let roundKey=&roundKey.%scan(&keySchedule,%eval(4*&round+&i));
	%end;
	
	&roundKey
%mend;
	
%macro getRcon(i,Nk,Nb,Nr);
	%local iMax;
	%let iMax=%eval(&Nb*(&Nr+1)-1);
	%if &i<0 or &i>&iMax %then %do;
		%put ERROR: [getRcon] Wrong parameter value (i=&i).;
		%return;	
	%end;
	
	%if &Nk=4 and &i=4 or &Nk=6 and &i=6 or &Nk=8 and &i=8 %then %do;
		01000000
	%end;
	%else %if &Nk=4 and &i=8 or &Nk=6 and &i=12 or &Nk=8 and &i=16 %then %do;
		02000000
	%end;
	%else %if &Nk=4 and &i=12 or &Nk=6 and &i=18 or &Nk=8 and &i=24 %then %do;
		04000000
	%end;
	%else %if &Nk=4 and &i=16 or &Nk=6 and &i=24 or &Nk=8 and &i=32 %then %do;
		08000000
	%end;
	%else %if &Nk=4 and &i=20 or &Nk=6 and &i=30 or &Nk=8 and &i=40 %then %do;
		10000000
	%end;
	%else %if &Nk=4 and &i=24 or &Nk=6 and &i=36 or &Nk=8 and &i=48 %then %do;
		20000000
	%end;
	%else %if &Nk=4 and &i=28 or &Nk=6 and &i=42 or &Nk=8 and &i=56 %then %do;
		40000000
	%end;
	%else %if &Nk=4 and &i=32 or &Nk=6 and &i=48 %then %do;
		80000000
	%end;
	%else %if &Nk=4 and &i=36 %then %do;
		1B000000
	%end;
	%else %if &Nk=4 and &i=40 %then %do;
		36000000
	%end;
%mend;