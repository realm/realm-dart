# Encrypt a Realm - Flutter SDK
## Overview
You can encrypt your realms to ensure that the data stored to disk can't be
read outside of your application. You encrypt the realm on
disk with AES-256 + SHA-2 by supplying a 64-byte encryption key when
opening a realm.

Realm transparently encrypts and decrypts data with standard
[AES-256 encryption](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard) using the
first 256 bits of the given 512-bit encryption key. Realm
uses the other 256 bits of the 512-bit encryption key to validate
integrity using a [hash-based message authentication code
(HMAC)](https://en.wikipedia.org/wiki/HMAC).

> **WARNING:**
> Do not use cryptographically-weak hashes for realm encryption keys.
For optimal security, we recommend generating random rather than derived
encryption keys.
>

> **NOTE:**
> You must encrypt a realm the first time you open it.
> If you try to open an existing unencrypted realm using a
> configuration that contains an encryption key, Realm throws an
> error.
>
> Alternatively, you can copy the unencrypted realm data to a new encrypted realm using the
> [Realm.writeCopy()](https://pub.dev/documentation/realm/latest/realm/Realm/writeCopy.html) method.
> Refer to Copy Data into a New Realm for more information.
>

## Considerations
The following are key impacts to consider when encrypting a realm.

### Storing & Reusing Keys
You **must** pass the same encryption key in the realm's
[Configuration.encryptionKey](https://pub.dev/documentation/realm/latest/realm/Configuration/encryptionKey.html)
property every time you open the realm. The key must be a 64-byte `List<int>`.
To create a key that meets this specification, the List must contain exactly 64 integers
and all integers must be between 0 and 255.

If you don't provide a key or specify the wrong key for an encrypted
realm, the Realm SDK throws an error.

Apps should store the encryption key securely, typically in the target
platform's secure key/value storage, so that other apps cannot read the key.

### Performance Impact
Reads and writes on encrypted realms can be up to 10% slower than unencrypted realms.
