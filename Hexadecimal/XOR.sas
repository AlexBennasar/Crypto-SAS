/*----------------------------------------------------------------------------------*
   ************************************************************
   *** Copyright 2022, Alex Bennasar.  All rights reserved. ***
   ************************************************************
   
   MACRO:      xOR
   
   PURPOSE:    Implementation of the xor function for operands of an arbitrary length
   
   DESCRIPTION: Given 2 operands, performs their xor operation
               
   ARGUMENTS:  H1		      => <Hexadecimal>     first operand
               H2		      => <Hexadecimal>     second operand
               
   RETURNS:	   					 <Hexadecimal>     xor of the 2 operands
               
   DETAILS:    Performs the xor operation of 2 given operands.
   			   Both operands must be hexadecimal numbers.
   			   Operands can have lengths over 8 hexadecimal digits.
   			   Operands must have the same length.
   			   Result have the same length (same hex digits) as operands.
   			                 
   DEPENDENCIES: None
               
   PROGRAM HISTORY:
   
   Date        Programmer        Description
   ---------   ---------------   ----------------------------------------------------
   04JUL2022   Alex Bennasar     Original version  
*-----------------------------------------------------------------------------------*/

%macro xOR
   (H1                 /* First operand, in hexadecimal */
   ,H2                 /* Second operand, in hexadecimal */
   );

%*--------------------------------------------------;
%*------------------- MACRO CODE -------------------;
%*--------------------------------------------------;
	%local out length numWords firstWordDigits i l s1 s2 firstDigitPos wordXOR;

	%let length=%length(&h1);

	%if &length ne %length(&h2) %then
		%do;
			%put ERROR: [xOR] Operand lengths must be equal.;
			%return;
		%end;

	/* Number of 7-digit words contained in operands */
	%let numWords=%sysevalf(&length/7, ceil);

	/* Number of hex digits of the first word (can be less than 7 only for it) */
	%let firstWordDigits=%eval(&length-(&numWords-1)*7);

	%do i=1 %to &numWords;

		/* First word of both operands */		
		%if &i=1 %then
			%do;
				%let l=&firstWordDigits;
				%let firstDigitPos=1;
			%end;

		/* Subsequent words (if any) */
		%else
			%do;
				%let l=7;
				%let firstDigitPos=%eval(&firstWordDigits+1+(&i-2)*7);
			%end;
		%let s1=%substr(&h1, &firstDigitPos, &l);
		%let s2=%substr(&h2, &firstDigitPos, &l);

		/* Perform xOR and convert back to hex */
		%let wordXOR=%sysfunc(bxor(0&s1.x, 0&s2.x), hex&l..);

		/* Concat current result word to former result */
		%let out=&out&wordXOR;
	%end;
	&out
%mend;
