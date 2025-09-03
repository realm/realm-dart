# Realm Files - Flutter SDK
A **realm** is the core data structure used to organize data in
Realm. A realm is a collection of the objects that you use
in your application, called Realm objects, as well as additional metadata
that describe the objects. To learn how to define a Realm object, see
Define a Realm Object Schema.

When you open a realm, you can include configuration that specifies additional details
about how to configure the realm file. This includes things like:

- Pass a file path or in-memory identifier to customize how the realm is stored on device
- Specify the realm use only a subset of your app's classes
- Whether and when to compact a realm to reduce its file size
- Pass an encryption key to encrypt a realm
- Provide a schema version or migration block when making schema changes

## Realm Files
Realm stores a binary encoded version of every object and type in a
realm in a single `.realm` file. The file is located at a specific
path that you can define when you open the realm.
You can also open, view, and edit the contents of these files with Realm Studio.

### Auxiliary Files
Realm creates additional files for each realm:

- **realm files**, suffixed with "realm", e.g. `default.realm`:
contain object data.
- **lock files**, suffixed with "lock", e.g. `default.realm.lock`:
keep track of which versions of data in a realm are
actively in use. This prevents realm from reclaiming storage space
that is still used by a client application.
- **note files**, suffixed with "note", e.g. `default.realm.note`:
enable inter-thread and inter-process notifications.
- **management files**, suffixed with "management", e.g. `default.realm.management`:
internal state management.

Deleting these files has important implications.
For more information about deleting `.realm` or auxiliary files, see Delete a Realm.
