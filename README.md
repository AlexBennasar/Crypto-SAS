# Cryptographic algorithms and protocols in SAS language

## Introduction

In SAS language, you can encrypt a full dataset, and there are a few cryptographic primitives that can be applied at variable level.

More precisely, with the [encryption providers included in Base SAS](https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/secref/n0gzdro5ac3enzn18qbmaqy4liz3.htm), users can:
- encrypt stored login passwords, using proprietary SAS algorithms and AES with salt (see [PWENCODE Procedure](https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/secref/n1vzmasf0tdebfn1xec0k1tevq7q.htm) for more details).

- encrypt full datasets with a password, using proprietary SAS algorithms or AES (see [SAS Data File Encryption](https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/lepg/n1s7u3pd71rgunn1xuexedikq90f.htm) for more details).

There are also [SAS functions](https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.2/lefunctionsref/n05ptq6zr5amxkn18mjkyvbkjjos.htm) to compute [Hashing Functions](https://en.wikipedia.org/wiki/Hash_function) and [Hash-Based Message Authentication Code (HMAC)](https://en.wikipedia.org/wiki/HMAC) on a dataset variable, but users can't perform a variable-level encryption. Regarding this issue, SAS [encourages users](https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/lrcon/p0ori2cs0xf6ign13vmzmkqgtqap.htm) to implement their own encryption and decryption algorithms, and provide 3 examples of encryption scheme implementations.

Unfortunately, those implementations are not enough if the confidentiality of the variable is critical, as they basically rely on [Substitution Cipher](https://en.wikipedia.org/wiki/Substitution_cipher#Substitution_in_modern_cryptography) solutions. Some stronger solution is required to really ensure the data is kept secret.

## The Advanced Encryption Standard (AES)
In this project we provide and implementation for the AES in SAS. With it, the user can encrypt macrovariables and dataset variables, without the need of performing full dataset encryption in this last case.

Several algorithms will be added in near future.
