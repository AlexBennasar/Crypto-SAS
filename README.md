# Cryptographic algorithms and protocols in SAS language

In SAS language, you can encrypt a full dataset, and there are a few cryptographic primitives that can be applied at variable level.

More precisely, with the [encryption providers included in Base SAS](https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/secref/n0gzdro5ac3enzn18qbmaqy4liz3.htm), users can:
- encrypt stored login passwords, using proprietary SAS algorithms and AES with salt (see [PWENCODE Procedure](https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/secref/n1vzmasf0tdebfn1xec0k1tevq7q.htm) for more details).

- encrypt full datasets with a password, using proprietary SAS algorithms or AES (see [SAS Data File Encryption](https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/lepg/n1s7u3pd71rgunn1xuexedikq90f.htm) for more details).

There are also [SAS functions](https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.2/lefunctionsref/n05ptq6zr5amxkn18mjkyvbkjjos.htm) to compute [Hashing Functions](https://en.wikipedia.org/wiki/Hash_function) and [Hash-Based Message Authentication Code (HMAC)](https://en.wikipedia.org/wiki/HMAC) on a dataset variable, but you can't perform a variable-level encryption with, for example, the Advanced Encryption Standard (AES).

## The Advanced Encryption Standard (AES)
In this project we provide and implementation for the AES in SAS. With it, the user can encrypt macrovariables and dataset variables, without the need of performing full dataset encryption in this last case.

Several algorithms will be added in near future.
