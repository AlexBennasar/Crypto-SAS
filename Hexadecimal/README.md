# Hexadecimal operations

This section includes the implementation of several macros that perform checks, operations and conversions over hexadecimal numbers.

## The %xOR macro

SAS includes a [BXOR function](https://documentation.sas.com/doc/en/vdmmlcdc/8.1/lefunctionsref/p16q5ly3d7dtlen1dkw2v4pctqs4.htm) that returns the bitwise logical EXCLUSIVE OR of two given arguments. However, this function has two limitations:
- the operands are limited to a value of 0xFFFFFFFF.
- the output is always decimal (although it can be easily transformed to hexadecimal).

With the [%xOR macro](https://github.com/AlexBennasar/Crypto-SAS/blob/2af84a307f66431a09930218dcc3e8b271019a90/Hexadecimal/XOR.sas), the operators can have an arbitrary length, and the output is given in hexadecimal format too, with its length equal to the operators length.
