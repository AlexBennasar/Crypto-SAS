/*----------------------------------------------------------------------------------*
   ************************************************************
   *** Copyright 2022, Alex Bennasar.  All rights reserved. ***
   ************************************************************
   
   MACRO:      cipherAES
   
   PURPOSE:    Implementation of the Advanced Encryption Standard (AES) algorithm
   			   (https://nvlpubs.nist.gov/nistpubs/fips/nist.fips.197.pdf)
   
   DESCRIPTION: Encrypts a block of data with a given key, following the AES algorithm
               
   ARGUMENTS:  M		      => <Hexadecimal>     message to be encrypted
               K		      => <Hexadecimal>     encryption key
               
   RETURNS:	   					 <Hexadecimal>     message encrypted
               
   DETAILS:    Encrypts the given message according to the AES, using the given key.
   			   Message must be a 32-length hexadecimal number (128 bits).
   			   Key can be a 32, 48 or 64-length hexadecimal number (128, 192 or 256 bits).
   			   The returned cryptogram is a 32-length hexadecimal number (128 bits).
   			   
   NOTES:      Several global macrovariables are created and used.
   			   Macrovariables whose names begin with "gFWord", "SBox" or "invSBox" must be
   			   avoided by the user.
               
   DEPENDENCIES: All the files, excluding "Test" subfolder, under:
   					Crypto-SAS/Hexadecimal
   					Crypto-SAS/AES/Basic-Algorithm
   				 Execution in the first place of the files under Crypto-SAS/Hexadecimal is 
   				 mandatory
   				 	
               
   PROGRAM HISTORY:
   
   Date        Programmer        Description
   ---------   ---------------   ----------------------------------------------------
   04JUL2022   Alex Bennasar     Original version  
*-----------------------------------------------------------------------------------*/

%macro cipherAES
   (M                  /* Message to be encrypted */
   ,K                  /* Encryption key */
   );

%*--------------------------------------------------;
%*------------------- MACRO CODE -------------------;
%*--------------------------------------------------;
	%local l round nr keySchedule state roundKey round;

	%if not %isHex(%superq(m)) %then
		%do;
			%put ERROR: [cipherAES] The message is not hexadecimal.;
			%abort;
		%end;

	%if not %isHex(%superq(k)) %then
		%do;
			%put ERROR: [cipherAES] The key is not hexadecimal.;
			%abort;
		%end;
	%let l=%eval(%length(&k)*4);

	%if &l ne 128 and &l ne 192 and &l ne 256 %then
		%do;
			%put ERROR: [cipherAES] Incorrect key length (&l bits).;
			%abort;
		%end;
	%let l=%eval(%length(&m)*4);

	%if &l ne 128 %then
		%do;
			%put ERROR: [cipherAES] Incorrect message length (&l bits).;
			%abort;
		%end;
	%let nr=%getNr(&k);
	%let keySchedule=%doKeyExpansion(&k);
	%let roundKey=%getRoundKey(&keySchedule, 0);
	%let state=&m;

	%do round=1 %to %eval(&nr-1);
		%let state=%addRoundKeyAES(&state, &roundKey);
		%let state=%subBytesAES(&state);
		%let state=%shiftRowsAES(&state);
		%let state=%mixColumnsAES(&state);
		%let roundKey=%getRoundKey(&keySchedule, &round);
	%end;

	/* Final Round */
	%let state=%addRoundKeyAES(&state, &roundKey);
	%let state=%subBytesAES(&state);
	%let state=%shiftRowsAES(&state);
	%let roundKey=%getRoundKey(&keySchedule, %eval(&nr));
	%let state=%addRoundKeyAES(&state, &roundKey);
	&state
%mend;

/*----------------------------------------------------------------------------------*
   ************************************************************
   *** Copyright 2022, Alex Bennasar.  All rights reserved. ***
   ************************************************************
   
   MACRO:      invCipherAES
   
   PURPOSE:    Implementation of the Advanced Encryption Standard (AES) algorithm
   			   (https://nvlpubs.nist.gov/nistpubs/fips/nist.fips.197.pdf)
   
   DESCRIPTION: Decrypts a block of a cryptogram with a given key, following the AES algorithm
               
   ARGUMENTS:  C		      => <Hexadecimal>     cryptogram to be decrypted
               K		      => <Hexadecimal>     decryption key
               
   RETURNS:	   					 <Hexadecimal>     message decrypted
               
   DETAILS:    Decrypts the given cryptogram according to the AES, using the given key, which 
   			   has to be the key used previously for encryption.
   			   Cryptogram must be a 32-length hexadecimal number (128 bits).
   			   Key can be a 32, 48 or 64-length hexadecimal number (128, 192 or 256 bits).
   			   The returned message is a 32-length hexadecimal number (128 bits).
   			   
   NOTES:      Several global macrovariables are created and used.
   			   Macrovariables whose names begin with "gFWord", "SBox" or "invSBox" must be
   			   avoided by the user.
               
   DEPENDENCIES: All the files, excluding "Test" subfolder, under:
   					Crypto-SAS/Hexadecimal
   					Crypto-SAS/AES/Basic-Algorithm
   				 Execution in the first place of the files under Crypto-SAS/Hexadecimal is 
   				 mandatory
               
   PROGRAM HISTORY:
   
   Date        Programmer        Description
   ---------   ---------------   ----------------------------------------------------
   04JUL2022   Alex Bennasar     Original version  
*-----------------------------------------------------------------------------------*/

%macro invCipherAES
   (C                  /* Message to be decrypted */
   ,K                  /* Decryption key */
   );

%*--------------------------------------------------;
%*------------------- MACRO CODE -------------------;
%*--------------------------------------------------;
	%local l round nr keySchedule state roundKey round;

	%if not %isHex(%superq(c)) %then
		%do;
			%put ERROR: [cipherAES] The cryptogram is not hexadecimal.;
			%abort;
		%end;

	%if not %isHex(%superq(k)) %then
		%do;
			%put ERROR: [cipherAES] The key is not hexadecimal.;
			%abort;
		%end;
	%let l=%eval(%length(&k)*4);

	%if &l ne 128 and &l ne 192 and &l ne 256 %then
		%do;
			%put ERROR: [cipherAES] Incorrect key length (&l bits).;
			%abort;
		%end;
	%let l=%eval(%length(&c)*4);

	%if &l ne 128 %then
		%do;
			%put ERROR: [cipherAES] Incorrect cryptogram length (&l bits).;
			%abort;
		%end;
	%let nr=%getNr(&k);
	%let keySchedule=%doKeyExpansion(&k);
	%let roundKey=%getRoundKey(&keySchedule, &nr);
	%let state=&c;
	%let state=%addRoundKeyAES(&state, &roundKey);

	%do round=1 %to %eval(&nr-1);
		%let state=%invShiftRowsAES(&state);
		%let state=%invSubBytesAES(&state);
		%let roundKey=%getRoundKey(&keySchedule, %eval(&nr-&round));
		%let state=%addRoundKeyAES(&state, &roundKey);
		%let state=%invMixColumnsAES(&state);
	%end;

	/* Final Round */
	%let state=%invShiftRowsAES(&state);
	%let state=%invSubBytesAES(&state);
	%let roundKey=%getRoundKey(&keySchedule, 0);
	%let state=%addRoundKeyAES(&state, &roundKey);
	&state
%mend;