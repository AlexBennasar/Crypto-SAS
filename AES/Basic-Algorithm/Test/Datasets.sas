/*----------------------------------------------------------------------------------*
   ************************************************************
   *** Copyright 2022, Alex Bennasar.  All rights reserved. ***
   ************************************************************
   
   EXAMPLE OF USAGE ON SAS DATASETS
   			                 
   DEPENDENCIES: All the files under:
   					Crypto-SAS/Hexadecimal
   					Crypto-SAS/AES/Basic-Algorithm
   				 Execution in the first place of that files is mandatory
   
   PROGRAM HISTORY:
   
   Date        Programmer        Description
   ---------   ---------------   ----------------------------------------------------
   04JUL2022   Alex Bennasar     Original version  
*-----------------------------------------------------------------------------------*/

/* Dataset with 2 messages to be encrypted, and 2 encryption keys (of 256 and 128 bits respectively) */
data testMessages;
	length m k $ 64;
	input m $ k $;
	datalines;
	00112233445566778899aabbccddeeff 000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f
	3243f6a8885a308d313198a2e0370734 2b7e151628aed2a6abf7158809cf4f3c
	;
run;

/* Compute cryptograms and store them in macrovar */
proc sql noprint;
	select '%cipherAES('||m||','||k||')' into :cryptograms separated by ' ' from testMessages;
quit;

/* Add computed cryptograms to the original dataset */
data testMessagesWithCryptogram;
	set testMessages;
	c=scan("&cryptograms", _n_);
run;

/* Compute message decryption and store message decrypted in macrovar */
proc sql noprint;
	select '%invCipherAES('||c||','||k||')' into :messagesDecrypted separated by ' ' from testMessagesWithCryptogram;
quit;

/* Add messages decrypted to the previous dataset */
data testMessagesDecrypted;
	set testMessagesWithCryptogram;
	mDecrypted=scan("&messagesDecrypted", _n_);
run;
