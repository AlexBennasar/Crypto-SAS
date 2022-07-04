/*----------------------------------------------------------------------------------*
   ************************************************************
   *** Copyright 2022, Alex Bennasar.  All rights reserved. ***
   ************************************************************
   
   SEVERAL MACROS THAT IMPLEMENT THE TRANSFORMATIONS DEFINED IN THE AES
   (https://nvlpubs.nist.gov/nistpubs/fips/nist.fips.197.pdf)
   			                 
   DEPENDENCIES: All the files, excluding "Test" subfolder and "AES.sas" file, under:
   					Crypto-SAS/Hexadecimal
   					Crypto-SAS/AES/Basic-Algorithm
   				 Execution in the first place of the files under Crypto-SAS/Hexadecimal is 
   				 mandatory
               
   PROGRAM HISTORY:
   
   Date        Programmer        Description
   ---------   ---------------   ----------------------------------------------------
   04JUL2022   Alex Bennasar     Original version  
*-----------------------------------------------------------------------------------*/

%macro subWordAES(word);
	%local i out;
	%do i=1 %to 4;
		%let out=&out%transformSBox(%substr(&word,%eval(2*&i-1),2));
	%end;
	&out
%mend;

%macro invSubWordAES(word);
	%local i out;
	%do i=1 %to 4;
		%let out=&out%invTransformSBox(%substr(&word,%eval(2*&i-1),2));
	%end;
	&out
%mend;

%macro rotWordAES(word);
	%local subWord1 subWord2;
	%let subWord1=%substr(&word,1,2);
	%let subWord2=%substr(&word,3,6);
	&subWord2&subWord1
%mend;

%macro subBytesAES(state);
	%local i column out;
	%do i=1 %to 4;
		%let column=%extractColumn(&state,&i);
		%let out=&out%subWordAES(&column);
	%end;
	&out
%mend;

%macro invSubBytesAES(state);
	%local i column out;
	%do i=1 %to 4;
		%let column=%extractColumn(&state,&i);
		%let out=&out%invSubWordAES(&column);
	%end;
	&out
%mend;

%macro addRoundKeyAES(state,roundKey);
	%local key i out column;
	
	%do i=1 %to 4;
		%let key=%extractColumn(&roundKey,&i);
		%let column=%extractColumn(&state,&i);
		%let out=&out%xOR(&key,&column);
	%end;
	
	&out
%mend;

%macro shiftRowsAES(state);
	%local i j s00 s10 s20 s30 s01 s11 s21 s31 s02 s12 s22 s32 s03 s13 s23 s33 sShift00 sShift10 
	sShift20 sShift30 sShift01 sShift11 sShift21 sShift31 sShift02 sShift12 sShift22 sShift32 
	sShift03 sShift13 sShift23 sShift33 out;
	
	%do j=0 %to 3;
		%do i=0 %to 3;
			%let s&i&j=%substr(&state,%eval(2*&i+8*&j+1),2);
			%let sShift&i&j=&&s&i&j;
		%end;
	%end;
	
	%let sShift10=&s11;
	%let sShift11=&s12;
	%let sShift12=&s13;
	%let sShift13=&s10;
	%let sShift20=&s22;
	%let sShift21=&s23;
	%let sShift22=&s20;
	%let sShift23=&s21;
	%let sShift30=&s33;
	%let sShift31=&s30;
	%let sShift32=&s31;
	%let sShift33=&s32;
	
	%do j=0 %to 3;
		%do i=0 %to 3;
			%let out=&out&&sShift&i&j;
		%end;
	%end;
	
	&out
%mend;

%macro invShiftRowsAES(state);
	%local i j s00 s10 s20 s30 s01 s11 s21 s31 s02 s12 s22 s32 s03 s13 s23 s33 sShift00 sShift10 
	sShift20 sShift30 sShift01 sShift11 sShift21 sShift31 sShift02 sShift12 sShift22 sShift32 
	sShift03 sShift13 sShift23 sShift33 temp out;
	
	%do j=0 %to 3;
		%do i=0 %to 3;
			%let s&i&j=%substr(&state,%eval(2*&i+8*&j+1),2);
			%let sShift&i&j=&&s&i&j;
		%end;
	%end;
	
	%let temp=&sShift13;
	%let sShift13=&sShift12;
	%let sShift12=&sShift11;
	%let sShift11=&sShift10;
	%let sShift10=&temp;

	%let temp=&sShift20;
	%let sShift20=&sShift22;
	%let sShift22=&temp;
	%let temp=&sShift21;
	%let sShift21=&sShift23;
	%let sShift23=&temp;
	
	%let temp=&sShift31;
	%let sShift31=&sShift32;
	%let sShift32=&sShift33;
	%let sShift33=&sShift30;
	%let sShift30=&temp;
	
	%do j=0 %to 3;
		%do i=0 %to 3;
			%let out=&out&&sShift&i&j;
		%end;
	%end;
	
	&out
%mend;

%macro mixColumnsAES(state);
	%local i s0 s1 s2 s3 sOut0 sOut1 sOut2 sOut3;
	%do i=0 %to 3;
		%let s&i=%extractRow(&state,%eval(&i+1));
	%end;
	%let sOut0=%xOR(%multiplyGFWord(02,&s0),%multiplyGFWord(03,&s1));
	%let sOut0=%xOR(&sOut0,%xOR(&s2,&s3));
	%let sOut1=%xOR(&s0,%multiplyGFWord(02,&s1));
	%let sOut1=%xOR(&sOut1,%xOR(%multiplyGFWord(03,&s2),&s3));
	%let sOut2=%xOR(&s0,&s1);
	%let sOut2=%xOR(&sOut2,%xOR(%multiplyGFWord(02,&s2),%multiplyGFWord(03,&s3)));
	%let sOut3=%xOR(%multiplyGFWord(03,&s0),&s1);
	%let sOut3=%xOR(&sOut3,%xOR(&s2,%multiplyGFWord(02,&s3)));
	%transposeBlock(&sOut0&sOut1&sOut2&sOut3)
%mend;

%macro invMixColumnsAES(state);
	%local i s0 s1 s2 s3 sOut0 sOut1 sOut2 sOut3;
	%do i=0 %to 3;
		%let s&i=%extractRow(&state,%eval(&i+1));
	%end;
	%let sOut0=%xOR(%multiplyGFWord(0E,&s0),%multiplyGFWord(0B,&s1));
	%let sOut0=%xOR(&sOut0,%xOR(%multiplyGFWord(0D,&s2),%multiplyGFWord(09,&s3)));
	%let sOut1=%xOR(%multiplyGFWord(09,&s0),%multiplyGFWord(0E,&s1));
	%let sOut1=%xOR(&sOut1,%xOR(%multiplyGFWord(0B,&s2),%multiplyGFWord(0D,&s3)));	
	%let sOut2=%xOR(%multiplyGFWord(0D,&s0),%multiplyGFWord(09,&s1));
	%let sOut2=%xOR(&sOut2,%xOR(%multiplyGFWord(0E,&s2),%multiplyGFWord(0B,&s3)));	
	%let sOut3=%xOR(%multiplyGFWord(0B,&s0),%multiplyGFWord(0D,&s1));
	%let sOut3=%xOR(&sOut3,%xOR(%multiplyGFWord(09,&s2),%multiplyGFWord(0E,&s3)));
	%transposeBlock(&sOut0&sOut1&sOut2&sOut3)
%mend;