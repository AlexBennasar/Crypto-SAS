/*----------------------------------------------------------------------------------*
   ************************************************************
   *** Copyright 2022, Alex Bennasar.  All rights reserved. ***
   ************************************************************
   
   EXAMPLE OF USAGE WITH SAS MACROVARS
   			                 
   DEPENDENCIES: All the files under:
   					Crypto-SAS/Hexadecimal
   					Crypto-SAS/AES/Basic-Algorithm
   				 Execution in the first place of that files is mandatory
   
   PROGRAM HISTORY:
   
   Date        Programmer        Description
   ---------   ---------------   ----------------------------------------------------
   04JUL2022   Alex Bennasar     Original version  
*-----------------------------------------------------------------------------------*/

/* Message to be encrypted */
%let message=00112233445566778899aabbccddeeff;
%put NOTE: Original message: &message;

/* Encryption with a 128-bit key */
%let key128=000102030405060708090a0b0c0d0e0f;
%let cryptogram128=%cipherAES(&message, &key128);
%put NOTE: Message encrypted with 128-bit key: &cryptogram128;

/* Encryption with a 192-bit key */
%let key192=000102030405060708090a0b0c0d0e0f1011121314151617;
%let cryptogram192=%cipherAES(&message, &key192);
%put NOTE: Message encrypted with 192-bit key: &cryptogram192;

/* Encryption with a 256-bit key */
%let key256=000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f;
%let cryptogram256=%cipherAES(&message, &key256);
%put NOTE: Message encrypted with 256-bit key: &cryptogram256;

/* Decryption with a 128-bit key */
%let messageDecrypted128=%invCipherAES(&cryptogram128, &key128);
%put NOTE: Message decrypted with 128-bit key: &messageDecrypted128;

/* Decryption with a 192-bit key */
%let messageDecrypted192=%invCipherAES(&cryptogram192, &key192);
%put NOTE: Message decrypted with 192-bit key: &messageDecrypted192;

/* Encryption with a 256-bit key */
%let messageDecrypted256=%invCipherAES(&cryptogram256, &key256);
%put NOTE: Message decrypted with 256-bit key: &messageDecrypted256;