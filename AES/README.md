# The Advanced Encryption Standard (AES)

This section includes the implementation of the AES in SAS, for performing macrovariable and single dataset variable encryption and decryption. An implementation in SAS of the basic AES algorithm is provided, which transforms a 128-bit message into a 128-bit cryptogram, using a 128, 192 or 256-bit key.

The Advanced Encription Standard (AES) specification can be found [here](https://nvlpubs.nist.gov/nistpubs/fips/nist.fips.197.pdf).

## Installation

### Previous step

The macros in this section perform a precomputation for certain values of the [GF Multiplication](https://en.wikipedia.org/wiki/Finite_field_arithmetic) and the [S-Box](https://en.wikipedia.org/wiki/S-box) needed by the algorithm to work (details [here](https://nvlpubs.nist.gov/nistpubs/fips/nist.fips.197.pdf)). The results of that precomputation is stored in global macrovariables. The user is adviced to **not** create any macrovar in the global namespace whose name begins with:
- gFWord
- SBox
- invSBox

### Step 1: Hexadecimal utility functions

Execute all the files under [Crypto-SAS/Hexadecimal](https://github.com/AlexBennasar/Crypto-SAS/tree/main/Hexadecimal). This will load several macros needed.

### Step2: AES functions

Execute all the files contained in this folder. This will load several macros needed, and will perform the precomputations required on the [Previous step](https://github.com/AlexBennasar/Crypto-SAS/edit/main/AES/README.md#previous-step).
