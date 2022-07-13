/*----------------------------------------------------------------------------------*
   ************************************************************
   *** Copyright 2022, Alex Bennasar.  All rights reserved. ***
   ************************************************************
   
   MACRO:      PBKDF2
   
   PURPOSE:    Implementation of the Password-Based Key Derivation Function (PBKDF2) 
               algorithm (https://datatracker.ietf.org/doc/html/rfc8018#section-5.2)
   
   DESCRIPTION: Applies a pseudorandom function to a password to derive keys
               
   ARGUMENTS:  password         => <Text>           password for deriving keys
               salt             => <Hexadecimal>    octet string that combines to the 
                                                    password to produce a key
               iCount           => <Integer>        Number of iterations to be 
                                                    performed by the internal 
                                                    algorithm to increase the cost of 
                                                    producing keys, and so, security
               PRF              => <Algorithm name> pseudorandom function to apply to 
                                                    derive the key
               derivedKeyLength => <Integer>        desired length, in octets, of the 
                                                    produced key
               
   RETURNS:                        <Hexadecimal>    derived key, with the desired length
               
   DETAILS:   Given a password and a salt, derives an hexadecimal key that can be used, 
   			   for example, as an encryption key of a cryptographic algorithm. 
   			   The user must specify which length, in octets, has to have the derived key.
   			   The macro needs the number of iterations to perform inside the F function 
   			   (see RFC8018 and "PBKDF2 F function.sas" for details), the bigger the 
   			   better from a security point of view, but always with care, as a bigger 
   			   iCount, worst performance (more time) for deriving the key.
   			   The user can select which pseudorandom function has to be used to derive 
   			   the key but, in this version, only the value 'HMAC-SHA256' is allowed.
   			   More details on Keyed-Hashing for Message Authentication (HMAC): 
   			   https://datatracker.ietf.org/doc/html/rfc2104
   			   More details on Secure Hash Algorithm (SHA): 
   			   https://datatracker.ietf.org/doc/html/rfc6234
               
   DEPENDENCIES: All the files, excluding "Test" subfolder, under:
   					Crypto-SAS/Hexadecimal 
   					Crypto-SAS/PBKDF2
               
   PROGRAM HISTORY:
   
   Date        Programmer        Description
   ---------   ---------------   ----------------------------------------------------
   13JUL2022   Alex Bennasar     Original version  
*-----------------------------------------------------------------------------------*/

%macro PBKDF2
   (password           /* Secret password for generating the key */
   ,salt               /* Octet string that combines with password to produce a key */
   ,iCount             /* Number of iterations to perform inside the F function */
   ,PRF                /* Pseudorandom function to apply */
   ,derivedKeyLength   /* Desired length, in octets, of the key produced */
   );

%*--------------------------------------------------;
%*------------------- MACRO CODE -------------------;
%*--------------------------------------------------;
	%local hLen L R counter T derivedKey;

	%if not %isNatural(%superq(iCount)) or %superq(iCount)=0 %then
		%do;
			%put ERROR: [PBKDF2] iCount must be an integer>0;
			%return;
		%end;

	%if not %isHex(%superq(salt)) %then
		%do;
			%put ERROR: [PBKDF2] The salt is not hexadecimal.;
			%return;
		%end;
	%let PRF=%qupcase(%superq(PRF));

	/* Pseudorandom functions supported */		
	%if &PRF=%str(HMAC-SHA256) %then
		%do;
			%let hLen=32;
		%end;
	%else
		%do;
			%put ERROR: [PBKDF2] PRF not supported;
			%return;
		%end;

	%if not %isNatural(%superq(derivedKeyLength)) or %superq(derivedKeyLength)=0 
		%then
			%do;
			%put ERROR: [PBKDF2] derivedKeyLength must be an integer>0;
			%return;
		%end;

	%if &derivedKeyLength > %eval((2**32 - 1) * &hLen) %then
		%do;
			%put ERROR: [PBKDF2] Derived key too long;
			%return;
		%end;

	/* Length of the desired key, measured in blocks of length hLen */
	%let L=%sysevalf(&derivedKeyLength/&hLen, ceil);

	%let R=%eval(&derivedKeyLength-(&L-1)*&hLen);

	%do counter=1 %to &L;

		%let T=%PBKDF2F(%superq(password), &salt, &iCount, &PRF, &counter);

		%if &counter=1 %then
			%let derivedKey=&T;
		%else
			%let derivedKey=&derivedKey&T;

	%end;

	%let derivedKey=%substr(&derivedKey, 1, %eval(&derivedKeyLength*2));

	%if &derivedKeyLength ne %eval(%length(&derivedKey)/2) %then
		%do;
			%put ERROR: [PBKDF2] Incorrect derived key length!;
		%end;
	&derivedKey
%mend;
   Date        Programmer        Description
   ---------   ---------------   ----------------------------------------------------
   13JUL2022   Alex Bennasar     Original version  
*-----------------------------------------------------------------------------------*/

%macro PBKDF2
   (password           /* Secret password for generating the key */
   ,salt               /* Octet string that combines with password to produce a key */
   ,iCount			   /* Number of iterations to perform inside the F function */
   ,PRF				   /* Pseudorandom function to apply */
   ,derivedKeyLength   /* Desired length, in octets, of the key produced */
   );

%*--------------------------------------------------;
%*------------------- MACRO CODE -------------------;
%*--------------------------------------------------;
	%local hLen L R counter T derivedKey;

	%if not %isNatural(%superq(iCount)) or %superq(iCount)=0 %then
		%do;
			%put ERROR: [PBKDF2] iCount must be an integer>0;
			%return;
		%end;

	%if not %isHex(%superq(salt)) %then
		%do;
			%put ERROR: [PBKDF2] The salt is not hexadecimal.;
			%return;
		%end;
	%let PRF=%qupcase(%superq(PRF));

	/* Pseudorandom functions supported */		
	%if &PRF=%str(HMAC-SHA256) %then
		%do;
			%let hLen=32;
		%end;
	%else
		%do;
			%put ERROR: [PBKDF2] PRF not supported;
			%return;
		%end;

	%if not %isNatural(%superq(derivedKeyLength)) or %superq(derivedKeyLength)=0 
		%then
			%do;
			%put ERROR: [PBKDF2] derivedKeyLength must be an integer>0;
			%return;
		%end;

	%if &derivedKeyLength > %eval((2**32 - 1) * &hLen) %then
		%do;
			%put ERROR: [PBKDF2] Derived key too long;
			%return;
		%end;

	/* Length of the desired key, measured in blocks of length hLen */
	%let L=%sysevalf(&derivedKeyLength/&hLen, ceil);

	%let R=%eval(&derivedKeyLength-(&L-1)*&hLen);

	%do counter=1 %to &L;

		%let T=%PBKDF2F(%superq(password), &salt, &iCount, &PRF, &counter);

		%if &counter=1 %then
			%let derivedKey=&T;
		%else
			%let derivedKey=&derivedKey&T;

	%end;

	%let derivedKey=%substr(&derivedKey, 1, %eval(&derivedKeyLength*2));

	%if &derivedKeyLength ne %eval(%length(&derivedKey)/2) %then
		%do;
			%put ERROR: [PBKDF2] Incorrect derived key length!;
		%end;
	&derivedKey
%mend;
