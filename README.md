![Realm](https://github.com/realm/realm-dart/raw/master/logo.png)

[![License](https://img.shields.io/badge/License-Apache-blue.svg)](LICENSE)

Realm is a mobile database that runs directly inside phones, tablets or wearables.
This repository holds the source code for the Realm SDK for Flutter™ and Dart™.

# Alpha

**This project is in the Alpha stage, All API's might change without warning and no guarantees are given about stability. Do not use it in production.**

The previous preview version of Realm Dart can be found on this branch: https://github.com/realm/realm-dart/tree/preview


### Versioning

Realm Flutter and Dart SDK packages follow [Semantic Versioning](https://semver.org/)
During the initial development the packages will be versioned according the scheme `0.major.minor+release stage` until the first stable version is reached then packages will be versioned with `major.minor.patch` scheme.

The first versions will follow `0.1.0+preview`, `0.1.1+preview` etc.
Then next release stage will pick up the next minor version `0.1.2+beta`, `0.1.3+beta`. This will ensure dependencies are updated on `pub get` with the new `beta` versions.
If an `alpha` version is released before `beta` and it needs to not be considered for `pub get` then it should be marked as `prerelease` with `-alpha` so  `0.1.2-alpha` etc. 
Updating the major version with every release stage is also possible - `0.2.0+beta`, `0.2.1+beta`.

# Code of Conduct

This project adheres to the [MongoDB Code of Conduct](https://www.mongodb.com/community-code-of-conduct).
By participating, you are expected to uphold this code. Please report
unacceptable behavior to [community-conduct@mongodb.com](mailto:community-conduct@mongodb.com).

# License

Realm Dart and [Realm Core](https://github.com/realm/realm-core) are published under the Apache License 2.0.

**This product is not being made available to any person located in Cuba, Iran,
North Korea, Sudan, Syria or the Crimea region, or to any other person that is
not eligible to receive the product under U.S. law.**

##### The "Dart" name and logo and the "Flutter" name and logo are trademarks owned by Google. 
