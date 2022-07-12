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
   12JUL2022   Alex Bennasar	 Macros %isNatural, getBase64FromHex and 
                                 getHexFromBase64 added
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

%macro isNatural(string);
	/* Missing is not a natural */
	%if %sysevalf(a%superq(string)=a, boolean) %then
		%do;
			0 
			%return;
		%end;
	/* Search for not (k) decimal digits (d) */
	%if %sysfunc(findc(%superq(string), , kd)) > 0 %then 0;
	%else 1;
%mend;

%macro isBase64(string);
	/* Missing or with a length not multiple of 4 is not base64 */
	%if %sysevalf(a%superq(string)=a, boolean) %then
		%do;
			0 
			%return;
		%end;
	%let string=%superq(string);
	%local l posNoBase64;
	%let l=%length(&string);
	%if %sysfunc(mod(&l,4)) ne 0 %then %do;
		0
		%return;	
	%end;
	
	/* First (l-2) chars: search for not (k) decimal digits (d) or alphabetic chars (a), 
	   or chars "+" or "/", ignoring case (i) 
	   Last 2 chars: same as first (l-2), but adding "=" as allowed last char, or "==" as 
	   allowed last 2 chars. */
	%let posNoBase64=%sysfunc(findc(%superq(string),%str(+/), kiad));
	%if &posNoBase64=0 
		or &posNoBase64=%eval(&l-1) and %qsubstr(&string,%eval(&l-1))=%str(==) 
		or &posNoBase64=%eval(&l) and %qsubstr(&string,%eval(&l))=%str(=)
			%then 1;
	%else 0;
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

/* Encodes each group of 3 bytes (6 hex) into 4 base64 digits.
   The last group is padded before encoding, to get a 3-bytes length, if needed.
   If padding is needed, a "=" or "==" string is added at the end of the output, indicating 
   that the last byte, or the last 2 bytes respectively, are not part of the value. 
   For this, function always gives a multiple-of-4-length output, counting the "=" or "==" 
   at the end, if needed */	
%macro getBase64FromHex(hexNumber);
	%if not %isHex(%superq(hexNumber)) %then %do;
		%put ERROR: [getBase64FromHex] Parameter is not an hexadecimal.;
		%return;
	%end;
	%local hexL groupsOf3Bytes base64L;
	%let hexL=%length(&hexNumber);
	
	%if %sysfunc(mod(&hexL,2)) ne 0 %then %do;
		%put ERROR: [getBase64FromHex] Even number of hex digits (integer number of bytes) required.;
		%return;	
	%end;
	
	%let groupsOf3Bytes=%sysevalf(&hexL/2/3,ceil);
	%let base64L=%eval(&groupsOf3Bytes*4);
	
	%qsysfunc(inputc(&hexNumber,$hex&hexL..),$base64x&base64L..)
%mend;

/* Encodes each group of 3 bytes (4 base64 digits) into 6 hex digits.
   Parameter must be a multiple-of-4-length base64 string, including, for computing this 
   mandatory length, the final "=" or "==", if present. */
%macro getHexFromBase64(base64Number);
	%if not %isBase64(%superq(base64Number)) %then %do;
		%put ERROR: [getHexFromBase64] Parameter is not a base64 string.;
		%return;
	%end;
	%let base64Number=%superq(base64Number);
	%local base64L groupsOf4Chars hexL;
	%let base64L=%length(&base64Number);
	
	%let groupsOf4Chars=%eval(&base64L/4);
	%let hexL=%eval(&groupsOf4Chars*6);
	
	/* base64 ends with "=="? If so, 2 bytes less = 4 hex less */
	%if %qsubstr(&base64Number,%eval(&base64L-1))=%str(==) %then %let hexL=%eval(&hexL-4);
	
	/* base64 ends with "="? If so, 1 bytes less = 2 hex less */
	%else %if %qsubstr(&base64Number,%eval(&base64L))=%str(=) %then %let hexL=%eval(&hexL-2);
		
	%sysfunc(inputc(&base64Number,$base64x&base64L..),$hex&hexL..)
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