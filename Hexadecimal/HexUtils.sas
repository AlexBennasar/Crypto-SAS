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
   13JUL2022   Alex Bennasar	 Macros %isNatural, %isBase64, %getBase64FromHex and 
                                 %getHexFromBase64 added
   16JUL2022   Alex Bennasar	 Macros %getBase64, %getHex, %getTextFromBase64, 
                                 %getTextFromHex, %getHexFromDec and %appendHex added
   18JUL2022   Alex Bennasar	 Macros %lengthBytes and %substrBytes added
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

%macro getHexFromDec(decNumber);
	%if not %isNatural(%superq(decNumber)) %then
		%do;
			%put ERROR: [getHexFromDec] Parameter is not a decimal number.;
			%return;
		%end;
	%local numHexDigits;
	%if &decNumber ne 0 %then
		%let numHexDigits=%sysevalf(%sysfunc(log(&decNumber))/%sysfunc(log(16))+1,floor);
	%else %let numHexDigits=1;
	%sysfunc(putn(&decNumber,hex&numHexDigits..))
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

/* Encodes a text into a base64 string. The operation is encoding-dependent.
   A SAS macrovar has a maximum length of 65534 bytes. Taking into account that:
   - a single ASCII char has a length of 1 byte (is extended from its 7 bits to 8 bits). 
   - other chars can have a length of more than 1 byte, it depends on the encoding.
   - each 3 bytes are codified as 4 base64 chars.
   in a worst-case scenario (2 bytes/char), problems may arise with string texts with 24575 chars or more 
   (=65534*3/(2*4)). It is responsibility of the user to manage these situations.
   */
%macro getBase64(string);
	%getBase64FromHex(%getHex(%superq(string)))
%mend;

/* Decodes a base64 string back into a text string. The operation is encoding-dependent. */
%macro getTextFromBase64(base64Number);
	%if not %isBase64(%superq(base64Number)) %then %do;
		%put ERROR: [getTextFromBase64] Parameter is not a base64 string.;
		%return;
	%end;
	%qsysfunc(inputc(%superq(base64Number),$base64x.))
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

/* Encodes a text into an hexadecimal string. The operation is encoding-dependent.
   A SAS macrovar has a maximum length of 65534 bytes. Taking into account that:
   - a single ASCII char has a length of 1 byte (is extended from its 7 bits to 8 bits). 
   - other chars can have a length of more than 1 byte, it depends on the encoding.
   - each byte is codified as 2 hexadecimal chars.
   in a worst-case scenario (2 bytes/char), problems may arise with string texts with 16383 chars or more 
   (=65534/(2*2)). It is responsibility of the user to manage these situations.
   */
%macro getHex(string);
	%sysfunc(putc(%superq(string),$hex65532.))
%mend;

/* Decodes an hexadecimal string back into a text string. The operation is encoding-dependent. */
%macro getTextFromHex(hexNumber);
	%if not %isHex(%superq(hexNumber)) %then %do;
		%put ERROR: [getTextFromHex] Parameter is not an hexadecimal.;
		%return;
	%end;
	%qsysfunc(inputc(%superq(hexNumber),$hex.))
%mend;
	
%macro appendHex(base64String,hexToAppend);
	%local inEmpty l lastBytes firstBytes out;
	%let inEmpty=%sysevalf(a%superq(base64String)=a, boolean);
	%if not %isBase64(%superq(base64String)) and not &inEmpty %then %do;
		%put ERROR: [appendHex] Parameter is not a base64 string.;
		%return;
	%end;
	%if not %isHex(%superq(hexToAppend)) %then %do;
		%put ERROR: [appendHex] Parameter is not an hexadecimal.;
		%return;
	%end;
	%if %sysfunc(mod(%length(%superq(hexToAppend)),2)) ne 0 %then %do;
		%put ERROR: [appendHex] Even number of hex digits (integer number of bytes) required.;
		%return;	
	%end;
	/* If input is empty, only output the hexToAppend, converted to base64 */
	%if &inEmpty %then %do;
		%let out=%getBase64FromHex(&hexToAppend);
		%superq(out)
		%return;
	%end;
	%let base64String=%superq(base64String);
	
	%let l=%length(&base64String);
	/* Last 4 chars. They'll be 3 bytes, or 2 (ends with "=") or 1 (ends with "==") */
	%let lastBytes=%qsubstr(&base64String,%eval(&l-3));
	/* Convert to hex */
	%let lastBytes=%getHexFromBase64(&lastBytes);
	%if &l>4 %then %let firstBytes=%qsubstr(&base64String,1,%eval(&l-4));
	%let out=&firstBytes.%getBase64FromHex(&lastBytes&hexToAppend);
	%superq(out)
