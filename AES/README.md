# The Advanced Encryption Standard (AES)

This section includes the implementation of the AES in SAS, for performing macrovariable and single dataset variable encryption.

## Basic-Algorithm

In this section we provide an implementation in SAS of the basic AES algorithm, which transforms a 128-bit message into a 128-bit cryptogram, using a 128, 192 or 256-bit key.

This functionality is the basic block of SAS variable encryption, but only with it, the user can't encrypt messages of an arbitrary length, and can't derive strong cryptographic keys. Further implementations of [Key Derivation Functions](https://en.wikipedia.org/wiki/Key_derivation_function), [Padding Schemes](https://en.wikipedia.org/wiki/Padding_(cryptography)) and [Block Cypher Modes](https://en.wikipedia.org/wiki/Block_cipher_mode_of_operation) will be added in the near future.
