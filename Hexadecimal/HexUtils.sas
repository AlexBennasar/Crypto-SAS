/*----------------------------------------------------------------------------------*
   ************************************************************
   *** Copyright 2022, Alex Bennasar.  All rights reserved. ***
   ************************************************************
   
   SEVERAL MACROS THAT PERFORM CHECKS, OPERATIONS AND CONVERSIONS OVER
   HEXADECIMAL NUMBERS
   			                 
   DEPENDENCIES: None
               
   PROGRAM HISTORY:
   
   Date        Programmer        Description
   ---------   ---------------   ----------------------------------------------------
   04JUL2022   Alex Bennasar     Original version  
*-----------------------------------------------------------------------------------*/

%macro isHex(string);
	/* Missing value is not hex */
	%if %sysevalf(a%superq(string)=a, boolean) %then
		%do;
			0 
			%return;
		%end;
		
	/* Search for not (k) hexadecimals (x), ignoring case (i) */
	%if %sysfunc(findc(%superq(string), , kix)) > 0 %then 0;
	%else 1;
%mend;

%macro isBin(string);
	%local l i char found;
	
	/* Missing value is not binary */
	%if %sysevalf(a%superq(string)=a, boolean) %then
		%do;
			0 
			%return;
		%end;
		
	%let l=%length(%superq(string));

	%let i=1;
	%let found=0;
	/* Search for a non-bit character */
	%do %while (&i <= &l and not &found);
		%let char=%qsubstr(%superq(string),&i,1);
		%if &char ne 0 and &char ne 1 %then %do;
			%let found=1;
		%end;
		%let i=%eval(&i+1);
	%end;
	%sysevalf(not &found,boolean)
%mend;

%macro getDecFromHex(hexNumber);
	%if not %isHex(%superq(hexNumber)) %then
		%do;
			%put ERROR: [getDecFromHex] Parameter is not an hexadecimal.;
			%return;
		%end;
	%sysfunc(inputn(&hexNumber,hex.))
%mend;

%macro getDecFromBin(binNumber);	
	%if not %isBin(%superq(binNumber)) %then %do;
		%put ERROR: [getDecFromBin] Parameter is not binary.;
		%return;
	%end;	
	%sysfunc(inputn(&binNumber,binary.))

%mend;

%macro getBinFromHex(hexNumber);
	%if not %isHex(%superq(hexNumber)) %then %do;
		%put ERROR: [getBinFromHex] Parameter is not an hexadecimal.;
		%return;
	%end;
	%sysfunc(putn(%getDecFromHex(%superq(hexNumber)),binary.))

%mend;

%macro getHexFromBin(binNumber);
	%if not %isBin(%superq(binNumber)) %then %do;
		%put ERROR: [getHexFromBin] Parameter is not binary.;
		%return;
	%end;
	%sysfunc(putn(%getDecFromBin(%superq(binNumber)),hex.))
%mend;

%macro shiftLeft(hexByte);
	%if %length(%superq(hexByte)) ne 2 or not %isHex(%superq(hexByte)) %then %do;
		%put ERROR: [shiftLeft] Wrong parameter.;
		%return;
	%end;

	%local dec;
	/* Shift left = convert to decimal and multiply by 2 modulo 256 */
	%let dec=%eval(%getDecFromHex(&hexByte)*2);
	
	%sysfunc(mod(&dec,256),hex2.)
%mend;