%mend;

%macro substrBytes(base64String,ini,length);
	%local inLength inLengthBytes last firstPos lastPos substrHex iniOffset;
	
	%if not %isBase64(%superq(base64String)) %then %do;
		%put ERROR: [substrBytes] Parameter is not a base64 string.;
		%return;
	%end;

	%let base64String=%superq(base64String);	
	/*%put NOTE: Original bytes: %getHexFromBase64(&base64String);*/
	
	%let inLength=%length(&base64String);
	%let inLengthBytes=%lengthBytes(&base64String);	
	/*%put NOTE: Length in bytes: &inLengthBytes;*/
	
	/* Missing length in bytes to extract? Extract till the end */
	%if %sysevalf(a%superq(length)=a, boolean) %then
		%do;
			%let length=%eval(&inLengthBytes-&ini+1); 
		%end;
	
	%if not %isNatural(%superq(ini)) or not %isNatural(%superq(length)) %then
		%do;
			%put ERROR: [substrBytes] Ini and length must be a natural number.;
			%return;
		%end;
	%if &ini<=0 or &length<=0 %then
		%do;
			%put ERROR: [substrBytes] Ini and length must be a positive number.;
			%return;
		%end;
	
	%let last=%eval(&ini+&length-1);
	
	/*%put NOTE: Last byte to extract: &last;*/
	
	%if &last>&inLengthBytes %then
		%do;
			%put ERROR: [substrBytes] Parameters out of range.;
			%return;
		%end;
	/*%put NOTE: First byte to extract: &ini;*/
	/* First position to extract from the original base64 string */
	%let firstPos=%eval(1+4*%sysevalf((&ini-1)/3,floor));
	/*%put NOTE: First position to extract from the original base64 string: &firstPos;*/
	/* Last position to extract from the original base64 string */
	%let lastPos=%eval(1+4*%sysevalf((&last-1)/3,floor)+3);
	/*%put NOTE: Last position to extract from the original base64 string: &lastPos;*/
	%let substrHex=%getHexFromBase64(%qsubstr(&base64String,&firstPos,%eval(&lastPos-&firstPos+1)));
	/*%put NOTE: Substr extracted in hex: &substrHex;*/
	
	/* Strip all exceeding bytes extracted */
	%let iniOffset=%eval(2*%sysfunc(mod(&ini-1,3))+1);
	/*%put NOTE: Initial Offset: &iniOffset;*/
	%let substrHex=%substr(&substrHex,&iniOffset,%eval(&length*2));
	/*%put NOTE: Final result: &substrHex;*/
	&substrHex
%mend;

%macro lengthBytes(base64String);
	%local inEmpty inLength inLengthBytes;
	%let inEmpty=%sysevalf(a%superq(base64String)=a, boolean);
	%if not %isBase64(%superq(base64String)) and not &inEmpty  %then %do;
		%put ERROR: [lengthBytes] Parameter is not a base64 string.;
		%return;
	%end;
	
	%if &inEmpty %then %do;
		0
		%return;
	%end;

	%let inLength=%length(&base64String);
	/* 4 base64 = 3 bytes */
	%let inLengthBytes=%eval(&inLength/4*3);
	
	%if %qsubstr(&base64String, %eval(&inLength-1))=%str(==) %then
		%let inLengthBytes=%eval(&inLengthBytes-2);
	%else %if %qsubstr(&base64String, &inLength)=%str(=) %then
		%let inLengthBytes=%eval(&inLengthBytes-1);	
		
	&inLengthBytes
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