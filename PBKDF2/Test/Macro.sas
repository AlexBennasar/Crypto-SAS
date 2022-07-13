/*----------------------------------------------------------------------------------*
   ************************************************************
   *** Copyright 2022, Alex Bennasar.  All rights reserved. ***
   ************************************************************
   
   EXAMPLE OF USAGE WITH SAS MACROVARS
   			                 
   DEPENDENCIES: All the files under:
   					Crypto-SAS/Hexadecimal
   					Crypto-SAS/PBKDF2
   
   PROGRAM HISTORY:
   
   Date        Programmer        Description
   ---------   ---------------   ----------------------------------------------------
   13JUL2022   Alex Bennasar     Original version 
*-----------------------------------------------------------------------------------*/

/* Password */
%let password=%str(//superSecretPW***);
/* Salt */
%let salt=12a5bc669820edc56710bbf55210aaed;
/* Number of rounds */
%let iCount=1024;
/* Pseudorandom function */
%let PRF=%str(hmac-sha256);
/* Length in bytes of the derived key */
%let derivedKeyLength=32;

/* Key derivation */
%let derivedKey=%PBKDF2(&password, &salt, &iCount, &PRF, &derivedKeyLength);
%put NOTE: Derived key: &derivedKey;
