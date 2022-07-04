/*----------------------------------------------------------------------------------*
   ************************************************************
   *** Copyright 2022, Alex Bennasar.  All rights reserved. ***
   ************************************************************
   
   SEVERAL MACROS FOR READING AND MANIPULATING A BLOCK, AS DEFINED 
   IN THE AES
   			                 
   DEPENDENCIES: None
   
   PROGRAM HISTORY:
   
   Date        Programmer        Description
   ---------   ---------------   ----------------------------------------------------
   04JUL2022   Alex Bennasar     Original version  
*-----------------------------------------------------------------------------------*/
%macro printBlock(block);
	%local i j s00 s10 s20 s30 s01 s11 s21 s31 s02 s12 s22 s32 s03 s13 s23 s33;

	%do j=0 %to 3;

		%do i=0 %to 3;
			%let s&i&j=%substr(&block, %eval(2*&i+8*&j+1), 2);
		%end;
	%end;
	%put NOTE: &s00 &s01 &s02 &s03;
	%put NOTE: &s10 &s11 &s12 &s13;
	%put NOTE: &s20 &s21 &s22 &s23;
	%put NOTE: &s30 &s31 &s32 &s33;
%mend;

%macro extractColumn(block,colNum);
	%substr(&block,%eval(8*(&colNum-1)+1),8)
%mend;

%macro extractRow(block,rowNum);
	%local i out;
	%do i=1 %to 4;
		%let out=&out%substr(&block,%eval(8*&i+2*&rowNum-9),2);
	%end;
	&out
%mend;

%macro transposeBlock(block);
	%local i r1 r2 r3 r4;
	%do i=1 %to 4;
		%let r&i=%extractRow(&block,&i);
	%end;
	&r1&r2&r3&r4
%mend;