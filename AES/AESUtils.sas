/*----------------------------------------------------------------------------------*
   ************************************************************
   *** Copyright 2022, Alex Bennasar.  All rights reserved. ***
   ************************************************************
   
   SEVERAL MACROS THAT IMPLEMENT UTILITY FUNCTIONS REQUIRED FOR THE AES, LIKE THE 
   "XTIME" FUNCTION AND THE "MULTIPLYGF" OPERATION
   			                 
   DEPENDENCIES: All the files under Crypto-SAS/Hexadecimal
   				 Execution in the first place of the files under Crypto-SAS/Hexadecimal is 
   				 mandatory
   				 
   NOTES:      Several global macrovariables are created and used.
   			   Macrovariables whose names begin with "gFWord" must be
   			   avoided by the user.
               
   PROGRAM HISTORY:
   
   Date        Programmer        Description
   ---------   ---------------   ----------------------------------------------------
   04JUL2022   Alex Bennasar     Original version  
*-----------------------------------------------------------------------------------*/
%macro getNk(key);
	%eval(%length(&key)/8)
%mend;

%macro getNb();
	4
%mend;

%macro getNr(k);
	%local Nk;
	%let Nk=%getNk(&k);

	%if %superq(Nk)=4 %then
		%do;
			10
			%return;
		%end;
	%else %if %superq(Nk)=6 %then
		%do;
			12
			%return;
		%end;
	%else %if %superq(Nk)=8 %then
		%do;
			14
			%return;
		%end;
%mend;

%macro xTime(hexByte);
	%local firstBit out firstDigit;

	%let out=%shiftLeft(&hexByte);

	%let firstDigit=%upcase(%substr(&hexByte, 1, 1));

	/* First bit is 1? */		
	%if &firstDigit=8 or &firstDigit=9 or &firstDigit=A or &firstDigit=B 
		or &firstDigit=C or &firstDigit=D or &firstDigit=E or &firstDigit=F %then
			%let out=%xOR(&out, 1B);
			&out
%mend;

%macro multiplyGFNotPrecomputed(byteHex1, byteHex2);
	%if &byteHex1=00 or &byteHex2=00 %then %do;
		00
		%return;
	%end;

	%local byteBin2 i j out bit sumand sumandXTime lastXTime;
	%let byteBin2=%getBinFromHex(&byteHex2);
	%let out=null;
	%let lastXTime=0;

	%do i=1 %to 8;
		%let bit=%substr(&byteBin2, %eval(8-&i+1), 1);

		%if &bit %then
			%do;
				%let sumand=&byteHex1;

				%if &i>1 %then
					%do;

						%if &lastXTime>0 %then
							%let sumand=&sumandXTime;

						%do j=%eval(&lastXTime+1) %to %eval(&i-1);
							%let sumand=%xTime(&sumand);
						%end;
						%let sumandXTime=&sumand;
						%let lastXTime=%eval(&i-1);
					%end;

				%if &out=null %then
					%let out=&sumand;
				%else
					%let out=%xOR(&out, &sumand);
			%end;
	%end;
	&out
%mend;

%macro multiplyGFWord(byteHex, word);
	%local i byte out;

	%do i=1 %to 4;
		%let byte=%substr(&word, %eval(2*&i-1), 2);
		%let out=&out%multiplyGF(&byteHex, &byte);
	%end;
	&out
%mend;

%macro precomputeGF;
	%local opList i j k hex1 hex2 op;
	%let opList=02 03 09 0B 0D 0E;

	%do i=0 %to 15;
		%let hex1=%sysfunc(putn(&i, hex1.));
		%do j=0 %to 15;
			%let hex2=%sysfunc(putn(&j, hex1.));
			%do k=1 %to 6;
				%let op=%scan(&opList,&k);
				%global gFWord&op&hex1&hex2;
				%let gFWord&op&hex1&hex2=%multiplyGFNotPrecomputed(&op,&hex1&hex2);
			%end;
		%end;
	%end;
%mend;

%precomputeGF;

/* byteHex1 must be one of these: 02 03 09 0B 0D 0E */
%macro multiplyGF(byteHex1, byteHex2);

	%if &byteHex1=00 or &byteHex2=00 %then
		%do;
			00 
			%return;
		%end;
	%else %if &byteHex1=01 %then
		%do;
			&byteHex2
		%return;
		%end;
	%else %if &byteHex2=01 %then
		%do;
			&byteHex1
		%return;
		%end;
		
	&&gFWord&byteHex1&byteHex2
%mend;