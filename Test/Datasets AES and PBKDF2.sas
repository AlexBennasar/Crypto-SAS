/*----------------------------------------------------------------------------------*
   ************************************************************
   *** Copyright 2022, Alex Bennasar.  All rights reserved. ***
   ************************************************************
   
   USING AES AND PBKDF2 TOGETHER. EXAMPLE WITH SAS DATASETS
   			                 
   DEPENDENCIES: All the files, except folders named "Test", under:
   					Crypto-SAS/Hexadecimal
   					Crypto-SAS/AES/Basic-Algorithm
   				 	(Execution in the first place of that files is mandatory)
   				 	Crypto-SAS/PBKDF2
   
   PROGRAM HISTORY:
   
   Date        Programmer        Description
   ---------   ---------------   ----------------------------------------------------
   15JUL2022   Alex Bennasar     Original version 
*-----------------------------------------------------------------------------------*/

/* Dataset with 2 equal messages to be encrypted and 2 different salts, to derive 
   2 different encryption keys */
data testMessages;
	length m salt $ 64;
	input m $ salt $;
	datalines;
	00112233445566778899aabbccddeeff 12a5bc669820edc56710bbf55210aaed
	00112233445566778899aabbccddeeff 2b7e151628aed2a6abf7158809cf4f3c
	;
run;

/* Password to perform encryption */
%let password=%nrstr(%"%'///superSecretPW***%");

/* Derive keys given the password and the salts, compute cryptograms and store them in macrovar */
proc sql noprint;
	select '%cipherAES('||m||',%PBKDF2(%superq(password),'||salt||',1024,hmac-sha256,32))' 
		into :cryptograms separated by ' ' from testMessages;
quit;

/* Add computed cryptograms to the original dataset */
data testMessagesWithCryptogram;
	set testMessages;
	c=scan("&cryptograms", _n_);
run;

/* Derive keys given the password and the salts, compute message decryption and store message decrypted in macrovar */
proc sql noprint;
	select '%invCipherAES('||c||',%PBKDF2(%superq(password),'||salt||',1024,hmac-sha256,32))' 
		into :messagesDecrypted separated by ' ' from testMessagesWithCryptogram;
quit;

/* Add messages decrypted to the previous dataset */
data testMessagesDecrypted;
	set testMessagesWithCryptogram;
	mDecrypted=scan("&messagesDecrypted", _n_);
run;