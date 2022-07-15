/*----------------------------------------------------------------------------------*
   ************************************************************
   *** Copyright 2022, Alex Bennasar.  All rights reserved. ***
   ************************************************************
   
   USING AES AND PBKDF2 TOGETHER. EXAMPLE WITH SAS MACROVARS
   			                 
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

/* ENCRYPTION */

/* Message to be encrypted */
%let message=00112233445566778899aabbccddeeff;
%put NOTE: Original message: &message;

/* Encryption key derivation. The key has length=256 bits */
%let key=%PBKDF2(%str(//superSecretPW***),12a5bc669820edc56710bbf55210aaed,1024,hmac-sha256,32);
%put NOTE: Derived encryption key: &key;

/* Encryption with a 256-bit key */
%let cryptogram256=%cipherAES(&message, &key);
%put NOTE: Message encrypted with 256-bit key: &cryptogram256;

/* DECRYPTION */

/* Decryption with a 256-bit key */
%let messageDecrypted256=%invCipherAES(&cryptogram256, &key);
%put NOTE: Message decrypted with 256-bit key: &messageDecrypted256;
