# Hexadecimal operations

This section includes the implementation of several macros that perform checks, operations and conversions over hexadecimal numbers.

## The %xOR macro

SAS includes a [BXOR function](https://documentation.sas.com/doc/en/vdmmlcdc/8.1/lefunctionsref/p16q5ly3d7dtlen1dkw2v4pctqs4.htm) that returns the bitwise logical EXCLUSIVE OR of two given arguments. However, this function has two limitations:
- the operands are limited to a value of 0xFFFFFFFF.
- the output is always decimal (although it can be easily transformed to hexadecimal).

With the [%xOR macro](https://github.com/AlexBennasar/Crypto-SAS/blob/main/Hexadecimal/XOR.sas), the operators are hexadecimal strings that can have an arbitrary length, and the output is given in hexadecimal format too, with its length equal to the operators length.

### Usage

```SAS
%let op1=A512ED125;
%let op2=0BB1F5695;

/* Performs a 9-digit xOR */
%let result=%xOR(&op1,&op2);

/* (0xA512ED125) xor (0x0BB1F5695) = 0xAEA3187B0 */
%put NOTE: (0x&op1) xor (0x&op2) = 0x&result;
```
