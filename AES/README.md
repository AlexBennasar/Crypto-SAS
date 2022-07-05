# The Advanced Encryption Standard (AES)

This section includes the implementation of the AES in Base SAS, for performing macrovariable and single dataset variable encryption and decryption. An implementation in SAS of the basic AES algorithm is provided, which transforms a 128-bit message into a 128-bit cryptogram, using a 128, 192 or 256-bit key.

The Advanced Encription Standard (AES) specification can be found [here](https://nvlpubs.nist.gov/nistpubs/fips/nist.fips.197.pdf).

The implementation is 100% Base SAS, without the need of using other languages.

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

## Usage

### Cipher operation

To cipher a message, call this macro:

```SAS
%macro cipherAES
   (M                  /* Message to be encrypted */
   ,K                  /* Encryption key */
   );
```

- M must be a 32-length hexadecimal number (128 bits).
- K can be a 32, 48 or 64-length hexadecimal number (128, 192 or 256 bits).
- The returned cryptogram is a 32-length hexadecimal number (128 bits).

### Decipher operation

To decipher a message, call this macro:

```SAS
%macro invCipherAES
   (C                  /* Message to be decrypted */
   ,K                  /* Decryption key */
   );
```

- C must be a 32-length hexadecimal number (128 bits), result of a previous call to ```%cipherAES```.
- K can be a 32, 48 or 64-length hexadecimal number (128, 192 or 256 bits).
- The returned message is a 32-length hexadecimal number (128 bits).

### Usage in datasets

To cipher or decipher a dataset variable, a tecnique for applying the previous macrofunctions to all the values of that variable is required. For example:

```SAS
/* Compute cryptograms and store them in macrovar */
proc sql noprint;
	select '%cipherAES('||m||','||k||')' into :cryptograms separated by ' ' from testMessages;
quit;

/* Add computed cryptograms to the original dataset */
data testMessagesWithCryptogram;
	set testMessages;
	c=scan("&cryptograms", _n_);
run;
```

## Examples of use

[Crypto-SAS/AES/Test](https://github.com/AlexBennasar/Crypto-SAS/tree/main/AES/Test) contains several usage examples of the macros, using both macrovariables and values stored in dataset variables.

## Testing
All the code developed have been tested in SAS Studio, release 3.8 (SAS release: 9.04.01M6P11072018).
