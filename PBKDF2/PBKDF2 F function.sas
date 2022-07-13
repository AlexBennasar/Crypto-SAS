/*----------------------------------------------------------------------------------*
   ************************************************************
   *** Copyright 2022, Alex Bennasar.  All rights reserved. ***
   ************************************************************
   
   F FUNCTION NEEDED TO EXTRACT BLOCKS OF LENGTH HLEN OF THE DERIVED KEY, AS DEFINED 
   IN PKCS #5 (https://datatracker.ietf.org/doc/html/rfc8018#section-5.2).
   			                 
   DEPENDENCIES: All the files under Crypto-SAS/Hexadecimal
               
   PROGRAM HISTORY:
   
   Date        Programmer        Description
   ---------   ---------------   ----------------------------------------------------
   13JUL2022   Alex Bennasar     Original version  
*-----------------------------------------------------------------------------------*/
%macro PBKDF2F(password, salt, iCount, PRF, i);
	%local intI formerU U count out;

	%let intI=%sysfunc(putn(&i, hex8.));

	%let formerU=&salt&intI;

	%do count=1 %to &iCount;

		%if &PRF=%str(HMAC-SHA256) %then
			%do;

			/* third parameter is '1' because U is hex, but password not */
			%let U=%sysfunc(sha256hmachex(&password, &formerU, 1));
			%end;
		%else
			%do;
				%put ERROR: [PBKDF2F] PRF not supported;
				%return;
			%end;

		%if &count>1 %then
			%do;
				%let out=%xOR(&U, &out);
			%end;
		%else
			%let out=&U;
		%let formerU=&U;
	%end;
	&out
%mend;