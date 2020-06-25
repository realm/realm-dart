# 4.9.5 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* Connecting via SSL would crash on iOS 11.x due to an incorrect version
  availability check around an API introduced in iOS 12. (Since 4.9.3).

### Enhancements
* None.

### Compatibility
* No change

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* None.

### Internal Bugfixes
* Properly handle the case where `on_changesets_integrated()` is called
  asynchronously with respect to `initiate_integrate_changesets()` in
  `_impl::ClientImplBase::Session`. Currently, this happens only on a subtier
  node of a star topology server cluster.

### Internal Enhancements
* Add utility headers `<realm/util/file_is_regular.hpp>` and `<realm/util/copy_dir_recursive.hpp>`.

-----------

## Sync team internal change notes
* Fixed issues preventing building of inspector toolset.

## Dependencies
* Uses core-5.23.8

----------------------------------------------


# 4.9.4 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* Untrusted SSL certificates were treated as transient rather than fatal errors
  on Apple platforms (since 4.9.3).

### Enhancements
* None.

### Compatibility
* No change

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* None.

### Internal Bugfixes
* Command-line tool `realm-vacuum`: Actually implement the effect of
  `--no-file-compaction` (do not perform file space defragmentation). So far,
  that option has been silently ignored.

### Internal Enhancements
* Server: New configuration option for enabling the 'ignore clients' mode of
  in-place history compaction. Please see documentation for
  `sync::Server::Config::history_compaction_ignore_clients`. This option is also
  available as `historyCompactionIgnoreClients` in the server's Node.js binding,
  and as `--history-compaction-ignore-clients` on the command line.
* Server: Configuration parameter `log_compaction_clock` renamed to
  `history_compaction_clock` in `sync::Server::Config` for consistency.
* Improve the message returned by `std::error_code::message()` for the
  SecureTransport error code category, i.e., for
  `util::network::SecureTransportErrorCategory`.

-----------

## Sync team internal change notes
* None.

## Dependencies
* Uses core-5.23.8

----------------------------------------------


# 4.9.3 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* Tables would survive during a client reset where a new realm file without the tables
  was downloaded - even though recover_local_changes was set to false.
  (Issue: https://jira.mongodb.org/browse/RJS-348)

### Enhancements
* Log a more descriptive error message when SSL certificate validation fails on
  Apple platforms.

### Compatibility
* No change

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* None.

### Internal Bugfixes
* None.

### Internal Enhancements
* Command-line tool `realm-hist`: Added new option `--instruction-type
  <type>`. This lets you search for history entries whose changeset contains a
  particular type of instruction.
* Command-line tool `realm-hist`: Added new option `--client-file-types
  <types>`. This lets you choose which types of client file entries to include
  when using `--client-files`.
* Command-line tool `realm-hist`: Added new options
  `--also-expired-client-files`, `--only-expired-client-files`, and
  `--only-unexpired-client-files`. These let you choose wether to include exired
  only, nonexpired only (the default), or both expired and nonexpired client
  file entries when using `--client-files`.
* Command-line tool `realm-hist`: Added new options `--min-last-seen-timestamp
  <timestamp>`, `--max-last-seen-timestamp <timestamp>`, and
  `--max-locked-version <version>`. Among other things, these let you figure out
  how many client files entries are blocking in-place history compaction from
  progressing beyond a certain point. Use `--help`, and see explnation of
  `--max-locked-version` for more on this.
* Bumped Core dependency to 5.23.8.

-----------

## Sync team internal change notes
* None.

## Dependencies
* Uses core-5.23.8

----------------------------------------------


# 4.9.2 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* None.

### Enhancements
* In-place history compaction can now be invoked in a mode where it ignores
  recorded last access times for clients, and instead looks at the apparent age
  of history entries. This is not something that should be done except in
  situations of emergency, as it should be expected to force some (especially
  new) clients to go through a reset operation regardless of how recently they
  have been active. In-place history compaction can be invoked only by use of
  the command line tool `realm-vacuum`, and only by specifying the
  `--ignore-clients` option. When using `realm-vacuum` for the purpose of
  invoking in-place history compaction, be sure to specify an appropriate "time
  to live" value (`--server-history-ttl`).

### Compatibility
* No change

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* None.

### Internal Bugfixes
* None.

### Internal Enhancements
* None.

-----------

## Sync team internal change notes
* None.

## Dependencies
* Uses core-5.23.7

----------------------------------------------


# 4.9.1 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* Under special circumstances, the server or client could become unresponsive
  during automatic conflict resolution. In most cases, the server would be more
  severely affected than the client (also fixed in 4.8.4-hotfix.1).

### Enhancements
* None.

### Compatibility
* No change

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* None.

### Internal Bugfixes
* Fixed a bug that made a serialized transaction fail when synchronous backup
  was enabled (clear
  `WorkInProgress::integration_result.accepted_serial_transact` in
  `ServerFile::finalize_work_stage_2()` rather than in
  `ServerFile::initiate_backup()`).

### Internal Enhancements
* Commandline tools `realm-dump`, `realm-stat`, `realm-hist`,
  `realm-server-index`, and `realm-verify-server-file` have been equipped with a
  `--version` (or `-v`) commandline option to show the version of the Realm Sync
  release that they belong to, as well as the build mode (`Release` or `Debug`).
* Server: Consistency of client's specification of `<is subserver>` in BIND
  message is now required by protocol specification, and verified by the server.
* Bumped Core dependency to 5.23.7.

-----------

## Sync team internal change notes
* Unit test `Sync_ServerHistoryCompaction_ReadOnlyClients` has been fixed.
* Class `WorkInProgress` in `realm/sync/server.cpp` was renamed to just `Work`.
* A call to `std::list::size()` had O(n) performance on libstdc++ using the
  pre-C++11 ABI. This was triggered through `ChangesetIndex::get_num_conflict_groups()`,
  and especially problematic for merge windows touching a huge number of different
  objects (also fixed in 4.8.4-hotfix.1).

## Dependencies
* Uses core-5.23.7

----------------------------------------------


# 4.9.0 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* None

### Enhancements
* Server: Improvements to in-place history compaction. Compaction in a reference
  file is no longer artificially held back by clients of partial views. The
  improvement will take immediate effect for new reference files. For
  preexisting reference files, time will need to pass before the change becomes
  fully effective. The amount of time that needs to pass, corresponds to the
  "time to live" configuration parameter setting for the in-place history
  compaction feature
  (`sync::Server::Config::history_ttl`). [RSYNC-62](https://jira.mongodb.org/browse/RSYNC-62).

### Compatibility
* The synchronization protocol version has been bumped from 29 to 30. The server
  side remains compatible with protocol versions back to, and including 22. The
  client side remains compatible with protocol versions back to, and including
  26.
* New protocol-level error code 222 "Client file has expired". This one is
  generated by the server when the association between a client and a
  server-side file expires due to in-place history compaction. This can happen
  while the client is connected (due to inherent, but benign race conditions),
  but mostly, it will happen as the client attempt to connect to the server
  after a long period of being offline.
* Server: Server-side history schema has changed. The schema version was bumped
  from 9 to 10. Transparent forward migration is provided, but, as usual, there
  is no provision for migration in the reverse direction, so it is effectively
  irreversible.
* Server: Backup protocol version bumped from 3 to 4. All nodes in a backup
  cluster must run the same backup protocol version.

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* Member `downloadable_bytes` removed from `sync::SyncProgress`. As part of
  `_impl::ClientImplBase::Session::m_progress`, it served no purpose, and its
  value could not feasibly be kept correct, so it was deemed a liability. It
  also never belonged in `sync::SyncProgress` in the first place.
* Functions `set_sync_progress()` and `integrate_server_changesets()` in
  `sync::ClientHistoryBase` received a new option `downloadable_bytes` parameter
  to make up for the removal of `downloadable_bytes` from `sync::SyncProgress`.

### Internal Bugfixes
* Serialized transactions: Avoid setting persistent record of
  `downloadable_bytes` (client side) to zero when finalizing a serialized
  transaction. Since the serialized transactions feature has not been exposed by
  higher-level APIs yet, no one is expected to have been impacted.

### Internal Enhancements
* A `client_types` column has been added to the `client_files` table in the
  history compartment of server-side files. This provides for a much clearer
  categorization of entries in that table. This, in turn, has paved the way for
  improvements to in-place history compaction, which is no longer held back by
  entries associated with clients of partial views. It has also lead to numerous
  improvements in the `realm-hist` command line tool.
* Command line tool `realm-hist` has been improved. By default, `realm-hist
  --client-files` will now only show client file entries associated with direct
  clients (regular clients, subservers, and partial views). To show all entries,
  use `--all-client-files`.

-----------

## Sync team internal change notes
* Subservers in a star topology cluster now specify an appropriate `User-Agent`
  HTTP header when they connect to the upstream server.

## Dependencies
* Uses core-5.23.6

----------------------------------------------


# 4.8.4-hotfix.1 Release notes

NOTE: This is a hotfix release. This means that the changes introduced here are not included in
subsequent releases up to and including 4.9.0.

### Bugfixes
* Under special circumstances, the server or client could become unresponsive
  during automatic conflict resolution. In most cases, the server would be more
  severely affected than the client.

-----------

## Sync team internal change notes
* A call to `std::list::size()` had O(n) performance on libstdc++ using the
  pre-C++11 ABI. This was triggered through `ChangesetIndex::get_num_conflict_groups()`,
  and especially problematic for changesets touching a huge number of different
  objects.

## Dependencies
* Uses core-5.23.6

----------------------------------------------


# 4.8.4 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* None.

### Enhancements
* Server no longer returns error code 214 when clients perform state requests on
  partial realms. It now returns an empty state, which allows the client to
  resync.

### Compatibility
* None.

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* None.

### Internal Bugfixes
* None.

### Internal Enhancements
* None.

-----------

## Sync team internal change notes
* None.

## Dependencies
* Uses core-5.23.6

----------------------------------------------


# 4.8.3 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* Eliminate use of dangling accessors after commit in
  `ClientHistoryImpl::integrate_server_changesets()`. This bug exists only in
  debug mode builds. In debug mode builds it will occasionally cause a
  crash. Since Sync 2.0.0. [RSYNC-71](https://jira.mongodb.org/browse/RSYNC-71).

### Enhancements
* None.

### Compatibility
* No change

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* None.

### Internal Bugfixes
* None.

### Internal Enhancements
* None.

-----------

## Sync team internal change notes
* None.

## Dependencies
* Uses core-5.23.6

----------------------------------------------


# 4.8.2 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* Client: Resume sync with correct server version after failure to integrate. A
  client may fail to integrate a received changeset if inconsistency has arisen
  between the server and itself. Such inconsistency will be due to some other
  bug. If this happens, the synchronizing agent (client) will suspend itself for
  roughly one hour before reconnecting and attempting to resume
  synchronization. When reconnecting, the client should ask to resume from a
  point before the integration failure, but did not, due to the bug. After being
  triggered, as explained, this bug would almost always result in (further)
  client-side corruption. Since Sync 2.3.1 (star
  topology). [RSYNC-48](https://jira.mongodb.org/browse/RSYNC-48).

### Enhancements
* None.

### Compatibility
* No change

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* None.

### Internal Bugfixes
* None.

### Internal Enhancements
* None.

-----------

## Sync team internal change notes
* None.

## Dependencies
* Uses core-5.23.6

----------------------------------------------


# 4.8.1 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* Fixed bug in newly introduced migration of history schema from version 8 to 9
  (incorrect initialization of column accessors). Since
  4.8.0. [RSYNC-63](https://jira.mongodb.org/browse/RSYNC-63).

### Enhancements
* None.

### Compatibility
* No change

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* None.

### Internal Bugfixes
* None.

### Internal Enhancements
* None.

-----------

## Sync team internal change notes
* None.

## Dependencies
* Uses core-5.23.6

----------------------------------------------


# 4.8.0 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* Server: Fix for not deleting the Realm file when state Realms are disabled.
  This has been a bug since the introduction of state Realms in version 4.3.0
  that had gone unnoticed due to state Realms being enabled by default.
* Server: Elimination of a bug, that involved unreliable updating of the
  `last_compaction_timestamp` field in the history compartment of server-side
  files. While it is now updated more reliably, its value has also become less
  important due to the switch to a more robust way of marking a client file
  entry as expired (since Sync 3.4.0, May 9, 2018).
* Server: Elimination of a race condition, that could allow clients to continue
  synchronization after being expired by in-place history compaction on the
  server side, if the client tried to connect at roughly the same time as it
  expired. It turned out to not be feasible to completely prevent expiration of
  client file entries with sessions in progress. Instead, the solution was to
  allow expiration, but disconnect the clients whose entries expire (since Sync
  3.4.0, May 9, 2018).
* Server: Removal of an unsafe and superfluous invocation of history compaction
  from `ServerFile::worker_process_work_unit()` in `realm/sync/server.cpp`
  (since Sync 3.4.0, May 9, 2018).

### Enhancements
* Server: Introduction of a new scheme for marking client file entries as
  expired in server-side files (`last_seen_timestamp == 0`). In the process of
  doing so, multiple bugs / robustness issues, relating to compaction and
  expiration of client file entries, were fixed.
* The protocol specification was updated to explicitly prohibit a client from
  asking to resume download from a point earlier than the server version on
  which an uploaded changeset was based (i.e., the base version of the
  reciprocal history). Besides being superfluous, this is now also a protocol
  violation.

### Compatibility
* A change was needed in the history schema on the server side. This bumps the
  server-side history schema version from 8 to 9. Transparent forward migration
  is provided, but, as usual, there is no provision for the reverse migration,
  so it is effectively irreversible.

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* None.

### Internal Bugfixes
* None.

### Internal Enhancements
* None.

-----------

## Sync team internal change notes
* None.

## Dependencies
* Uses core-5.23.6

----------------------------------------------


# 4.7.12 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* Bumped Core dependency to version 5.23.6, fixing a corruption issue with
  encrypted realms.

### Enhancements
* JWT parser will now recognize `path`, `syncLabel`, and `access` fields from an
  embedded object in the JSON called `stitch_data` to allow access tokens
  generated by stitch to be used for sync sessions.

### Compatibility
* No change

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Dependencies
* Uses core-5.23.6

----------------------------------------------


# 4.7.11 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* Remove some incorrect assertions that rejected Realm files where an int
  primary key column was not the first column in a table. Since 3.13.3.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Internal Bugfixes
* Commandline tool `realm-hist` is now emitting changesets to `STDOUT` instead
  of `STDERR` when `--format` is `changeset`.

### Internal Enhancements
* Commandline option `--with-versions` was added to commandline tool
  `realm-hist`. When specified, versions are shown for each changeset when
  `--format` is `changeset` or `hexdump`.
* New history filtering capabilities added to command-line tool
  `realm-hist`. For example, one can now select only those changesets that
  modify a particular object. New command-line options are `--class`,
  `--object`, `--property`, `--modifies-object`, `--modifies-property`, and
  `--links-to-object`.

-----------

## Sync team internal change notes
* Commandline option `--max-download-size` was added to sync server command.

## Dependencies
* Uses core-5.23.5

----------------------------------------------


# 4.7.10 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* None.

### Enhancements
* Added guards to client and server to catch cases where the client or server
  object is destroyed while the event loop thread is still executing the `run()`
  method. These guards are also effective when the code is built in release
  mode.

### Compatibility
* No change

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* None.

### Internal Bugfixes
* None.

### Internal Enhancements
* None.

-----------

## Sync team internal change notes
* Support for multiphased schedule of performing transactions was added to the
  test client (`--next-phase`).

## Dependencies
* Uses core-5.23.5

----------------------------------------------


# 4.7.9 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* Get rid of incorrect assertion which occasionally crashed the server when the
  server is built in debug mode. Since 4.7.0.

### Enhancements
* Improve performance of changeset scanning. For changesets involving large
  numbers of objects that are otherwise cheap to process this speeds up
  changeset integration by ~20%.
  ([PR #3128](https://github.com/realm/realm-sync/pull/3128)).

### Compatibility
* No change

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* None.

### Internal Bugfixes
* None.

### Internal Enhancements
* None.

-----------

## Sync team internal change notes
* A suite of protocol compatibility tests has been added
  (`/test/protocol_compat`).

## Dependencies
* Uses core-5.23.5

----------------------------------------------


# 4.7.8 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* None.

### Enhancements
* None.

### Compatibility
* No change

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* None.

### Internal Bugfixes
* None.

### Internal Enhancements
* Bumped Core dependency to 5.23.5.

-----------

## Sync team internal change notes
* None.

## Dependencies
* Uses core-5.23.5

----------------------------------------------


# 4.7.6 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* Server: Fix for new bug causing inconsistency between upload progress and
  upload threshold when receiving UPLOAD messages from clients using protocol
  versions earlier than 29 (Sync 4.6 and below). Issue
  [SYNC-27](https://jira.mongodb.org/browse/SYNC-27). Since 4.7.4.

### Enhancements
* Server: Command-line tool `realm-hist` can now be used to inspect the "client
  files" registry in a server-side Realm file.

### Compatibility
* No change

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* None.

### Internal Bugfixes
* None.

### Internal Enhancements
* None.

-----------

## Sync team internal change notes
* None.

## Dependencies
* Uses core-5.23.3

----------------------------------------------


# 4.7.5 Release notes

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Internal Enhancements
* Update Core dependency to 5.23.3.

-----------

## Sync team internal change notes
* Changed the default metrics exclusions to `Core_ALL`, meaning that core
  metrics are opt-in rather than opt-out.

## Dependencies
* Uses core-5.23.3

----------------------------------------------


# 4.7.4 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* Server: New fix for bug causing inconsistency between upload progress and
  upload threshold when receiving UPLOAD messages from clients using protocol
  versions earlier than 29 (Sync 4.6 and below). The previous fix (Sync 4.7.3)
  was incorrect. Issue [SYNC-14](https://jira.mongodb.org/browse/SYNC-14). Since
  4.7.0.
* Server: Fix for bug introduced in Sync 4.7.3 that would leave
  `progress_server_version` uninitialized when receiving UPLOAD messages from
  clients using protocol versions earlier than 29 (Sync 4.6 and below). Since
  `progress_server_version` is used to trim reciprocal history, this bug is
  expected to have caused corruption of the association between client and
  server-side files for many clients. Since 4.7.3.

### Enhancements
* None.

### Compatibility
* No change

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* None.

### Internal Bugfixes
* None.

### Internal Enhancements
* Various improvements to logging.
* Bumped Core dependency to 5.23.2.

-----------

## Sync team internal change notes
* None.

## Dependencies
* Uses core-5.23.2

----------------------------------------------


# 4.7.3 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* Server: Fixed a bug where clients using protocol versions 25 through 28 would
  receive `Bad server version` errors, with log messages on the server such as
  "Upload progress (x, y) is mutually inconsistent with threshold (a, b)".
  (Issue [SYNC-14](https://jira.mongodb.org/browse/SYNC-14), since 4.7.0).

-----------

## Sync team internal change notes

* Server: For protocol versions 25 through 28, the `last_server_version` field
  interpreted as `progress_server_version`. But this is inconsistent with the
  progress reported by the client in the `IDENT` message, because of the empty
  UPLOAD message, which does not source the value for `last_server_version` from
  uploadable client history entries, but from the client history entries
  received from the server. This underlying inconsistency was fixed in #2999,
  however the server must still account for the old behavior.

## Dependencies
* Uses core-5.23.1

----------------------------------------------


# 4.7.2 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Internal Enhancements
* Access token metadata will also be parsed using canonical JWT keys (`iat`, `sub`, `exp`, etc.)

-----------

## Sync team internal change notes
* Synchronization is now optional when running the test client. If the server
  URL is not specified, no synchronization will take place.

## Dependencies
* Uses core-5.23.1

----------------------------------------------


# 4.7.1 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Enhancements
* Client: Added experimental support for HTTP proxies. This is configured in the
  new field `Session::Config::proxy_config`.

### Compatibility
* No change

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* Added a new client error code `realm::sync::Client::Error::http_tunnel_failed`
  that signifies failure to negotiate tunnel with proxy.

-----------

## Dependencies
* Uses core-5.23.1

----------------------------------------------


# 4.7.0 Release Notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* Pinned snapshot exposed history corruption after client reset. History is now
  trimmed during client reset to avoid the problem. [Issue
  #3000](https://github.com/realm/realm-sync/issues/3000).
* Eliminated a race condition that could cause a request for "state size
  recomputation" to be ignored.
* Do not compact history when history compaction is disabled
  (`disable_history_compaction` in `sync::Server::Config`). Until now, and
  probably since the introduction of state Realms (version 4.3.0), history
  compaction was done in some cases regardless of the configuration parameter
  that was supposed to control it. This matters, because history compaction can
  be seriously expensive.

### Enhancements
* Changesets in the cooked history are now stored together with a corresponding
  server version. For a particular cooked changeset, the server version is the
  one that was produced on the server by an earlier form of the cooked
  changeset. A Client, that works as a bridge between a Realm server and another
  storage system, can use this information to enable reliable fail-over from one
  instance of the client to another. For more on this, see
  ([`doc/cooked_history.md`](doc/cooked_history.md)).
* The synchronization protocol and the server now supports a "locked server
  version" feature, which means that the client can specify a server version
  different from "last integrated server version" of the upload progress, and
  this will cause the server to abstain from trimming away or compacting the
  part of the history that lies before this version. This is intended to be
  coupled to the consumption of the "cooked history", and to make "cooking
  clients" (data adapters) tolerant to fail-over.
* Information about schema version of history compartment is now recorded at
  file creation time and whenever the the file is migrated from one history
  compartment schema version to another. This happens for both client and
  server-side files. The information can be retrieved using the `realm-stat`
  command line tool. Each stored record specifies the new history compartment
  schema version, the sync library version, the snapshot number of the Realm
  file, and a timestamp. The purpose of this is to help during future debugging
  sessions.
* A new command-line tool `realm-hist` has been added. It can be used to inspect
  the synchronization history in client and server-side Realm files. It is
  intended as a supplement to the already existing tools, `realm-stat`
  (summarize contents of a Realm file) and `realm-dump` (dump payload data from
  a Realm file).
* New options `--server-history-ttl` and `--log-level` added to commandline tool
  `realm-vacuum`.
* From now on, it is no longer possible to switch between using and not using a
  changeset cooker after synchronization with the server has commenced. Even
  though it was possible before, it would have been an error to do so.

### Compatibility
* A change was needed in the history schema on the client side. This bumps the
  client-side history schema version from 1 to 2. Transparent forward migration
  is provided, but, as usual, there is no provision for the reverse migration,
  so it is effectively irreversible.
* A change was needed in the history schema on the server side. This bumps the
  server-side history schema version from 7 to 8. Transparent forward migration
  is provided, but, as usual, there is no provision for the reverse migration,
  so it is effectively irreversible.

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* Type `LocalChangeset`, and functions `set_initial_collision_tables()`,
  `set_initial_state_realm_history_numbers()`,
  `set_client_file_ident_and_downloaded_bytes()`,
  `set_client_file_ident_in_wt()`, `get_next_local_changeset()`, and
  `set_client_reset_adjustments()` have been removed from class
  `sync::ClientHistory`. These are now only available through the implementing
  class `_impl::ClientHistoryImpl`. This type and these function are all related
  to the "async open" and the "client reset" features.
* Configuration parameter `enable_upload_log_compaction` in
  `sync::Client::Config` was replaced by `disable_upload_compaction`. Compaction
  during upload (removal of superfluous instructions) remains enabled by
  default.
* Configuration parameter `enable_download_log_compaction` in
  `sync::Server::Config` was replaced by
  `disable_download_compaction`. Similarly, `enable_download_log_compaction` was
  replaced by `disable_download_compaction` in
  `config::Configuration`. Compaction during download (removal of superfluous
  instructions) remains enabled by default. Note, this change does not affect
  the server's Node.js API.
* Configuration parameter `enable_log_compaction` in `sync::Server::Config` was
  replaced by `disable_history_compaction`. Similarly,
  `history_compaction_enabled` was replaced by `disable_history_compaction` in
  `config::Configuration`. In-place compaction of the synchronization history
  remains enabled by default. Note, this change does not affect the server's
  Node.js API.
* Signature changed for function `find_uploadable_changesets()` in
  `sync::ClientHistoryBase`. This function now determines the appropriate value
  to be used for `<locked server version>` in DOWNLOAD messages.

### Internal Bugfixes
* Fixed a race condition that could produce an inconsistent state of
  `WorkInProgress::version_info` after the invocation of
  `ServerHistory::compact_history()` from
  `ServerFile::worker_process_work_unit()` in `server.cpp`.

### Internal Enhancements
* The synchronization history on the client side is no longer trimmed at the
  same times and to the same point as the continuous transactions history. Until
  now, those two histories were always trimmed at the same time, and to the same
  point. The change allows for more aggressive trimming which is always good,
  but it was required at this time in order to solve a problem with the upcoming
  "client reset" feature. [Issue
  #3007](https://github.com/realm/realm-sync/issues/3007).
* A column of locked server versions has been added to the "client files" table
  in the server-side history compartment.
* New functions `get_cooked_status()` and `get_cooked_changeset()` added to
  `sync::ClientHistory` for the purpose of managing the server versions that are
  now associated with cooked changesets. `get_cooked_changeset()` is an overload
  that returns the server version along with the cahngeset.
* Function `set_cooked_progress()` in `sync::ClientHistory` now returns the
  snapshot number produced by the transaction inside it. This should be passed
  to `nonsync_transact_notify()` in `sync::Session`.

-----------

## Sync team internal change notes
* Added a slot for `progress_upload_server_version` to the root array of the
  client-side history compartment.
* Reorder slots in root array of the client-side history compartment.
* `test_sync_log_compaction.cpp` in `test/` was renamed to
  `test_sync_server_history_compaction.cpp` (to reduce the number of distinct
  things called "log compaction").
* `test_metrics.cpp` in `test/` was renamed to `test_sync_server_metrics.cpp`.
* Options `--disable-history-compaction` and `--disable-download-compaction`
  were added to the server command.
* Options `--disable-upload-compaction` and `--use-trivial-cooker` was added to
  the test client (`test/client/test-client`).

## Dependencies
* Uses core-5.23.1

----------------------------------------------


# 4.6.4 Release Notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* The `core.query` metrics were emitting an unescaped character causing parse
  errors.

### Enhancements
* None.

### Compatibility
* No change

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* None.

### Internal Bugfixes
* None.

### Internal Enhancements
* None.

-----------

## Sync team internal change notes
* None.

## Dependencies
* Uses core-5.23.1

----------------------------------------------


# 4.6.3 Release Notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* None.

### Enhancements
* None.

### Compatibility
* No change

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* None.

### Internal Bugfixes
* None.

### Internal Enhancements
* None.

-----------

## Sync team internal change notes
* None.

## Dependencies
* Uses core-5.23.1

----------------------------------------------


# 4.6.2 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* None.

### Enhancements
* None.

### Compatibility
* No change

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* None.

### Internal Bugfixes
* None.

### Internal Enhancements
* Bumped Core dependency to 5.23.0.

-----------

## Sync team internal change notes
* None.

## Dependencies
* Uses core-5.23.0

----------------------------------------------


# 4.6.1 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* None.

### Enhancements
* Added new metrics tracking core query and transaction statistics.
  [#2829](https://github.com/realm/realm-sync/pull/2829).
* Added a new server config `metricsExclusions` which allows users to opt-out
  of various metrics, including the newly added ones above.

### Compatibility
* No change

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* None.

### Internal Bugfixes
* None.

### Internal Enhancements
* Bumped Core dependency to 5.22.0.

-----------

## Sync team internal change notes
* Introduce a new unit test for comprehensive testing of migration from earlier
  history schema versions on both client and server side
  (`Sync_HistoryMigration`).

## Dependencies
* Uses core-5.22.0

----------------------------------------------


# 4.6.0 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* None.

### Enhancements
* Added support for *Serialized Transactions*. A serialized transaction is one
  that is guaranteed to only succeed if it can be applied everywhere (and in
  particular, on the server) without being merged with causally unrelated
  changes. A serialized transaction can only complete at times where the client
  is able to communicate with the server. This new feature comes with three new
  public functions in `sync::Session`: `async_initiate_serial_transact()`,
  `async_try_complete_serial_transact()`, and `abort_serial_transact()`. See
  also [doc/serialized_transactions.md](doc/serialized_transactions.md).

### Compatibility
* No change

### Breaking changes (non-backwards compatible. Only for Major versions)
* The synchronization protocol version has been bumped to version 28 in
  connection with the implementation of serialized transactions. Full backwards
  compatibility is retained on both client and server side, although, serialized
  transactions are possible only when both client and server support version 28
  of the protocol.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* New error code `operation_not_supported` in `util::MiscExtErrors`.
* New error code `transact_before_upload` in `sync::ProtocolError`.
* New error codes `bad_serial_transact_status` and `bad_object_id_substitutions`
  in `sync::Client::Error`.

### Internal Bugfixes
* Fix a thread-safety issue in `StateRealms::get_compactable_server_version()`
  that caused a data race on the PRNG object owned by the server's network event
  loop thread.
* Realm file state transfers (part of async open and client reset) will now be
  disabled if client and server do not agree on client-side file format and
  history schema. In such cases, the client will be forced to go through
  conventional incremental synchronization, which is believed to be slower than
  state transfers. Prior to the new protocol version 28, Realm file state
  transfers will be unconditionally disabled. [Issue
  #2919](https://github.com/realm/realm-sync/issues/2919).

### Internal Enhancements
* New public member functions
  `sync::ClientHistory::get_upload_anchor_of_current_transact()` and
  `sync::ClientHistory::get_sync_changeset_of_current_transact()`.
* Server: Reintroduced stronger checking of UPLOAD messages (nondecreasing
  `<server version>` across a sync session).
* New sync server configuration parameter `disable_serial_transacts` in
  `sync::Server::Config` (`disableSerialTransacts` from Node.js and
  `--disable-serial-transacts` from command line).
* CI now triggers a TSAN run.
* Bumped Core dependency to 5.21.0.

-----------

## Sync team internal change notes
* Exclude unit tests `Sync_Partial_Fuzz` and `Sync_FuzzCases_1` when test suite
  is built in thread sanitizer mode. While those unit tests do trigger deadlock
  warnings from the thread sanitizer due to inconsistency in the order of
  acquisition of locks concurrently held by a single thread, it is believed that
  those unit tests are constructed in a way that avoid such deadlocks.
* Implementation of client-side history moved from `sync/history.cpp` to
  `noinst/client_file_impl.hpp` and `noinst/client_file_impl.cpp`.

## Dependencies
* Uses core-5.21.0

----------------------------------------------


# 4.5.1 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* Server: A regression was introduced in version 4.3.0 (and reintroduced in 4.5.0) that could
  cause the server to decide to perform full history compaction on every upload, causing severe
  performance degradation. (Issue [#2962](https://github.com/realm/realm-sync/issues/2962),
  since 4.3.0)

### Compatibility
* No change

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* None.

-----------

## Dependencies
* Uses core-5.20.0 (Fixes metrics reporting exabytes, and wrongly reporting corrupted files)

----------------------------------------------


# 4.5.0 Release notes
NOTE: This was based on 4.4.2, and thus does not include the regression fixed in 4.4.4.

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* None.

### Enhancements
* Server: Performance improvement of query-based sync with many readers.

### Compatibility
* No change

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* New error code `missing_protocol_feature` in `sync::Client::Error`.
* Server: All configuration options related to the deprecated "prechecker"
  feature have been removed.
* Server: SyncServer NPM module no longer contains both Debug and Release
  builds. The `enableDebugMode` configuration option has been removed. A
  separate NPM package is provided containing Debug builds for all supported
  platforms.
* Server: The "prechecker" feature has been removed, along with associated
  configuration options (`disablePrecheckInChildProc`, `precheckCommandPath`,
  `skipVerifyRealmsAtStart`, `shouldCompactRealmsAtStart`, and
  `shouldPerformPartialSyncAtStart`). The most important part of it has been
  replaced by the "partial sync completer" feature, which is enabled by default,
  and can be disabled with the config options `disablePartialSyncCompleter`.

### Internal Bugfixes
* Sometimes, and depending on timing, canceled wait operations on sync sessions
  (e.g., `sync::Session::async_wait_for_download_completion()`) would
  incorrectly pass a success indication to the completion handler. This bug was
  introduced in Sync 2.2.1 (Dec 20, 2017), and has now been fixed.

### Internal Enhancements
* Server: Some redundant work has been eliminated in query-based sync for the
  case where the server has few writers and many readers, yielding a performance
  improvement proportional to the number of readers.
* New sync server configuration parameter `max_protocol_version` in
  `sync::Server::Config` (`--max-protocol-version` from command line). For now,
  it is primarily intended for testing / debugging purposes.

-----------

## Sync team internal change notes
* The server no longer re-parses outstanding changes from the reference realm
  when updating partial views during fanout.
* Command line tool `realm-print-changeset` can now accept a changset that is
  not hex encoded.
* The prechecker and related command line tools have been removed from the
  code base.
* Introduce new feature of test framework, `CHECK_NOTHROW()`, and use it in the
  client/server test fixture to reveal what exceptions are thrown from the event
  loop threads spawned by it.

## Dependencies
* Uses core-5.19.1

----------------------------------------------

# 4.4.3/4.4.4 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* Server: A regression was introduced in version 4.3.0 that could cause the server to decide to
  perform full history compaction on every upload, causing severe performance degradation. (Issue
  [#2962](https://github.com/realm/realm-sync/issues/2962), since 4.3.0)

-----------

## Sync team internal change notes
* None.

## Dependencies
* Uses core-5.19.1

----------------------------------------------

# 4.4.2 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* None.

### Enhancements
* None.

### Compatibility
* No change

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* None.

### Internal Bugfixes
* None.

### Internal Enhancements
* Bumped Core dependency to 5.19.1.

-----------

## Sync team internal change notes
* None.

## Dependencies
* Uses core-5.19.1

----------------------------------------------


# 4.4.1 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* A bug was fixed where null values in timestamp columns could be incorrectly
  encoded in the protocol ([Issue
  #2924](https://github.com/realm/realm-sync/issues/2924), since 4.2.0. Also backported to 4.2.2).

### Enhancements
* None.

### Compatibility
* No change

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* None.

### Internal Bugfixes
* None.

### Internal Enhancements
* Bumped Core dependency to 5.19.0.

-----------

## Sync team internal change notes
* None.

----------------------------------------------


# 4.4.0 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* None.

### Enhancements
* Adds support for including user specified backlinks in a query based subscription.
  (Issue [#2812](https://github.com/realm/realm-sync/issues/2812)).

### Compatibility
* No change

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* StatsD metrics `<prefix>.changeset.integrated` (counter),
  `<prefix>.changeset.integrated` (timing),
  `<prefix>.changeset.integrated.merges`, and
  `<prefix>.changeset.integrated.size` have been retired
  (https://github.com/realm/engineering/issues/26#issuecomment-471828499).
* New `nanoseconds` value in enumeration `util::TimestampFormatter::Precision`.

### Internal Bugfixes
* None.

### Internal Enhancements
* New sync server configuration parameters `disable_sync_to_disk` and
  `disable_pfile_sync_to_disk`. These are for testing / debugging purposes.
* New sync client configuration parameter `disable_sync_to_disk`. This is for
  testing / debugging purposes.
* New command line tool `realm-dump`. This one makes it possible to dump the
  contents of tables (something that is not possible with `realm-stat`).
* Added utility header `<realm/util/quote.hpp>`.

-----------

## Sync team internal change notes
* Change in test client command line interface: Option `--num-requests` was
  replaced by `--send-ptime-requests` (changeset propagation time measurement
  requests are now sent as part of the regular transactions). Option
  `--add-rows` was replaced by `--replace_blobs` with the opposite
  meaning. Options `--receive-requests` and `--request-threshold` were renamed
  to `--receive-ptime-requests` and `--ptime-request-threshold` respectively.
* Test client: Blob class renamed from `Test` to `Blob`.
* Test client: Blob class now has string property `label` and integer property
  `kind`. Command line options `--blob-label` and `--blob-kind` can be used to
  control the values. Additionally, blob class now has integer property,
  `level`, taking on randomized values. Command line options `--blob-level` and
  `--max-blob-level` can be used to control the randomization.

----------------------------------------------


# 4.3.1 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* Fix a server error which could affect partial sync users who operate on a schema with a nullable
  array of primitives type. The server error would be: `Partial sync: Column 'X' of table 'class_Y'
  is nullable in reference and is not nullable in partial Realm.`
  ([#2894](https://github.com/realm/realm-sync/pull/2894), since v4.2.0)
* Permisions may not be respected when populating partial realms where the subscription condition
  consists of OR clauses. ([#2896](https://github.com/realm/realm-sync/issues/2896), since v4.2.0)

### Enhancements
* None.

### Compatibility
* No change

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* None.

### Internal Bugfixes
* None.

### Internal Enhancements
* Make a clear warning in the log if Debug mode is used.
* Added new StatsD metric `<prefix>.workunit.pfiles` of type "histogram". The
  emitted value is the number of partial files that are included in a work
  unit. Exactly one value will be emitted for this metric for every work unit
  that contains at least one uploaded changeset.
* Bumped Core dependency to 5.18.0.
* Optimized the permission check query.

-----------

## Sync team internal change notes
* None.

----------------------------------------------


# 4.3.0 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* None.

### Enhancements
* A new async open feature is introduced where the client can download a
  full Realm from the server. The purpose of the new async feature is to
  speed up the initial bootstrap time.
* Client resync is implemented in the sync client and server. Whenever,
  synchronization is impossible due to a client server mismatch such as backup
  recovery, a client resync can repair the situation and bring the client back
  to a state where it can continue synchronzing. The resync is transparent from
  the point of view of the application. The resync recovers local changes.

### Compatibility
* No change

### Breaking changes (non-backwards compatible. Only for Major versions)
* The sync protocol version has been bumped to version 27.
* A STATE_REQUEST message is introduced. The message is sent by the client and
  is a request to the server for a State Realm. The message contains an offset
  that allows resumption of an interrupted earlier download.
* A STATE message is introduced. The message is sent by the server and is used
  to download a block compressed Realm to the client. The message also contains
  byte based progress information that allows the client to track progress.
* A CLIENT_VERSION_REQUEST and a CLIENT_VERSION message have been added to the
  protocol. They are used by client resync.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* Class `sync::Metrics` now supports all the metrics types/methods supported by
  Dogless including "histogram".

### Internal Bugfixes
* None.

### Internal Enhancements
* client resync and async open are documented in doc/client_reset.md,
  doc/client_reset_guidelines.md, and doc/client_reset_local_recovery.md
* See also client.hpp and server.hpp for the state Realm and client resync
  config options.
* Previously undocumented metric `<prefix>.upload.processing` is now
  documented. See [doc/monitoring.md](doc/monitoring.md).
* Metric `<prefix>.upload.processing` has been slightly changed in terms of what
  it reflects. Now, exactly one value will be emitted for this metric for every
  work unit that contains at least one uploaded changeset. The emitted value is
  the time, in milliseconds, from when the first of those changesets was
  received on the server, and until the work unit is processed on the server to
  the point where sessions have had their download processes resumed. In the
  case of partial sync, a single work unit spans the reference file as well as
  all of its associated partial files.
* Added new metrics `<prefix>.workunit.uploaded.changesets` and
  `<prefix>.workunit.uploaded.bytes` of type "histogram". Exactly one value will
  be emitted for these metrics for every work unit that contains at least one
  uploaded changeset. The emitted value for
  `<prefix>.workunit.uploaded.changesets` is the number of changesets in the
  work unit. For `<prefix>.workunit.uploaded.bytes`, it is the sum of the sizes,
  in bytes, of those changesets. In the case of partial sync, a single work unit
  spans the reference file as well as all of its associated partial files.

-----------

## Sync team internal change notes
* The STATE_REQUEST, STATE, CLIENT_VERSION_REQUEST and CLIENT_VERSION messages
  are described in doc/protocol.md.
* A new file noinst/common_dir.hpp is introduced that is used by both client
  and server.  The function remove__realm_file is moved from server_dir.hpp to
  common_dir.hpp.
* An inspector executable is added for client history Realms.
* Compression functions are added. Specifically, a block compression function is added.
  It is used by the STATE message to download pre-compressed Realms in blocks that can be
  decompressed and encrypted on the fly by the client.
* The StateRealm object manages state Realms created and stored by the server.
* The ClientStateDownload object manages the download of the state Realm on the client.
* Realm deletion becomes asynchronous due to the need to wait for state Realms creating
  threads to finish.
* Realm deletion is updated to block new sessions while state Realms are deleted.
* Since introduction of empty UPLOAD messages,
  `ServerFile::m_num_pfiles_with_changesets` in `sync/server.cpp` was not
  updated correctly. This has been fixed.

----------------------------------------------


# 4.2.0 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* Server: A bug was fixed where if a user had `canCreate` but not `canUpdate`
  privileges on a class, the user would be able to create the object, but not
  actually set any meaningful values on that object, despite the rule that
  objects created within the same transaction can always be modified.
  (Issue [#2574](https://github.com/realm/realm-sync/issues/2574), since sync-3.0.0).
* Server: A Realm file deletion (including deletion of partial files as a result of
  history compaction) could cause various kinds of crashes, and even corruption within
  the server.
  (Issue [#2874](https://github.com/realm/realm-sync/issues/2874), since sync-3.0.0).
* Server/SDK: HTTP requests made by the Sync client now always include a `Host:` header,
  as required by HTTP/1.1, although its value will be empty if no value is specified
  by the application.

### Enhancements
* Server: The server no longer rejects subscriptions based on queries with `distinct`
  and/or `limit` clauses. (PR [#2790](https://github.com/realm/realm-sync/pull/2790).
* Server: Realm files used for query based sync have had all non-essential state
  removed, to reduce the file size on disk and improve query based sync performance.
  In some scenarios, this improves the latency of query-based sync by up to 25%,
  depending on the user's schema.

### Compatibility
* Server: History file format version for server realms has been bumped to 7.
  This version contains no changes to the server history's format, but marks the
  transition to reduced-state partial views. The server will automatically
  migrate existing partial views. The migration is not backwards-compatible;
  the server cannot be downgraded without restoring from backup.

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* None.

### Internal Bugfixes
* Fix undefined symbol errors when linking the library on iOS (since v3.15.2).
* Sync client now properly specifies the port number as part of the `Host:`
  header in the HTTP requests sent to the sync server
  (https://github.com/realm/realm-sync/issues/2827).
* Auth client (and by extension, the sync test client) now properly specifies a
  `Host:` header in the HTTP requests sent to the auth server
  (https://github.com/realm/realm-sync/issues/2827).

### Internal Enhancements
* The sync server now reports amount of memory used for decrypted data, the target
  and workload set for the decrypted page reclaimer and the amount of slab used to
  hold write-transaction data. (https://github.com/realm/realm-sync/pull/2849)
* Adds the ability to run a query with an arbitrary user, which can be useful for
  impersonating others on the client. See `sync::query_with_permissions()`.
  (Issue [#2781](https://github.com/realm/realm-sync/issues/2781)).
* Command line tool `realm-stat` now has an option to list all subscription
  queries found in the file (`--show-queries`).
* Make it more clear in server log whether (in place) history compaction is
  enabled or not.
* Server now emits new StatsD timing metric `<prefix>.workunit.time`. It
  measures the time, in milliseconds, taken by the worker thread to execute a
  work unit. Exactly one value will be emitted for every work unit.

-----------

## Sync team internal change notes
* Test client fixed such that `@N` substitutions now again have leading zeroes
  as was intended.

----------------------------------------------


# 4.1.0 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* None.

### Enhancements
* None.

### Compatibility
* No change

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* New error codes `client_too_old_for_server`, `client_too_new_for_server`, and
  `protocol_mismatch` in error enumeration `sync::Client::Error`.
* Metric `protocol.<version>.used` has been deleted from the metrics
  specification (it has never actually been generated). Instead, the server now
  emits new metric `protocol.used,version=<num>` when protocol version
  negotiation succeeds.
* The signature of
  `util::websocket::Config::websocket_handshake_error_handler()` has been
  modified. The presence of HTTP headers has been made optional, and a new
  argument allows for the response body to optionally be passed.
* Return type changed from `std::streamsize` to `std::size_t` for `size()`
  member of class templates `util::BasicResettableExpandableOutputStreambuf` and
  `util::BasicResettableExpandableBufferOutputStream`.

### Internal Bugfixes
* Fix command line tool `realm-stat`, which was rendered half-broken by Sync
  4.0.0 due to changes in the schema of the history compartment of server-side
  files.
* Test client now properly recognizes new error code
  `sync::Client::Error::bad_protocol_from_server`.
* Fix inspector tools, which were left broken in Sync 4.0.0 due to a renamed
  variable.

### Internal Enhancements
* Command line tool `realm-stat` now offers a detailed breakdown of the history
  compartment of client-side files.
* Command line tool `realm-stat` now has an option (`--show-history`) to enable
  the detailed breakdown of the history compartment. By default, it is not
  enabled.
* Server now includes additional details in the HTTP response body when sync
  protocol negotiation fails. In particular, identifier strings
  `REALM_SYNC_PROTOCOL_MISMATCH:CLIENT_TOO_OLD`,
  `REALM_SYNC_PROTOCOL_MISMATCH:CLIENT_TOO_NEW`, or
  `REALM_SYNC_PROTOCOL_MISMATCH` are included when negotiation fails because
  there were no versions that were supported by both client and server. This
  allows the client to generate errors `client_too_old_for_server`,
  `client_too_new_for_server`, and `protocol_mismatch` from
  `sync::Client::Error`.
* Server now emits new metrics `protocol.no_spec`, `protocol.bad_spec`,
  `protocol.mismatch`, `protocol.client_too_old`, and `protocol.client_too_new`
  when protocol version negotiation fails.
* Server now logs error messages on the form `Protocol version negotiation
  failed: ...` when protocol version negotiation fails.
* The contents of the HTTP response header, `Server:`, has been changed. It is
  now `RealmSync/<sync library version>`. Before, it was
  `realm-sync-server/<protocol version>`.
* Both client and server now logs the ranges of supported protocol versions
  during start up. The messages are on this form, `Supported protocol versions:
  ...`. The server logs this at `info` level. The client logs it as `debug`
  level.
* Server now saves information in file `<server-root>/var/lock.log` to help
  diagnose why we seem to occasionally launch two servers in the same working
  directory. Each successful locking of the working directory will add an entry
  of the form `2019-02-24T15:44:41.752Z|SUCCESS|<host name>|<unique pod
  identifier>`. Likewise for each failed attempt, but with `FAILURE` substituted
  for `SUCCESS`. The `|<unique pod identifier>` part will only be present if
  environment variable `REALM_SYNC_SERVER_LOCK_ID` is specified. Additionally,
  when locking fails, the server will wait for 5 seconds before loading the
  contents of `<server-root>/var/lock.log` to ensure that the other party has
  had time to add its entry. It will then include at most the last 25 lines in
  the message of the thrown exception.
* New configuration parameter `disableWorkdirLock` has been added to the
  server's Node.js API. The purpose is to allow for this locking mechanism to be
  disabled if it is deemed to not work as intended. CAUTION: Please do not
  disable it while work is in progress to figure out why we seem to occasionally
  launch multiple servers in the same working directory.

-----------

## Sync team internal change notes
- Error code `sync::ProtocolError::wrong_protocol_version` has been marked as
  obsolete.

----------------------------------------------


# 4.0.0 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* Fixed a bug where a cached subscription could be sent to a client who did not
  subscribe to it. This could happen when updating more than two clients of a
  reference realm with the same user where the first two subscribe to the same
  query, but the third does not
  (https://github.com/realm/realm-sync/issues/2816).
* The downloadable_bytes value supplied to the progress callback has been
  incorrect for some time.  This release fixes this problem. Both client and
  server must be updated to get the fix.
* Server now rejects clients using too old protocol versions. The limit is
  currently set to version 22, which corresponds to Sync 2.0.0, which was
  release on Oct 12th 2017 (https://github.com/realm/realm-sync/issues/2561).
* Fixed a bug where upgrade of a server realm file created by a ROS version prior
  to v3.3.0 could lead to a corrupt realm file. Only realms with more than 1000
  clients can be affected by this. (https://github.com/realm/raas/issues/1429)

### Enhancements
* Query based sync performance is improved in some cases. For example, when
  clients add or remove subscriptions without modifying any data
  (Issue [#2787](https://github.com/realm/realm-sync/pull/2787)).
* Will issue a warning if a partial subscription is trying to add a number of objects
  exceeding a given threshold. The threshold is controlled by the configuration
  parameter `psync_create_threshold` (or `psyncCreateThreshold` via Node.js). Default value
  is 10000 (PR https://github.com/realm/realm-sync/pull/2760)
* The default values for `connect_timeout`, `ping_keepalive_period`, and
  `pong_keepalive_timeout` of `sync::Client::Config` have been lowered to 2
  minutes, 1 minute, and 2 minutes respectively. These are the values that were
  originally intended for these parameters. They were temporarily raised to
  account for the fact that the server was single-threaded and therefore could
  become unresponsive to heartbeats and other network related stuff for long
  periods of time. The server is no longer single threaded
  (https://github.com/realm/realm-sync/issues/2814).
* A more flexible sync protocol negotiation mechanism has been introduced (still
  based on HTTP headers `Sec-WebSocket-Protocol`). Now, both the server and the
  client can opt to support older protocol versions. Previously, only the server
  could do that. The current version of the client only supports the latest sync
  protocol (version 26), so this new feature is not yet utilized. However, if
  the next client, that incorporates a protocol change, chooses to also support
  the prior protocol version, then rolling that client out will become much
  easier, because there is then no longer a requirement that a matching new
  server must be rolled out first
  (https://github.com/realm/realm-sync/issues/2561).

### Compatibility
* No change

### Breaking changes (non-backwards compatible. Only for Major versions)
* The sync protocol version has been bumped to version 26. The server retains
  the ability to service clients using earlier protocol versions. Clients, on
  the other hand, will not be able to communicate with earlier versions of the
  server, so the server needs to be upgraded before clients are.
* Four new protocol error codes introduced, 217, 218, 219, and 220. Codes 217
  "Synchronization no longer possible for client-side file", and 220 "User has
  been blacklisted (BIND)" were introduced in anticipation of future use cases.
* When a server-side file is deleted while a client session is bound to it, the
  server now closes the session with error code 218 "Server file was deleted
  while session was bound to it". Previously, the session would have been closed
  with error code 200 "Session closed (no error)".
* When a client attempts to initiate synchronization for a blacklisted
  client-side file, the server now responds with error code 219 "Client file has
  been blacklisted (IDENT)". Previously, the session would have been closed with
  error code 201 "Other session level error".
* The server-side history schema has been changed. The history schema version
  has been bumped to 6, and transparent migration is provided.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* None.

### Internal Bugfixes
* Fix race discovered during review of multi-threaded outward partial sync. Should not have
  affected end users, as the feature has not officially shipped yet, and ROS does not support
  enabling the feature yet. (https://github.com/realm/realm-sync/pull/2820)
* Fix a bug that could result in violation of the "no merge" invariant for
  partial sync. This bug has existed since the introduction of partial sync,
  which was in Sync 2.0.0 (https://github.com/realm/realm-sync/issues/2822).

### Internal Enhancements
* The query cache is now used across multiple work units.
* Bumped Core dependency to 5.15.0.

-----------

## Sync team internal change notes
* The interpretation of downloadable bytes is different between protocol
  versions. Now, downloadable bytes in the DOWNLOAD message means the size of
  the remaining history. The server uses the proper form of downloadable_bytes
  depending on the protocol version of the client.
* The download bytes progress handler has an unchanged API. The API can be kept
  unchanged under the protocol change by having the client calculate
  the original downloadable_bytes from the new one.

----------------------------------------------


# 3.15.2 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* Server: Detailed memory allocation metrics are now counted separately for each
  tenant in multi-tenancy deployments. (Since 3.13.0)

### Compatibility
* No change

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Internal Bugfixes
* The server's check of the client specified protocol version
  (`Sec-WebSocket-Protocol`) was unintentionally lenient. This has now been
  fixed (https://github.com/realm/realm-sync/issues/2803).

### Internal Enhancements
* Introduce new metric `<prefix>.user_sessions,identity=<str>` measuring the
  number of currently established sessions on behalf of a particular user, where
  `<str>` is the user identity specified during establishment of the session
  with all nonalphanumeric characters having been percent encoded.
* Detailed memory metrics have been added for the server's work queue, emitted
  as `<prefix>.memory,subsystem=worker_queue`. Issue [#2778](https://github.com/realm/realm-sync/issues/2778).

----------------------------------------------


# 3.15.1 Release notes

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Internal Bugfixes
* Server: The server now shrinks internal scratch memory buffers after
  performing partial sync. This should reduce sustained high memory usage in
  multi-tenancy scenarios, but will incur a very slight performance penalty for
  certain memory allocations.

----------------------------------------------


# 3.15.0 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* None.

### Enhancements
* Added the ability to use extra worker threads to speed up outward partial
  sync.  This enhancement targets the use case where a few clients do smaller
  updates, which are then distributed to a large number of listening
  clients. The number of additional threads are controlled by the configuration
  parameter `num_aux_psync_threads` (or `numAuxPsyncThreads` via Node.js). (PR
  https://github.com/realm/realm-sync/pull/2703)

### Compatibility
* No change

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* Server configuration parameter `sync::Configuration::log_file_path` no longer
  exists. The path is now hard-coded to `<root>/var/server.log`. Note, this
  change is not breaking in practice, because no downstream product is currently
  referring directly to `sync::Configuration::log_file_path`.

### Internal Bugfixes
* None.

### Internal Enhancements
* Clear out the old contents of the download cache before generating new
  contents. This can make a big difference because the size of that body can be
  very large (10GiB has been seen in a real-world case).
* New boolean server configuration parameter
  `sync::Configuration::log_to_file`. When the server is launched via Node.js
  and when `log_to_file` is set to true, log messages will be also written to
  `<root>/var/server.log` in the local filesystem of the server.
* On the server, the beginning and end of the processing of a work unit by the
  worker thread is now clearly parentherized in the log by `debug`-level
  messages `Work unit execution started` and `Work unit execution completed`.
* Bumped Core dependency to 5.14.0.

-----------

## Sync team internal change notes
* None.

----------------------------------------------


# 3.14.14 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* None.

### Enhancements
* When log compaction expires a client due to that client being offline longer
  than the server's `historyTtl` setting, the server now also discards metadata
  (reciprocal history) for that client, further reducing the size of the file.
* Log compaction effectiveness has been improved slightly by ensuring that
  changesets that no longer contain any substantial instructions also do not
  leave any strings behind. (Issue [#2725](https://github.com/realm/realm-sync/issues/2725))

### Compatibility
* No change

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* None.

### Internal Bugfixes
* None.

### Internal Enhancements
* Bumped Core dependency to 5.13.0.

-----------

## Sync team internal change notes
* None.

----------------------------------------------


# 3.14.13 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* None.

### Enhancements
* None.

### Compatibility
* No change

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* None.

### Internal Bugfixes
* None.

### Internal Enhancements
* Continuation of: Make `_impl::ServerHistory::verify()` ignore corruptions
  relating to `history_byte_size`. This is a temporary work-around for a known
  common source of corruption in server-side
  files. See[https://github.com/realm/realm-sync/issues/2695](https://github.com/realm/realm-sync/issues/2695).

-----------

## Sync team internal change notes
* None.

----------------------------------------------


# 3.14.12 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* Server: In obscure scenarios, a client reconnecting to a deleted and recreated server
  realm could corrupt the realm. (Issue [#2654](https://github.com/realm/realm-sync/issues/2654), since 3.4.0)
* Server: Added a check to prevent possible out-of-bounds write on an array that could cause corruption of a
  realm file. (May be a fix for https://github.com/realm/realm-sync/issues/2694 an other issues, since 3.4.0)

### Compatibility
* No change

----------------------------------------------


# 3.14.11 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* Fix a race condition when stopping the sync node server multiple times
  asynchronously which could produce a segfault or a system error.
  Issue [#2692](https://github.com/realm/realm-sync/issues/2692).
* Fixes uncaught exception `realm::util::File::PermissionDenied: remove_dir()
  failed: Directory not empty`. Issue
  [#2699](https://github.com/realm/realm-sync/issues/2699), since 3.14.3..

### Enhancements
* None.

### Compatibility
* No change

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* None.

### Internal Bugfixes
* Fix UWP build on modern MSVC by removing usage of extended alignment support
  through `std::aligned_storage` in `instructions.hpp`.

### Internal Enhancements
* Bumped Core dependency to 5.12.7.
* Sync server's working directory is now protected with a file lock. This
  prevents accidental overlapping launch of multiple servers for the same
  working directory, which could otherwise cause corruption.
* New command line tool `realm-server-precheck`. This command runs the same
  prechecking process as can be enabled as part of server bootstrapping.

-----------

## Sync team internal change notes
* We are deprecating the Windows and Linux binary locations
  (`/downloads/sync/sha-version/SOME-SHA/`) as this security measure is no
  longer needed. Artifacts will be uploaded to `/downloads/sync/` similar to
  other platforms. For the time being, artifacts will be available at both
  locations, but, eventually, we'll stop publishing to the `sha-version` one.

----------------------------------------------


# 3.14.10 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* In general, the server reports the total byte size of changesets waiting to
  be integrated. In the case where a client uploaded bad changesets, all
  changesets from the client in the work queue are discarded.  These discarded
  changesets were not properly accounted for in the byte size calculation. This
  release fixes that bug.

### Enhancements
* None.

### Compatibility
* No change

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* None.

### Internal Bugfixes
*  This release replaces the work around in release 3.14.6 for the assertion
  "Assertion failed: m_unblocked_changesets_from_downstream_byte_size == 0"
  with a proper solution.

### Internal Enhancements
* Show associated file system path when catching `util::File::AccessError` in
  server's Node.js binding.
* Make `_impl::ServerHistory::verify()` ignore corruptions relating to
  `history_byte_size`. This is a temporary work-around for a known common source
  of corruption in server-side
  files. See[https://github.com/realm/realm-sync/issues/2695](https://github.com/realm/realm-sync/issues/2695).

-----------

## Sync team internal change notes
* None.

----------------------------------------------


# 3.14.9 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* A critical bug in the server could lead to wrong conflict resolutions, assertion
  failures, corrupted intermediate files and potentially lead to a unresponsive server.
  This bug would particularly manifest itself if two clients are trying to upload
  incompatible schema changes, but could also occur in other scenarios.
  (Issue [#2650](https://github.com/realm/realm-sync/issues/2650), since 1.0.0)

### Enhancements
* None.

### Compatibility
* No change

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* None.

### Internal Bugfixes
* None.

### Internal Enhancements
* Improved performance of `Changeset::erase_stable`.

-----------

## Sync team internal change notes
* None.

----------------------------------------------


# 3.14.8 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* Deletion of reference Realm file by way of HTTP request no longer leaves any
  associated partial file behind. Previously, some partial files were left behind,
  which could easily lead to server crashes with uncaught exception of type
  `_impl::CorruptedPartialFileAssoc`.
  (Issue [#2669](https://github.com/realm/realm-sync/issues/2669)).
* A crash bug was fixed that could be triggered by creating tables and
  establishing link columns between them without having sufficient permissions
  to do so. It manifested itself as an uncaught exception of type
  `CrossTableLinkTarget`.
  (Issue [#2662](https://github.com/realm/realm-sync/issues/2662), since 3.0.0)
* A crash bug could be triggered in some situations by creating, deleting,
  then recreating tables with primary keys. This could be seen observed as a
  crash with the message `realm::LogicError: Row index out of range`.
  (Issue [#2651](https://github.com/realm/realm-sync/issues/2651), since 2.0.0).

### Compatibility
* No change

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Internal Bugfixes
* Various problems relating to unanticipated fallout from introduction of empty
  UPLOAD messages. For example, a received empty UPLOAD message was causing too
  many invocations of outward partial sync for other concurrently connected
  clients.

### Internal Enhancements
* Further enhance command line tool `realm-stat`. It now reveals additional
  information from the server-side history compartment: Current sync version,
  whether file has upstream status, and whether file is initiated as partial
  view.

----------------------------------------------


# 3.14.7 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* Erasing elements in an array of primitives in a Realm being accessed through
  query-based sync could crash the server with a segmentation fault.
  (Issue [#2644](https://github.com/realm/realm-sync/issues/2644), since 3.14.0)

### Compatibility
* No change

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Internal Bugfixes
* The utility function `sync::add_array_column()` always returned 0 instead of
  the index of the array column that was added.
* Fix mixed up use of loggers in
  `ServerImpl::complete_any_pending_partial_sync()`.

----------------------------------------------


# 3.14.6 Release notes

Same as 3.14.4 (which was never released) except for an addition to the changelog.

### Bugfixes
* When used in realm-js core no longer throws "Operation not permitted" exception
  on AWS Lambda. ([Core #3193](https://github.com/realm/realm-core/issues/3193))
  This fix comes from Core 5.12.6 and should have been included in 3.14.4 in the
  changelog.

# 3.14.4 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* Fix of a bug that made the server crash with message:
  "Assertion failed: m_unblocked_changesets_from_downstream_byte_size == 0".
  ([#2658](https://github.com/realm/realm-sync/pull/2658))

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Internal Bugfixes
* A work around for the assertion
  "Assertion failed: m_unblocked_changesets_from_downstream_byte_size == 0".
  It is unknown why the assertion was hit in the first place.

### Internal Enhancements
* Bumped Core dependency to 5.12.6.

----------------------------------------------

# 3.14.3 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* Fixed several log messages printing not providing contextual variable information. For example,
 the message "Permissions: The user with ID '%1' is not a member of any roles that have Class-level
 permissions. This is usually an error." will now print the the user id instead of "%1".
* Fix of a bug that made the server crash with message:
  "Assertion failed: m_unblocked_changesets_from_downstream_byte_size == 0".
* When loading the realm binary from within the realm-js SDK, core could hang on Windows
  ([JS #2169](https://github.com/realm/realm-js/issues/2169)).

### Enhancements
* None.

### Compatibility
* No change

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* None.

### Internal Bugfixes
* Probably fixed https://github.com/realm/realm-sync/issues/2641 which made the
  server crash with
  "Assertion failed: m_unblocked_changesets_from_downstream_byte_size == 0".
  The bug was that in case of Realm deletion, the member variable was not
  correctly reset.

### Internal Enhancements
* Make `realm-stat --show-columns` also show which columns have search indexes.
* Bumped Core dependency to 5.12.5.

-----------

## Sync team internal change notes
* None.

----------------------------------------------


# 3.14.2 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* A crash bug was fixed related to state size calculation. This should remedy
  some restarts observed by users as segfaults. (FreshDesk #2473, since sync-3.13.3 / ros-3.13.1)

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* Server configuration parameters `idle_timeout` and `drop_period` in
  `sync::Server::Config` renamed to `connection_reaper_timeout` and
  `connection_reaper_interval` respectively. Corresponding command line options
  `--idle-timeout` and `--drop-period` renamed to `--connection-reaper-timeout`
  and `--connection-reaper-interval` respectively. These configuration
  parameters are now exposed in the server's Node.js API as
  `connectionReaperTimeout` and `connectionReaperInterval` respectively.

### Internal Enhancements
* Bumped Core dependency to version 5.12.4. This version fixes a crash related
  to Realm file size calculation. ([ROS #1374](https://github.com/realm/realm-object-server-private/issues/1374))
* Server configuration parameters `http_request_timeout`,
  `http_response_timeout`, and `soft_close_timeout` in `sync::Server::Config`
  are now available as command line options `--http-request-timeout`,
  `--http-response-timeout`, and `--soft-close-timeout` respectively. They are
  now also exposed in the server's Node.js API as `httpRequestTimeout`,
  `httpResponseTimeout`, and `softCloseTimeout` respectively.


----------------------------------------------


# 3.14.1 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* Added a mechanism to avoid violation of the no-merge invariant for partial
  sync (Issue #2481). The sync server will now look for any incomplete partial
  synchronization, and complete it during startup (look for `Partial sync
  completer:` in the log). This feature is enabled by default, but can be
  disabled through the new server configuration parameter
  `disable_psync_completer` in `sync::Server::Config`, or using
  `--disable-psync-completer` from the command line. The name of this parameter
  is `disablePartialSyncCompleter` in the Node.js API.

### Enhancements
* None.

### Compatibility
* No change

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* None.

### Internal Bugfixes
* Permissions corrections would sometimes not be applied to partial views,
  which could lead to crashes and failure to recover from a crash.

### Internal Enhancements
* Added utility header `<realm/util/substitute.hpp>`.
* Bump Core dependency to 5.12.3. This version includes improved detection of
  file corruption.

-----------

## Sync team internal change notes
* Added facilities to deploy sync test client into Kubernetes cluster
  (`arena.k8s.realmlab.net`) for performance measurements
  (`/test/client/cloud_perf_test/`).
* Added substitution parameter `@U` to test client. It expands to the user
  identity as received from the authentication authentication server. It is
  available only in server URL (virtual path), and only when the auxiliary
  authentication protocol is activated (`--username`).
* Added command line option `--ensure-ptime-class` to test client. This allows
  for subscription queries to be established before receiving the
  `PropagationTime` class from the server.

----------------------------------------------


# 3.14.0 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* The `LIMIT` predicate on partial sync queries will now be evaluated after the
  permission check instead of before. In the past, users uploading queries with
  `LIMIT` predicates would sometimes not get all the objects that matched the
  query, because the query results were limited before permission checks, so if
  some of the results after limit did not pass permission checks, they would be
  filtered out, and others that would pass permission checks would not be
  included.
* An index out of range error in query based sync is fixed. The bug would
  manifest itself with a "list ndx out of range" error.
* If encryption was enabled, decrypted pages were not released until the file was closed, causing
  excessive usage of memory.
  A page reclaim daemon thread has been added, which will work to release decrypted pages back to
  the operating system. To control it, a governing function can be installed. The governing function
  sets the target for the page reclaimer. If no governing function is installed, the system will attempt
  to keep the memory usage below any of the following:

        - 1/4 of physical memory available on the platform as reported by "/proc/meminfo"
        - 1/4 of allowed memory available as indicated by "/sys/fs/cgroup/memory/memory_limit_in_bytes"
        - 1/2 of what is used by the buffer cache as indicated by "/sys/fs/cgroup/memory/memory.stat"
        - A target directly specified as "target <number of bytes>" in a configuration file specified
          by the environment variable REALM_PAGE_GOVERNOR_CFG.
  if none of the above is available, or if a target of -1 is given, the feature is disabled.
  ([#3123](https://github.com/realm/realm-core/issues/3123))
* Fix incorrect assertion when generating ERROR message for clients connecting
  with sync protocol version 22 or less.

### Enhancements
* Queries with `LIMIT` are now fully supported with query-based sync.

### Compatibility
* No change

### Breaking changes (non-backwards compatible. Only for Major versions)
* None.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* None.

### Internal Bugfixes
* Eliminate a data race in access to `RealmLogger::m_last_time` as defined in
  `src/node/sync-server/src/js_realm_logger.hpp`.
* During outward partial sync, link lists instructions with prior size
  different from the actual size of the link list are handled by postponing the
  link list, i.e. handling it by state diffing at the end of outward
  partial sync. Issue: https://github.com/realm/realm-sync/issues/2600

### Internal Enhancements
* Added utility headers `<realm/util/timestamp_formatter.hpp>` and
  `<realm/util/timestamp_logger.hpp>`.
* As a temporary fix, when the server deletes a Realm file, it now sends
  obsolete error code 207 "Bad server file identifier (IDENT)" to clients that
  currently have a session bound to that file. This ensures that the "client
  reset" process is properly triggered on those clients.
* A new column, `matches_count`, is added by the server to the
  `class___ResultSets` table. It will be populated by the server after running
  partial sync queries, and will contain the total number of objects matched by
  the query before applying `LIMIT`, but after permission checks. It is the
  maximum number of objects that the client can see if the query was evaluating
  without `LIMIT`, and is intended to enable simple pagination.

-----------

## Sync team internal change notes
* Bumped Core dependency to 5.12.2.
* Added utility header `<realm/util/string_view.hpp>`. The provided facility is
  in complete agreement with a subset of std::basic_string_view as offered by
  C++17. This header is obsolete when we switch to C++17.
* Test client now logs timestamps with milliseconds precision.
* The test harness now supports logging with timestamps. To enable it, set the
  environment variable `UNITTEST_LOG_TIMESTAMPS` to a nonempty value. This
  change represents a deviation from the copy of the test harness present in the
  Git repository of the core library. This divergence will have to be resolved
  later.
* New command line option `--disable-sync-to-disk` added to sync server command
(`realm-sync-worker`).
* Fix "dry run" mode of sync test client (`test/client/test-client --dry-run`).

----------------------------------------------


# 3.13.7 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Enhancements
* The log compaction algorithm has been improved, and should produce better
  results. It should also consume less memory while running.

### Compatibility
* No change

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* Enum type `sync::Protocol` renamed to `sync::ProtocolEnvelope` to avoid
  conflation with other uses of the name "protocol".
* Enum value `realm_ssl` of `sync::ProtocolEnvelope` renamed to `realms` to
  align with the URL scheme specifier (which is `realms:`).

### Internal Bugfixes
* None.

### Internal Enhancements
* Changed the interface for the node sync server logger to
  logCallback?: (level: number, message: string, time: number) => void;.
  The time is the number of microseconds since the epoch.
  The time is made strictly increasing by bumping it by one microsecond if
  necessary.
* New enum value `ws` and `wss` added to `sync::ProtocolEnvelope`. Currently,
  these are equivalent to `realm` and `realms` respectively, except that they
  have slightly different rules for what the default port number is. The default
  port number for `ws` (URL scheme `ws:`) is always 80, and for `wss` (URL
  scheme `wss:`), it is always 443.
* Improved `realm-stat` tool: Show breakdown of server-side history compartment.

-----------

## Sync team internal change notes
* Added SSL support to the auth client and, in turn, to the test client.

----------------------------------------------


# 3.13.6 Release notes

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Internal Enhancements
* Make server able to cache the contents of the DOWNLOAD message(s) used for
  client bootstrapping. This feature is enabled by the new server configuration
  parameter `enable_download_bootstrap_cache` in `sync::Server::Config` (off by
  default), or using `--enable-download-bootstrap-cache` from the command
  line. The name of this parameter is `enableDownloadBootstrapCache` in the
  Node.js API.

-----------

## Sync team internal change notes
* Shorthand option for sync server option `--state-size-report-compute-directly`
  changed from `-B` to `-G`.

----------------------------------------------


# 3.13.5 Release notes

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Internal Enhancements
* Introducing a short-term work-around that hopefully avoids, or at least lowers
  the risk of the server running out of memory due to an ever growing amount of
  buffered incoming changesets, in cases where the worker thread cannot keep up
  with the inflow. This is done by throwing off clients that attempt to upload
  at a time where the accumulated size of incoming buffered changesets exceeds a
  configurable limit (`Server::Config::max_upload_backlog`).

----------------------------------------------


# 3.13.4 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* Fixed linking problem with Node.js 10 on Linux, where internal calls in our
  statically linked OpenSSL would collide with (newer) OpenSSL symbols from
  Node.js 10. Node.js 10 upgraded their dependency on OpenSSL to 1.1.x, but we
  are still using OpenSSL 1.0.2k, and they are not ABI-compatible. The problem
  was fixed by statically linking with an OpenSSL that was built with
  `-fvisibility=hidden`.

----------------------------------------------


# 3.13.3 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* When using query-based sync, log compaction was skipped in the reference file.
  Enabling log compaction in the reference file when being used through
  query-based sync revealed another oversight, namely that partial views did not
  correctly experience the equivalent of client reset. This situation could be
  experienced by users if they accessed a reference file both through
  query-based sync and regular sync (i.e., through Realm Studio), and the server
  decided to perform log compaction on the reference file as a result of writes
  made through regular sync. Issues:
  [#2546](https://github.com/realm/realm-sync/issues/2546),
  [#2554](https://github.com/realm/realm-sync/issues/2554).
  PR: [#2555](https://github.com/realm/realm-sync/pull/2555)
* For the purposes of log compaction, activity in partial views now count
  towards activity in the reference file. This means that the server will not
  compact history in the reference file being used by a partial view with at
  least one active client within the history TTL.
* A set of bugs that could lead to bad changesets were fixed.
  The errors fixed here impacted both clients and servers.
  An example of an assertion, caused by these bugs, is:
  `[realm-core-5.10.0] Assertion failed: ndx < size() with (ndx, size()) =  [742, 742]`.
  An example of an error in a log file, caused by these bugs, is:
  `ERROR: Client[1]: Connection[1]: Session[14]: Failed to parse, or apply received changeset: ndx out of range`.


### Enhancements
* Bumped Core dependency to 5.12.1.
* Improve merge performance when building with assertions enabled in Release
  builds. This is currently done only on Apple platforms.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Internal Bugfixes
* Updated unit tests to never insert a column in front of the object id column.

### Internal Enhancements
* New TableInfoCache constructors.
* TableInfoCache::clear_last_object method.
* Assert that the object id column has index 0 in more places.

-----------

## Sync team internal change notes
* Included the fuzz test in the file test_sync_fuzz.cpp.
* Expanded TableInfoCache::verify() and use it more in debug mode.
* Time based seed in the fuzz test.
* Employed TableInfoCache::clear_last_object in places where it is needed.
  TableInfoCache is generally passed by ref instead of having multiple
  instances of it. This fixes a class of Bad Changeset errors as reported in
  https://github.com/realm/realm-sync/issues/2388 for instance.

----------------------------------------------


# 3.13.2 Release notes

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Internal Enhancements
* New server configuration parameter `state_size_report_compute_directly` in
  `sync::Server::Config`. This can be used to reenable the direct form of state
  size computation, as it was done prior to being changed to be computed
  indirectly through the history size
  (https://github.com/realm/realm-sync/pull/2533). The name of this parameter is
  `stateSizeReportComputeDirectly` in the Node.js API.
* When Realm state size reporting is enabled, the server will now also report
  file sizes along with the state sizes. The file size of each file is reported
  as a metrics gauge value with key `<prefix>.realm_file_size,path=<percent
  encoded virtual path>` and the number of bytes as value. `<percent encoded
  virtual path>` is the URI percent encoding of the virtual path with only
  alphanumeric characters remaining unencoded. In general, `<prefix>` is
  `realm.<host name>`. In this case, the *file size* of a Realm file is the
  actual size of the file, not the logical size (a concept defined by the Realm
  file format).
* New command line option `-c`/`--show-columns` for `realm-stat`. This makes the
  tool show column-level schema information for each table.
* When the prechecking child process crashes due to an uncaught exception, log
  the type and messages of that exception.

-----------

## Sync team internal change notes
* New command line option `--state-size-report-compute-directly` added to Realm
server command (`realm-sync-worker`).

----------------------------------------------


# 3.13.1 Release notes

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Internal Bugfixes
* The headers in `util/metered/` were not installed to the correct directory,
  rendering the binary packages unusable.

----------------------------------------------


# 3.13.0 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* The cache between row index and object is cleared after table::swap_rows and
  table::move_row.  Part of the fuzz testing issue:
  https://github.com/realm/realm-sync/issues/2388. This bug is irrelevant for
  users and bindings that do not use swap_rows and move_row.
* The cache between row index and object is invalidated in more cases. The
  underlying bug only manifests itself in very very rare cases and is not
  believed to have been encountered by users.
  PR: https://github.com/realm/realm-sync/pull/2531

### Enhancements
* Bumped Core dependency to 5.12.0.
* Adds support for Node.js 10.x. The driver for this is that Realm JavaScript
  needs support for Node.js 10 since it will become the LTS version by the end
  of October 2018.
* The performance of merging large number of highly interconnected instructions
  has been improved, sometimes by a factor 10. In use cases where many objects
  link to the same handful of objects, integrating changesets on the server
  should be noticeably faster.
* Performance of calculating the state size optimized somewhat.

### Breaking changes (non-backwards compatible. Only for Major versions)
* Node.js 9.x is no longer supported.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Internal Bugfixes
* The cache between row index and object id is cleared for erase_object in the
  case of a short circuited replicator. The absence of clearing the cache would
  lead to the new assertions in row_for_object_id() and object_id_for_row()
  being hit. This bug would only have an effect in very very rare cases where
  object id hash collisions occur.

### Internal Enhancements
* Heap allocation instrumentation for each subsystem (`realm.memory`, with
  labels such as `subsystem=partial_sync`, etc.). These metrics are emitted once
  per second by each `Server` instance. They are implemented in terms of custom
  allocators, using the `realm::util::AllocatorBase` interface.
  (https://github.com/realm/realm-sync/pull/2309).
* Detailed debug logging has been added for changeset indexing / merging
  progress. The number of changesets, instructions, and conflict groups is
  logged as the algorithm progresses. This is to aid performance diagnostics.
* Debug assertions are added to the object id cache. The assertions check
  that the cache returns the correct result. The assertion is not turned on in
  release mode since it would counter the whole purpose of the cache.

----------------------------------------------


# 3.12.10 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* A bug in log compaction of link lists was fixed. This bug would lead to
  errors of the type "index out of range" or "ndx < size()". Issue:
  https://github.com/realm/realm-sync/issues/2388

### Enhancements
* Allow for the triggering of Realm state size reporting in the server to be
  specified as a time of day (number of milliseconds after midnight UTC)
  (https://github.com/realm/realm-sync/issues/2484).
* When the server is launched via the Node.js API, the default action during
  Realm state size recomputation and reporting is to skip files that are not
  already open in the LRU file access cache of the worker thread
  (https://github.com/realm/realm-sync/issues/2484).
* The synchronization client now sends a user agent description to the server
  via the HTTP `User-Agent` header
  (https://github.com/realm/realm-sync/issues/2455).
* The synchronization server now logs client information for every initiated
  session, including the user agent description
  (https://github.com/realm/realm-sync/issues/2455).
* The synchronization client API now allows for an application to add a
  description of itself to the user agent description that is sent to the server
  via the HTTP `User-Agent` header
  (https://github.com/realm/realm-sync/issues/2455).
* Synchronization protocol no longer allows for user identity to be changed
  during a session.
* Log messages about Realm files being opened and closed by the LRU cache on the
  client side have been demoted from `detail` to `debug` level.
* Log messages for "Scheduling Compaction ..." demoted from `info` to `detail`.
* Log messages for details about slow computations demoted from `warn` to `debug`.
* Added support to the server for blacklisting of client files. Client file
  blacklists are loaded from `<root>/client_file_blacklists` when the server is
  started. See [Client file blacklisting](doc/blacklisting.md) for further
  details (https://github.com/realm/realm-sync/issues/2516).

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
* Server configuration parameter `enable_realm_state_size_reporting` in
  `sync::Server::Config` renamed to `enable_state_size_reporting`.

### Internal Enhancements
* Bumped Core dependency to 5.11.3
* New server configuration parameters `state_size_report_tofd` and
  `state_size_report_period` in `sync::Server::Config`. The default value of
  `state_size_report_period` is zero, which means that the triggering of state
  size reporting is "time of day"-based, i.e., based on `state_size_report_tofd`
  and specified as number of milliseconds after midnight UTC. The default value
  of `state_size_report_tofd` is 32400000 which means that state size reporting
  is triggered at 9am UTC (2am PDT, 11am CEST). In the Node.js API, these
  parameters are `stateSizeReportTimeOfDay` and `stateSizeReportPeriod`
  respectively.
* New server configuration parameter `state_size_report_skip_closed_files` in
  `sync::Server::Config`. If set to true, files that are not already open in the
  LRU file access cache will be skipped during Realm state size recomputation
  and reporting. In the Node.js API, the corresponding, but logically inverted
  parameter is `stateSizeReportDoNotSkipClosedFiles`.
* New client configuration parameters `user_agent_platform_info` and
  `user_agent_application_info` in `sync::Client::Config`.
* Added utility header `<realm/util/platform_info.hpp>`.
* New server configuration parameter `client_file_blacklists` in
  `sync::Server::Config`. This is a collection of the client files that must be
  rejected by the server.
* New StatsD metric `<prefix>.blacklisted` (counter) bumped every time a sync
  session is rejected due to the client file having been blacklisted.

----------------------------------------------


# 3.12.9 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* Avoid crashing the server when compaction is requested for a file whose
  history type is not yet set to `server`
  (https://github.com/realm/realm-sync/pull/2492).

### Enhancements
* The vacuum command is enhanced to take options history-type and bump-realm-version.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Internal Enhancements
* Avoid conflation of release and debug-mode builds of command line tools as
  they are included in the server NPM package. Now, command line tools that are
  built in debug mode have a `-dbg` suffix. Before they did not, which meant
  that one would clobber the other as they were placed in the server NPM
  package.
* New StatsD metric `<prefix>.realms.all` (gauge) reports the total number of
  server-side Realm files in the servers working directory. It is emitted when
  the server starts, and thereafter, whenever it changes.
* Improve the logging for the exception for 'bump realm version' for plain and
  client Realms.
* Command-line tool `realm-stat` improved in several ways.
* The Vacuum options get a new property "history_type" that can be used to force
  a specific Realm history type instead of auto detection. The sync server uses
  this option.
* Auto detection of history type is disallowed in compact for Realms with
  history type None and version = 1.

----------------------------------------------


# 3.12.8 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* Metric `<prefix>.authentication.failed` was sometimes incremented twice where
  it should only have been incremented once
  (https://github.com/realm/realm-sync/issues/2455).

### Enhancements
* Various log messages, that are emitted by the server when the access token has
  expired, are now emitted at `detail` level, rather than at `error`
  level. Since it is impossible to avoid all such cases, they should not be
  considered as errors (https://github.com/realm/realm-sync/issues/2455).
* Extended typescript definition for `IRealmSyncServerConfiguration` to accept the
  `skipVerifyRealmsAtStart` option, which defaults to `false` when omitted.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Internal Enhancements
* Include command-line tools `realm-stat` and `realm-verify-server-file` in sync
  server NPM package.
* New command line option `--report-state-sizes` added to Realm server command
(`realm-sync-worker`).

-----------

## Sync team internal change notes
* Command-line tools `realm-stat` and `realm-verify-server-file` moved into
  `/src/realm/` from `/src/realm/inspector/`.
* Log messages at `trace` level when a work unit is unblocked, starts to
  execute, completes execution on worker thread, and when it completes execution
  altogether.
* More logging when state size recomputation is initiated.
* Improved logging during server-file prechecking process.

----------------------------------------------


# 3.12.7 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* Core downgraded to 5.10.3

----------------------------------------------


# 3.12.6 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Enhancements
* The sync server command gets an option to include time stamps in log messages.
* The node.js server gets an option called logIncludeTimestamp to include time
  stamps in messages.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Internal Enhancements
* New command line options `--precheck-in-child-proc` and
  `--precheck-command-path` added to Realm server command (`realm-sync-worker`).
* Significant speed-up of prechecking many partial files associated with the
  same reference file, but only in the case where "precheck in child process" is
  not enabled (https://github.com/realm/realm-sync/pull/2465).
* New command line tool `realm-verify-server-file`, which opens the specified
  file with server-type history plug-in, and then calls `realm::Group::verify()`
  in a read transaction.
* Make it possible to request compaction of individual files through HTTP. The
  request path is `/api/compact<realm virtual path>`. If `<realm virtual path>`
  is the empty string, then the request is for all Realm files to be compacted
  (consistent with prior behavior). Otherwise, the request initiates compaction
  of the Realm file specified by `<realm virtual path>`. In any case, the server
  will respond with 200 "OK" when the requested compaction process is
  complete. Please note, due to limitations at the core level in the conditions
  under which compaction can be performed, compaction takes place on the network
  event loop thread of the server. For that reason, the server becomes
  completely unresponsive while compaction is in progress. This was true, and
  remains true for now.
* Core updated to 5.11.3 (includes new assertions in release mode)

-----------

## Sync team internal change notes
* Command line tool `realm-stat`: Encryption key is now specified as file-system path.

----------------------------------------------


# 3.12.5 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* The default action of the sync server node wrapper on an uncaught exception
  is to abort instead of exit(1).

### Enhancements
* The server logs the maximum number of open files on start-up.
* The sync server node wrapper logs an error message on catching a fatal error
  and sleeps for two seconds to increase the chance that the log message is
  emitted before the process aborts.
* Added maxOpenFiles to the typescript sync server configuration.

----------------------------------------------


# 3.12.4 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Enhancements
* The implementation of the merge algorithm has been made more efficient
  (https://github.com/realm/realm-sync/pull/2449).
* New StatsD metric `<prefix>.precheck_time` (timing) emitted on completion of
  the server file prechecking process. It is the time taken, in milliseconds, by
  that prechecking process.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Internal Enhancements
* If too many server files fail the prechecking step, the server will not
  start. The limit on the number of files has been raised from 10 to 50 to
  accommodate a case where 17 files failed the precheck step.
* Prechecking with partial sync enabled is now much more efficient in the case
  where nothing has changed in the partial file since the previous prechecking
  round.
* Bumped Core dependency to 5.10.3.
* The time taken by the server file prechecking process is now logged.
* During server file prechecking, a progress message is logged once every 5
  minutes.
* Added utility header `<realm/util/get_file_size.hpp>`.

----------------------------------------------


# 3.12.3 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Enhancements
* Performance improved when merging changes on the server.
* Reduced file size of server side realms.

-----------

## Sync team internal change notes
* A "dirty" flag was added to the `Changeset` class. When the merge algorithm
  modifies a changeset, it is marked as dirty. Non-dirty changesets are not
  persisted in the reciprocal history. This should reduce write-load when
  integrating remote changesets, and in turn reduce Realm file sizes, especially
  on the server.

----------------------------------------------


# 3.12.2 Release notes

### Internal Enhancements
* Outward partial synchronization is no longer performed during prechecking of
  server files (boot-up consistency checker), only inward partial
  synchronization. This is expected to drastically reduce the prechecking time
  in cases where partial sync is enabled as part of the prechecking step.
* Added utility header `<realm/util/value_reset_guard.hpp>`.

----------------------------------------------


# 3.12.1 Release notes

### Internal Enhancements
* New member `metrics_prefix` added to `config::Configuration` (server
  configuration).

----------------------------------------------


# 3.12.0 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* A bug has been fixed in the OT merge algorithm that could lead to errors such
  as `BadChangesetError`, particularly on clients using query-based sync.
  https://github.com/realm/realm-sync/issues/2389

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Internal Bugfixes
* Avoid swallowing mocha error codes on CI

### Internal Enhancements
* `ChangesetIndex` has been rewritten in a way that should reduce memory
  pressure.

## Sync team internal change notes
* `ChangesetIndex` now scans changesets and builds conflict groups up-front
  instead of while indexing instructions.

----------------------------------------------


# 3.11.1 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Enhancements
* At start, the sync server logs at info level whether encryption is enabled.
  In case encryption is enabled, a fingerprint of the key is logged.
* The sync server stores an encryption key fingerprint in a file with path
  `root_dir/encryption_key_fingerprint`. The server will only start if the
  configured encryption key matches the fingerprint. This change makes the
  server robust against a situation where a misconfigured encryption key, in
  combination with the consistency checker could lead to data loss.
  Issue: https://github.com/realm/realm-sync/issues/2420.
* The sync server keeps track of the size of pending uploaded changesets.  The
  server logs and emits metrics every time the size of pending changesets
  change. The metric is a gauge with key "upload.pending.bytes".
  Issue: https://github.com/realm/realm-sync/issues/2406
* The sync server reports the total time from receiving an uploaded changeset
  until it has been processed. If multiple changesets are pending
  simultaneously, the longest time is reported.  The times are logged and
  emitted to metrics. The metric is a timer with key "upload.processing".
  Issue: https://github.com/realm/realm-sync/issues/2407
* If configured, the server performs a consistency check of its Realms at start
  up. The consistency check is now done using multiple operating system
  processes in order to increase the robustness of the check; if a consistency
  check crashes in a worker process, the surviving main process will continue
  the check.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Breaking API changes
While the following changes technically breaks the public API, they are not being
used by anyone yet.
* Error codes `end_of_input`, `premature_end_of_input`, and `delim_not_found`
  have been moved out of `util::network::errors` and into a new `enum`-type
  called `util::MiscExtErrors` (intended to eventually be merged with
  `util::misc_errors` in the core library). This was done to allow those error
  codes to be reused in contexts unrelated to networking. The name of the
  corresponding error category is `realm.util.misc_ext`, and the global category
  object is available as `util::misc_ext_error_category`.
* Error `enum`-type `util::network::errors` was renamed to
  `util::network::ResolveErrors`, since all remaining error codes are related to
  network address resolution (DNS). The name of the corresponding error category
  is `realm.util.network.resolve`, and the global category object is available
  as `util::network::resolve_error_category`.
* Error `enum`-type `util::network::ssl::Error` renamed to
  `util::network::ssl::Errors`. The name of the corresponding error category is
  `realm.util.network.ssl`, and the global category object is available as
  `util::network::ssl::error_category`. Function
  `util::network::ssl::ssl_error_category()` no longer exists.
* The error category associated with error codes produced by OpenSSL is now
  available via the global object
  `util::network::openssl_error_category`. Function `openssl_error_category()`
  no longer exists. The name of the category is still `openssl`.
* The error category associated with error codes produced by Apple's
  SecureTransport library is now available via the global object
  `util::network::secure_transport_error_category`. Function
  `secure_transport_error_category()` no longer exists. The name of the category
  is still `securetransport`.
* Members `should_compact_realms_at_start` and
  `should_perform_partial_sync_at_start` of `config::Configuration` (server
  configuration) were renamed to `precheck_compact` and `precheck_partial_sync`
  respectively.
* Command line options `--should-compact-at-start` and
  `--should-perform-partial-sync-at-start` of Realm server command
  (`realm-sync-worker`) were renamed to `--precheck-compact` and
  `--precheck-partial-sync` respectively.

### Internal Enhancements
* The crypto library is updated with a SHA256 hash function.
  It is implemented for both apple and openssl.
* A function for calculating a SHA256 fingerprint of an encryption key is
  added. A verify function is added as well.
* The prepare_server_directory() function used to start the sync server is
  updated to store an encryption key fingerprint in a file called
  root_dir/encryption_key_fingerprint. At every server start the configured
  encryption key, if any, is compared with the fingerprint in the file. If
  there is disagreement, an exception with an informative message is thrown.
* Added utility header `<realm/util/misc_ext_errors.hpp>` (intended to
  eventually be merged with `<realm/util/misc_errors.hpp>` in the core library).
* A number of previously hidden error category objects are now exposed to
  applications. This serves two purposes: First, it allows the applications to
  compare categories more efficiently, i.e., by object pointer rather than by
  name. Second, it makes comparisons between error codes much more efficient.
* Added utility header `<realm/util/system_process.hpp>`.
* New members `precheck_in_child_proc`, `precheck_command_path`, and
  `precheck_verify` added to `config::Configuration` (server configuration).
* New command line option `--precheck-verify` added to Realm server command
  (`realm-sync-worker`).


## Sync team internal change notes
* SHA1 function signature changed to take unsigned char* instead of char*
  argument.

----------------------------------------------


# 3.10.1 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* Verifying SSL certificates on the Sync client would leak memory. It would
  present itself as enhanced memory consumption by a client that keeps connecting
  to the server with no app restarts in between. The memory leak was introduced in
  Sync release 3.9.0.
* Fixed a bug that could result in `PartialSync: Violation of no-merge
  invariant: ...` errors on the server (uncaught exception). The bug was
  introduced in Realm Sync 3.9.0. Upgrade recommended.
* The consistency checker upgraded to use Realm encryption for partial Realms.
* Partial sync permissions are changed to be based on the user identity in the
  URL instead of the user identity of the connecting user. Especially, when an
  admin user connects to a partial Realm, the partial Realm will not receive
  objects that the normal user does not have access to. This bug fixes
  https://github.com/realm/realm-sync/issues/2362.

### Enhancements
* Add an arm64_32 slice to the watchOS build to support building for Watch Series 4.

-----------

## Internal
Below are internal changes that don't affect end users and are only relevant to
Realm developers.

### Internal Bugfixes
* OpenSSL memory leak issue https://github.com/realm/realm-sync/issues/2392 solved.
* Fix compilation of the inspector tools.
* The introduction of server-side multithreading introduced a bug that could
  cause `ServerFile::m_need_outward_psync` to incorrectly be cleared. This could
  result in `PartialSync: Violation of no-merge invariant: ...` errors. This has
  been fixed.

### Internal Enhancements
* realm-encryption-transformer gained a new flag `-j|--jobs` that enables parallel workloads.

## Sync team internal change notes
* The number of rounds in the test Transform_Randomized has been lowered to 1
  to make the test suite run faster.
* Removed warning for exception in no-throw function.
* A function _impl::parse_virtual_path() that parses virtual paths and returns
  a struct that contains information about validity, partial or non-partial,
  real Realm path, reference path if applicable, and user_identity if
  applicable.

----------------------------------------------


# 3.10.0 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Breaking changes
* The sync protocol version has been bumped to version 25. The server is
  backwards-compatible with clients using protocol version 24 or below, but
  clients at version 25 are not backwards-compatible with a server at protocol
  version 24. The server must be upgraded before any clients are upgraded.

### Bugfixes
* When using query-based sync and performing a query that would return a very
  large (>4 GB) resultset, ROS could crash with
  'std::runtime_error("Compression error")'.  (Issue:
  https://github.com/realm/realm-sync/issues/2280. Present since ROS 3.0).
* Crashes related to changeset processing in query-based sync have
  been fixed.

### Enhancements
* Clients using protocol 25 now report download progress to the server,
  even when they make no local changes. This allows the server to do history
  compaction much more aggressively, especially when there are many clients that
  rarely or never make local changes. The server considers doing history
  compaction when an actual change is uploaded to the server. Related issue:
  realm/realm-object-server#127

-----------

## Internal
Below are internal changes that doen't affect end users and are only relevant to
Realm developers.

### Internal Bugfixes
* Rewrite of the zlib based compress() and decompress() functions to
  update the zlib stream repeatedly with chunks whose size can be
  represented as an unsigned int.
* Clearing the TableInfoCache after changeset processing in outward partial
  sync if objects are deleted or tables are cleared. This fixes a bug found by
  fuzz testing.
* object_for_row_id() returns realm::npos instead of asserting for large
  ObjectIDs.

### Internal Enhancements
* Upgraded Core dependency to version 5.10.1.
* A test util function for generating random data of a specified size.
* Many exceptions now include a stack trace (when supported) of their throw-site
  in their `what()` message.

## Sync team internal change notes
* The SSL certificates used for testing have been updated with very long expiration times.

----------------------------------------------


# 3.9.9 Release notes

## Public
Below are changes that affect end users of our products. These changes should
most likely propagate through to release notes of our end products.

### Bugfixes
* The sync server has updated treatment of HTTP requests with non-standard Content-Length headers.
  This change is a contribution to solving https://github.com/realm/realm-sync/issues/2378.

----------------------------------------------


# 3.9.8 Release notes

### Bugfixes

* The sync server could crash with an exception with description 'Violation of
  no-merge invariant'.  It is believed that this bug is the cause of an error
  seen in https://github.com/realm/realm-sync/issues/2347.
* Make the master side (as opposed to the slave side) of the backup mechanism
  able to deal with HTTP-based Realm file deletion without crashing. This fix is
  not sufficient to make the backup mechanism able to properly handle Realm file
  deletions, instead, it simply avoids a likely server crash when a Realm file
  is reintroduced after having been deleted. Without additional work towards
  supporting file deletions in the backup mechanism, there will be a remaining
  risk of a server crash, and even of corrupting the backup.

-----------

### Internals

* Add a client Config option `disable_upload_activation_delay` that allows a
  client to upload changesets before it has performed download completion.
  Currently clients sometimes wait for download completion after connecting to
  the server before they start uploading. Clients used to always activate the
  upload process immediately. The new option enforces the old behavior. The
  option is intended exclusively for testing purposes.

----------------------------------------------


# 3.9.7 Release notes

### Enhancements

* Add support for `ssl_trust_certificate_path` on iOS.
* Pin the leaf certificate when using `ssl_trust_certificate_path` on Apple
  platforms as was already done when using OpenSSL.

----------------------------------------------


# 3.9.6 Release notes

-----------

### Internals

* Include `realm-encryption-transformer` binary in the npm package.

----------------------------------------------


# 3.9.5 Release notes

### Enhancements

* Add support for encryption of server-side files. Encryption is switched on by
  specifying a 64-byte encryption key in `sync::Server::Config::encryption_key`.

-----------

### Internals

* The realm-sync-worker gets command line options for
  should-compact-realms-at-start and should-perform-partial-sync-at-start.
  These options make it possible to run the consistency check at start with
  realm-sync-worker.
* Make `inspector/realm-stat` command line tool able to inspect encrypted Realm
  files.
* Bumped Core dependency to 5.10.0.
* Utilize new `bump_version_number` argument of `SharedGroup::compact()` to
  increase robustness of backup mechanism.

----------------------------------------------


# 3.9.4 Release notes

### Bugfixes

* Fixed the consistency checker such that it does not crash on empty partial Realms.

----------------------------------------------


# 3.9.3 Release notes

### Bugfixes

* Fix a crash when running a server without a public key introduced in 3.9.2.

----------------------------------------------


# 3.9.2 Release notes

### Bugfixes

* Adding a table and creating a subscription for it without having permissions
  to create the table could result in a `CrossTableLinkTarget` exception being
  thrown by Core. (realm/realm-object-server-private#1216)
* Outward partial sync was fixed to handle the case where temporary link
  targets have been previously deleted in the reference Realm. This bug could
  lead to crashes and error messages of type "index out of range" or an
  assertion of the form "ndx < m_size". This bug could explain many of the
  "index out of range" crashes that have been seen. This bug has not led to bad
  changesets being generated, which means that there should be no remnants of
  the bug in existing Realms.  This bug solves issue
  https://github.com/realm/realm-object-server-private/issues/1162.
* In outward partial sync, the member variable m_selected_table is changed to a
  std::string instead of StringData, since it could get mutated incorrectly.

### Enhancements

* New member function `decompose_server_url()` added to `sync::Client`.

-----------

### Internals

* Upgrade to Core 5.8.0 to support LIMIT queries.
* The authentication protocol has now been integrated into the test client and
  is activated by specifying a username (`--username`) and optionally a
  password (`--password`) on the command line.
* Test client: Command line option `-u` changed from being shorthand for
  `--queryable-text` to being shorthand for `--username`. Command line option
  `-p` changed from being shorthand for `--statsd-port` to being shorthand for
  `--password`. Command line option `-b` changed from being shorthand for
  `--statsd-address` to being shorthand for `--queryable-text`.
* Added a package-lock.json to the `realm-sync-server`.

----------------------------------------------


# 3.9.1 Release notes

### Bugfixes

* HTTP compact request could get hung indefinitely when quickly following a HTTP
  deletion request.

----------------------------------------------


# 3.9.0 Release notes

### Bugfixes

* Avoid access to dangling arrays after end of transaction
  (`ServerHistory::get_salted_server_version()`).
* Fixed another problem in time-to-live-based server-side history compaction
  caused by transient information
  (`_impl::ServerHistory::m_clients_last_seen_at`) getting lost across a
  close/reopen cycle of the file access cache (`_impl::ServerFileAccessCache`).
* Fixed a bug in the client where a session was not properly discarded after a
  deactivation process ending with the reception of an ERROR message. When this
  happened, it would lead to corruption of the client's internal datastructures
  (or an assertion failure if built in debug mode).
* Sync server can now handle HTTP requests for Realm file deletion on Windows
  platforms.
* Make sure that ssl stream is destroyed before its socket in the backup client.
* Initialize the logger of a `network::ssl::stream` to `nullptr`.

### Breaking changes

* Member functions `set_sync_progress()` and `integrate_server_changesets()` in
  `sync::ClientHistoryBase` now take a `sync::VersionInfo&` argument.

### Enhancements

* The sync server has been upgraded to a multithreaded architecture. It now has
  two major internal threads, a networking event loop thread, and one worker
  thread for performing potentially long-running tasks. The main motivation
  behind this change, was to allow the server to stay responsive in terms of
  network communication. It is particularly important that the server is able to
  maintain heartbeat with all simultaneously connected clients, because loosing
  connections leads to disruption for the end users, but also because it is
  relatively expensive for the server to reestablish connections, especially in
  the context of partial synchronization.
* Sync server now uses an adaptive scheme for caching and reusing query results
  during partial synchronization. The scheme is still very rudimentary, though.
* Sync server now has actual support for synchronous backup of Realm files
  taking part in partial synchronization. Until now, both reference and partial
  files were backed up **asynchronously** even though synchronous backup was
  selected for the server.
* Improved support for asynchronous backup: Reference file is now guaranteed to
  be backed up after partial files. This will eliminate a potential for
  corruption during a fail-over from the master to the backup slave.
* The backup client will use an embedded list of SSL trust certificates when
  built with the option `REALM_INCLUDE_CERTS` set to true. This change will make
  sure that backup slaves accept the certificates of the master if the master
  uses a certificate signed by a standard Certificate Authority.

-----------

### Internals

* Add utility header `<realm/util/circular_buffer.hpp>`.
* Add utility header `<realm/util/parent_dir.hpp>`.
* New support for integrated backup in client/server test fixture
  (`test/sync_fixtures.hpp`).
* Updated the devtoolset to version 6 for CentOS 6.
* Disabled ASAN to avoid errors coming from the change of devtoolset.

----------------------------------------------


# 3.8.16 Release notes

### Enhancements

* Expose option to toggle verification of backup master's SSL certificate.

----------------------------------------------


# 3.8.15 Release notes

### Bugfixes

* Fix the `masterSlaveSslTrustCertificatePath` property on the Node.js configuration.

----------------------------------------------


# 3.8.14 Release notes

### Bugfixes

* Fix copying the config settings for backup SSL in the Node.js API.

----------------------------------------------

# 3.8.13 Release notes

### Enhancements

* NodeJS package now allows catching fatal errors from the sync server binding,
  using the `errorCallback` configuration option.
* NodeJS binding is now bundled with both release and debug builds. The build can
  be chosen at runtime using the new `enableDebugMode` option to RealmSyncServer.

----------------------------------------------


# 3.8.12 Release notes

### Bugfixes

* Fix not flowing endpoint and SSL settings from the CLI to the runtime
  configuration in the Node.js server binding.

----------------------------------------------


# 3.8.11 Release notes

### Bugfixes

* The Node.js API can really start the server with SSL now.

-----------

### Internals

* Improved `realm-stat` command line tool. Extra robustness, and now also
  revealing history type and history schema version.

----------------------------------------------


# 3.8.10 Release notes

### Bugfixes

* Fixed distinct queries with partial sync (broken in 3.6.0).

### Enhancements

* Exposed SSL-related configuration options in the Node.js API.

----------------------------------------------


# 3.8.9 Release notes

### Bugfixes

* Some of the virtual methods of `_impl::ServerHistory::Context`, that are
  required when performing partial synchronization, were not implemented in
  `_impl::ServerInitialization`. They are now.

----------------------------------------------


# 3.8.8 Release notes

### Bugfixes

* Fixed (another) stray iterator bug, which could result in memory corruption
  and crashes on the server.

----------------------------------------------


# 3.8.7 Release notes

### Public

* Added more logging around the detection of invalid partial realms about to be
  renamed as "inconsistent". The error causing the inconsistency was previously
  swallowed.

### Bugfixes

* Fixed a bug in the permission system where establishing a link to an object
  that had previously been ignored due to permission checks would incorrectly be
  let through, and subsequently crash the server.

----------------------------------------------


# 3.8.6 Release notes

### Bugfixes

* Added missing `enlist_to_send()` after a session has sent an ALLOC message in
  `server.cpp`.
* Avoid race condition by always resuming download processes when
  `ServerFile::notify_sessions()` is called in `server.cpp`.

### Enhancements

* Introduce "delayed upload activation on connect" into the sync client. This
  means that in the general case, the upload process will start out in a
  suspended state after the client establishes a connection to the server, and
  that it will remain in this suspended state until the client reaches download
  completion. However, if the client was connected to the server less than 1
  minute ago (configurable), then the upload process will be activated
  immediately upon reconnect. This is to avoid unnecessary latency in change
  propagation. For now, the purpose of "delayed upload on connect" is to
  increase the chance of multiple initial transaction on the client-side, to be
  uploaded to, and processed by the server as a single unit.
* Added new sync client configuration parameter
  `sync::Client::Config::fast_reconnect_limit`.

-----------

### Internals

* Reduced number of large allocations in ChangesetIndex by using non-contiguous
  containers (`std::deque`) and move semantics where applicable.

----------------------------------------------


# 3.8.5 Release notes

### Bugfixes

* Support allocations larger than 16 MB in ScratchAllocator.


----------------------------------------------


# 3.8.4 Release notes

### Bugfixes

* Fixed another memory bug related to stray iterators while iterating in the
  merge algorithm, which could lead to memory corruption, changeset corruption,
  and crash the server/client. Also added an aggressive amount of checking in
  debug mode.

### Enhancements

* Improved the average memory usage during merge by applying the changeset
  indexing mechanism on incoming changesets rather than the local changesets.
  Building the changeset index is memory-intensive, but only needs to be done
  for one side. Since the number of incoming changesets is likely to be smaller
  on average than the number of local changesets (due to the heuristics for
  UPLOAD and DOWNLOAD message batching), this means that the average memory
  consumption is much more limited. Note that if a client uploads a very large
  changeset, the changeset indexing mechanism will still consume the necessary
  amount of memory to index that particular changeset.


----------------------------------------------


# 3.8.3 Release notes

### Enhancements

* Optimized `ChangesetIndex` when merging changesets that mention a large number
  of objects.
* Small optimization to the representation of `Changeset`, resulting in faster
  string lookups during merge.

----------------------------------------------


# 3.8.2 Release notes

### Bugfixes

* Fix undefined symbol errors when linking the client library introduced in
  3.8.0.

----------------------------------------------


# 3.8.1 Release notes

### Public

* Updated Core dependency to 5.7.2.

### Bugfixes

* Several bugs have been fixed in the merge algorithm that could lead to memory
  corruption and crash the server with errors like "bad changeset" and
  "unreachable code".
* It is made possible to start a new HTTP request in the completion handler for
  the previous HTTP response.
* A client session could get enlisted to send while it was already enlisted to
  send (request REFRESH message before reception of IDENT message).
* Make it possible to use util::make_thread_exec_guard() without a stoppable
  parent.

### Enhancements

* Sync server now logs a message at `info` level when it is shut down
  gracefully. The message is `Realm sync server stopped`.
* Detect violations of the "no merge during partial synchronization" invariant.
* When integration of an uploaded changeset fails, log enough information about
  the failure to allow the failure to be reproduced using a copy of the target
  Realm file plus the `realm-merge-changeset-into-realm` command line tool.

-----------

### Internals

* New `realm-stat` command line tool which dumps basic information about Realm
  files, especially information about the amount of file space used for
  different things, including a per-table break-down. It is currently located
  next to the inspector tools in `src/realm/inspector/`.
* Test client: Perform parameter substitution (`@N`, `@H`) in subscription
  queries.
* A util for function for generating random lower case strings.
* Building the test client with CMake.
* An authentication client library.

----------------------------------------------


# 3.8.0 Release notes

### Bugfixes

* When `sync::Client::Config::one_connection_per_session` is set to true (which
  it currently is by default), connections are now closed immediately after the
  session ends, irrespective of the configured connection linger time. This
  prevents a potentially large buildup of connections in cases where the
  application creates a lot of sessions within a short amount of time.

### Breaking changes

* Removed futile synchronization session configuration parameter
  `sync::Session::Config::one_connection_per_session`. Its value was, and has
  probably always been entirely ignored by the synchronization client
  implementation. Also, it made little sense to specify this parameter at the
  session level. Note that the right way to specify that the client should use a
  separate network connection per synchronization session, is via
  `sync::Client::Config::one_connection_per_session`.

### Enhancements

* The sync server is given an initialization phase. During initialization, the
  sync server can compact Realms and perform complete partial sync on all
  reference and partial Realms.  Inconsistent partial Realms are renamed and
  not used by the server. They can be removed manually if needed.  The sync
  server, and the node sync server, configuration gets two new parameters
  'should_compact_realms_at_start' and 'should_perform_partial_sync_at_start'.

-----------

### Internals

* Sync client now logs information at debug level about its configuration,
  including sync protocol version, and versions of Core and Sync libraries.
* Inspector command line tool for performing partial sync on a reference Realm
  and a partial Realm.
* Added a logger to the vacuum class.
* Introduce a test/resource directory to keep Realms used for testing.

----------------------------------------------


# 3.7.1 Release notes

### Public

* Update Core dependency to 5.7.1.

### Bugfixes

* The enabling of time-to-live-based server-side history compaction
  (`sync::Server::Config::enable_log_compaction`) was done in a way that would
  get lost when the associated file was closed and then later reopened by the
  file access cache. This is now fixed by making it the responsibility of the
  file cache mechanism to optionally enable compaction every time the file is
  opened/reopened.

### Enhancements

* New server configuration parameter
  `sync::Server::Config::enable_realm_state_size_reporting` (also available from
  NodeJS as `IRealmSyncServerConfiguration.enableRealmStateSizeReporting`). When
  set to true, the server will compute the state size of all Realm files once
  every 30 minutes. The state size of each file is reported as a metrics gauge
  value with key `<prefix>.realm_state_size,path=<percent encoded virtual path>`
  and the number of bytes as value. `<percent encoded virtual path>` is the URI
  percent encoding of the virtual path with only alphanumeric characters
  remaining unencoded. In general, `<prefix>` is `realm.<host name>`. The *state
  size* of a Realm file is the total size of the latest snapshot within the
  Realm file, minus the history compartment, and minus the "free space"
  registry.
* New function `sync::Server::report_realm_state_size_now()` to be used for
  immediate initiation of Realm state size computation and reporting for the
  specified Realm file.
* New HTTP request `/report-realm-state-size<realm virtual path>` to be used for
  immediate initiation of Realm state size computation and reporting for the
  specified Realm file.
* Improved performance of changeset parsing.
* Slightly sped up applying changes to Realm files.
* Eliminated double-parsing of changesets when merging changes.

-----------

### Internals

* Add utility header `<realm/util/signal_blocker.hpp>`.
* Add utility header `<realm/util/thread_exec_guard.hpp>`.

----------------------------------------------


# 3.7.0 Release notes

### Public

* Updated Core dependency to 5.6.5.

### Bugfixes

* Many bugs in the `PermissionsCache` were found and fixed, which could in some
  cases lead to privilege escalation depending on the batching of changesets in
  the `UPLOAD` message.

### Breaking changes

* Query-based sync no longer maintains the ordering of objects in the partial
  realm, and no longer updates the `matches` column with query results. Users of
  query-based sync are expected to re-run queries in the subscription locally to
  get the results.

### Enhancements

* Query-based sync has been greatly optimized, and should be faster under almost
  all workloads.

-----------

### Internals

* The implementation of query-based sync has been moved to `partial_sync.cpp`,
  and refactored for maintainability and performance analysis.
* The `ScratchAllocator` customer allocator concept has been added to support
  very fast scoped allocation.
* The `FlatMap` utility has been added to the repository, which is a
  cache-friendly alternative to `std::map` backed by linear storage (like
  `std::vector`). It is suitable for small maps where allocation of inner nodes
  is slower than shifting elements during insertion/deletion. It is not
  currently in use.

----------------------------------------------


# 3.6.0 Release notes

### Public

* Upgraded Core dependency to 5.6.4.

### Bugfixes

* When a Realm file, that is acting as a partial view, is modified, the
  modification must be immediately followed by synchronization with the
  reference Realm to ensure that there is never a need for merging of changes
  during synchronization between the partial view and the reference Realm. The
  problem was that this was done only if at least one session was associated
  with the partial view at the time of the modification of the partial
  view. This could lead to a kind of corruption that would cause errors during
  future synchronization between that partial view and the reference Realm. This
  fix still leaves a vulnerability in case of a crash, meaning that if the crash
  occurs after the modification of the partial view, but before the
  synchronization with the reference Realm, then the problem can still
  occur. This vulnerability needs to be addressed separately.
* After performing partial synchronization, activate backup after any change in
  a Realm file, not just when a new history entry is added.

### Breaking changes

* Server configuration parameter `sync::Server::Config::logger` now has to be a
  thread-safe logger.
* All implementations of interface `sync::Metrics` are now required to be
  thread-safe. Also, member function `gauge_relative()` removed from interface
  `sync::Metrics`. This was done because the implementation of of that function
  was not thread-safe.
* Interface `util::Clock` moved to `sync` namespace. Also, all implementation
  are now required to be thread-safe.

### Enhancements

* Improved performance of creating objects with string primary keys.

----------------------------------------------


# 3.5.8 Release notes

### Public

* Upgraded Core dependency to 5.6.3, which improves performance of commit for
  large transactions.

----------------------------------------------


# 3.5.7 Release notes

### Enhancements

* The sync server obtains a function
  stop_sync_and_wait_for_backup_completion(completion_handler, timeout) that
  closes all sync connections to clients and waits for backup completion.
  Backup completion is achieved when the slave has all changes from the master.
  The function has a time out.
* The node sync server obtains a function "stopSyncAndWaitForBackupCompletion"
  that returns a promise that resolves when backup is complete and is rejected
  after time out or error.
* HTTP request for /api/compact to the sync server makes the sync server
  compact all Realms. The request must be authorized with an admin user token.
* Improve client-side performance of setting multiple fields in a row on tables
  which have a string primary key.

-----------

### Internals

* Unit tests for stop_sync_and_wait_for_backup_completion.
* Unit tests for the node sync server stopSyncAndWaitForBackupCompletion.
* Replaced deprecated Nan Call and MakeCallback with AsyncResource.
* Introduce a BackupServer object that owns the Backup server connection.  The
  sync server communicates with the BackupServer through a BackupListener
  interface.
* The BackupServer is implemented in .hpp and .cpp files instead of as a
  template class.
* Added HTTP status code "410 Gone" to the WebSocket library.
* Timing the vacuum operation.
* Server functions for closing and compacting all Realms.

----------------------------------------------


# 3.5.6 Release notes

### Bugfixes

* Fixed a bug that caused PING messages to be sent without delay (at a much too
  high frequency) after an invocation of
  `sync::Client::cancel_reconnect_delay()`.

-----------

### Internals

* Added interactive mode to sync test client where commands are read from STDIN.

----------------------------------------------


# 3.5.5 Release notes

### Bugfixes

* Fixed a bug that could result in a crash with the message "bad changeset
  error" (both on client and server). The crash was caused by failure to update
  a pointer to the current changeset during merge, which again resulted in stray
  erases and potential memory corruption.

----------------------------------------------


# 3.5.4 Release notes

### Public

* Upgraded Core dependency to 5.6.2, including the fix for very large freelists.

----------------------------------------------


# 3.5.3 Release notes

### Public

* Upgraded Core dependency to 5.6.1.

-----------

### Internals

* Building for Linux no longer requires fiddling with the
  `_GLIBCXX_USE_CXX11_ABI` compiler flag depending on whether building against a
  a self-built or a released version of Core. The flag is now derived from
  Core's `realm-config.cmake`.

----------------------------------------------


# 3.5.2 Release notes

### Bugfixes

* Fixed a problem in the changeset indexing algorithm that would sometimes cause
  "bad permission object" and "bad changeset" errors to crash the server.

-----------

### Internals

* Changed the changeset indexin algorithm to be more conservative -- it now uses
  slightly more memory, but also does less copying while the merge algorithm
  runs.

----------------------------------------------


# 3.5.1 Release notes

### Public

* Re-"fixed" a crash on Android by downgrading the release optimization flags to
  `-O1`.
* Added a temporary workaround for the "invalid permission object" error that
  was sometimes crashing the server. It is not yet understood how the server
  gets into the state that causes the error.
* Expose `historyTtl`, `enableLogCompaction`, and `historyCompactionInterval` in the node API.

### Bugfixes

* Re-fixed a problem with duration comparisons of different ratios, which could
  sometimes result in integer overflow under the hood.

-----------

### Internals

* Do not report bytes sent and received via both StatsD counters and StatsD
  gauges, only report them via counters.
* When the server creates a new session, that binds a particular client-side
  file to a server-side file, but another session exists that binds the same
  client-side file to the server-side file, and the other session is associated
  with a different network connection, the server used to close the preexistsing
  conflicting session, but leave the associated connection open. Now it
  immediately closes the connection associated with the conflicting
  session. This change was made in the interest of getting zombie connections
  closed as soon as possible.
* Test client: Also single out system errors `ETIMEDOUT` and `EHOSTUNREACH` when
  reporting connection termination reason metrics to StatsD.

----------------------------------------------


# 3.5.0 Release notes

### Public

* The "Developer Edition" has been disabled. All users of the
  `realm-sync-server` Node.js module must now set the `featureToken`
  configuration parameter to a valid feature token.

### Bugfixes

* None.

### Breaking changes

* None.

### Enhancements

* For whole file transfer, the Realm is copied before sending the fragments.
  This ensures that fragmented Realm transfer works for asynchronous backup
  where the Realm might change during the transfer.
* A RealmBackupState class that keeps track of the state of the backup for a
  Realm. The class allows the server to signal that the Realm needs to be
  backed up again during the fragmented transfer of the Realm.
* Backup utilility functions for getting the path of a Realm and its version.
* Backup client uses util funtions.
* Backup server uses util functions instead of ServerFile.
* Backup whole reference Realms
* Sync server backs up partial sync Realms and makes sure that partial Realms
  and reference Realms are all backed up.
* Backup client treats partial Realms differently than other Realms to avoid
  partial sync initialization to run on the backup client.

-----------

### Internals

* New test client feature: Generate multiple objects per propagation time
  measurement request (`--num-blobs`).
* Sync server now reports event loop metrics to StatsD if compiled with
  `-DREALM_UTIL_NETWORK_EVENT_LOOP_METRICS`.
* Unit tests for partial sync backup.
* Remove redundant code in test_backup.

----------------------------------------------


# 3.4.0 Release notes

### Public

* Server-side history compaction at-rest has been added, in order to reduce
  server file sizes. The configuration options `enable_log_compaction`,
  `history_ttl`, and `history_compaction_interval` have been added to let the
  user control log compaction. If a client is offline for longer than
  `history_ttl` (default: forever), it may experience a reset, and it will
  receive a `bad_server_version` protocol error from the server). The server
  will only consider compacting the history every `history_compaction_interval`
  seconds (default: 1 hour). History log compaction is enabled by default, but
  the default settings never force a client to reset. History log compaction
  does not yet have any effect on 'reference' Realms used in query-based
  synchronization.
* A new command-line utility `realm-vacuum` was added, which allows server
  admins to manually run compaction of Realm files from the command-line.

### Breaking changes

* Server-side history schema format has been bumped to version 5, in order to
  add support for live history compaction. After upgrade, reverting to an older
  server is not possible.

----------------------------------------------


# 3.3.0 Release notes

### Public

* Update Core dependency to 5.6.0.

### Bugfixes

* Get rid of global metrics object in Node.js wrapper for sync server. Thereby,
  different server instances will no longer mix their metrics.
* The backup does not leave Realm fragments in tmp folders.

### Breaking changes

* The Dogless implementation of the metrics interface is now available as
  `sync::make_buffered_statsd_metrics()`. The class `sync::DoglessMetrics` is no
  longer publicly available.

### Enhancements

* The server now emits StatsD metrics for a breakdown of different connection
  termination reasons. See "Connection termination reasons" in
  `doc/monitoring.md` for details.

-----------

### Internals

* New test client feature: Allow incoming changeset propagation time measurement
  requests to be ignored if they were initiated before the connection to the
  server was last established (`--request-threshold`).
* New test client feature: Compute sample sizes and fractiles over propagation
  time measurements, and report them to StatsD.
* New test client feature: Report heartbeat based roundtrip times to StatsD
  (`--report-roundtrip-times`).
* Add inspector tool `dump-changeset`.
* Added Win32 to the test stage in CI.
* Add SSL certificates to the Android client library.

----------------------------------------------


# 3.2.2 Release notes

### Public

* Dogless (statsd) support has now also been re-added to the Sync worker Node
  module.
* Changed default configuration value for `maxDownloadSize` to 16 MB.

----------------------------------------------


# 3.2.1 Release notes

### Bugfixes

* Narrowing conversion fixed.

----------------------------------------------

# 3.2.0 Release notes

### Public

* Introduce max memory consumption for the backup.

### Bugfixes

* None.

### Breaking changes

* Bump the backup protocol to version 3.

### Enhancements

* Introduce a vector of mismatch realms for which the whole Realm files are
  sent asynchronously.
* Introduce a protocol message that transfers Realm files in fragments.
* The backup master reads the Realm file to transfer in chunks when the
  connection to the slave is ready to receive more data.
* The backup slave assembles a received Realms in a temp directory and moves
  the whole Realm to the sync server root_dir when completed.

-----------

### Internals

* Unit test for whole Realm transfer in the backup system.

----------------------------------------------


# 3.1.1 Release notes

### Public

* Dogless support was accidentally disabled in previous 3.x releases due to an
  oversight in the build scripts. This situation has been remedied.

### Breaking changes

* The concept of "urgent PONG message timeout" has been removed from the sync
  client. The corresponding configuration parameters
  `sync::Client::Config::pong_urgent_timeout_ms` and
  `sync::Server::Config::upstream_pong_urgent_timeout_ms` have also been
  removed.
* Suffix `_ms` (milliseconds) dropped from client configuration parameter names
  `connect_timeout_ms`, `connection_linger_time_ms`, `ping_keepalive_period_ms`,
  and `pong_keepalive_timeout_ms`, and from server configuration parameter names
  `http_request_timeout_ms`, `http_response_timeout_ms`, `idle_timeout_ms`,
  `drop_period_ms`, and `soft_close_timeout_ms`. The fact that these are
  expressed in milliseconds is now conveyed by their type name, which is
  `sync::milliseconds_type`, and is defined in `<realm/sync/protocol.hpp>`. This
  is now a signed integer type. Before it was unsigned.
* The function `set_idle_timeout_ms()` of `sync::Server` has been renamed to
  `set_idle_timeout()`. The fact that the argument is expressed in milliseconds
  is now conveyed by its type name, which is `sync::milliseconds_type`, and is
  defined in `<realm/sync/protocol.hpp>`. This is now a signed integer
  type. Before it was unsigned.
* New error code `bad_timestamp` in error enumeration `sync::Client::Error`.

-----------

### Internals

* One can now specify a function to be called by the sync client with the
  round-trip time whenever a PONG message is received
  (`sync::Client::Config::roundtrip_time_handler`). This is mainly for testing
  purposes.

----------------------------------------------


# 3.1.0 Release notes

### Public

* Log at warning level for slow merge.
* Update Core dependency to 5.5.0.

### Bugfixes

* None.

### Breaking changes

* Server configuration parameters `idle_timeout_s` and `drop_period_s` in
  `config::Configuration` have been replaced with `idle_timeout_ms` and
  `drop_period_ms` respectively. The new ones are specified in milliseconds,
  whereas the old ones were specified in seconds.

### Enhancements

* Server will now enforce a limit to the amount of time it takes to process an
  HTTP request (`http_request_timeout_ms` and `http_response_timeout_ms` in
  `sync::Server::Config`).
* Server now uses parameter `soft_close_timeout_ms` in `sync::Server::Config` to
  enforce a limit to the amount of time to wait for the client to close the
  connection after the server has sent an ERROR message.
* The sync client now enforces an upper bound on the time that is used to fully
  establish a connection to the server (including network address resolution,
  SSL handshake, and WebSocket handshake). If the allotted time is insufficient,
  the connect operation will be aborted.
* New client configuration parameter `connect_timeout_ms` was added to
  `sync::Client::Config`. The default value is 120'000 (2 minutes).
* Fix handling of 30x HTTP status codes in sync client.
* `util::load_file()` can now be used to load from a stream-like file, i.e., one
  whose size can only be determined by reading until the end-of-file marker is
  reached.

-----------

### Internals

* The time between PING messages can now be specified in the test client (`-I`
  or `--time-between-pings`).
* Sync server command line options `--idle-timeout-s` and `--drop-period-s` have
  been replaced with `--idle-timeout` and `--drop-period` respectively. The new
  ones are specified in milliseconds, whereas the old ones were specified in
  seconds.
* New command line option `--pong-timeout` (and `-O`) was added to test client.
* New command line option `--connect-timeout` (and `-U`) was added to test
  client.
* New test client feature: Wait for download completion before initiating
  testing process (`--download-first`).
* Test client has improved facilities for adding subscription queries and
  queryable contents (`--query-class`, `--ensure-query-class`,
  `--queryable-level`, `--max-queryable-level`, `--queryable-text`,
  `--generate-queryable`, and `--add-query`).
* Test client now reports error type breakdown to StatsD.
* New parameter substitution scheme for test client command line arguments PATH
  and URL. `@N` will be replaced by the number of the corresponding peer, and
  `@H` will be replaced by the hostname (as returned by the `hostanme`
  command).
* Maximum reconnect delay after nonfatal errors raised from 1 to 5 minutes.
* New test client feature: Halt on crash, i.e., sleep indefinitely after test
  client exits with nonzero exit status or is killed by a signal
  (`--halt-on-crash`).
* New test client feature: Allow generation of core dumps (`--allow-core-dump`).
* Reproduction test for issue 2104 for slow merge.
* Inspector commands to help debug issues with Realms and changesets.
* Inspector: realm-print-changeset takes a hex changeset, say from a log file,
  and prints out the instructions.
* Inspector: realm-inspect-server-realm prints out information about clients and
  changesets from a server side Realm.
* Inspector: realm-merge-changeset-into-realm takes a changeset, a Realm and
  variables such as client-version and merges the changeset into the Realm.
  The command can be used to merge a changeset from a log file into a Realm.
* The changeset index range contains all instructions for clear table and
  schema change instructions. This change improves performance drastically in
  certain worst case scenarios. For a schema change in a table with many
  objects, merge_ranges_in_place() is called many times resulting in slow
  execution. With the current change, the range is immediately set to all
  instructions without any computation. The actual merge is slower with this
  change but it is more than compensated by less work in calculating the
  ranges. The original implementation is faster for few objects, but since
  schema changes are rare the quadratic problem is usually not present for
  schema changes.

----------------------------------------------


# 3.0.3 Release notes

### Internals

* macOS build fixes.

----------------------------------------------


# 3.0.2 Release notes

### Public

* Includes the changes from sync 2.2.16.

-----------

### Internals

* Unit test for SSL to external servers.
* Logging integrated changesets if integration of changesets takes more than 10
  seconds.

----------------------------------------------


# 3.0.1 Release notes

### Public

* Update Core dependency to 5.4.2.

### Breaking changes

* WebSocket error codes have changed. See `<realm/util/websocket.hpp>` for the
  full list.
* The variable `is_fatal` in the connection state change listener has slightly
  different semantics: All 5xx HTTP responses are considered nonfatal.

### Enhancements

* Extensive logging of errors when the client receives a HTTP response.

-----------

### Internals

* New ConnectionTerminationReasons:
    `server_sent_fatal_http_response`
    `server_sent_non_fatal_http_response`
    `ssl_certificate_rejected`
* Check for valid HTTP status codes at receipt of HTTP response.
* Logging in the HTTP library.
* Unit test of the client response to errors in the sync handshake. A test
  server(`SurpriseServer`) is created to produce all kinds of HTTP response to a
  sync client WebSocket request.

----------------------------------------------


# 3.0.0 Release notes

### Public

* Support for object-level and class-level permissions has been added to the
  "partial sync" feature. Partial views of the database will be filtered by the
  server such that users can only see objects and classes to which they have
  access, and changes made by clients will be reverted by the server if the
  user does not have access to make the change. See
  [`<realm/sync/permissions.hpp>`](src/realm/sync/permissions.hpp).
* Support for destructive schema changes (`EraseTable` and `EraseColumn`) has
  been added to the sync protocol, and the protocol version has been bumped to
  24.
* The existence of permissions metadata is now a prerequisite for using Partial
  Sync. Attempting to connect to Realm with Partial Sync without sufficient
  in-Realm permissions set up will result in empty queries and all changes being
  reverted by the server.
* Update Core dependency to 5.4.0.
* We are now building and testing our Node.js server module for Node.js versions
  6.10.3, 8.9.4, and 9.6.1.
* For OpenSSL, the sync client includes a fixed list of certificates in its
  SSL certificate verification besides the default trust store in the case
  where the user is not specifying its own trust certificates or callback.
* The sync worker now adds the user on connection, and adds the user to the
  "everyone" role.

### Breaking changes

* Partial sync is no longer allowed for clients using protocol versions lower
  than 24.
* Support for building with yaml-cpp, and by consequence using a configuration
  file with the sync server, has been removed.
* Instructions with "Container" in their name have been renamed to "Array". The
  members of the enum `ContainerType` have been renamed to correspond with
  current naming conventions.

### Bugfixes

* The log message about log compaction ("Log compaction: Saved X bytes") was
  incorrectly using `downloadableBytes` in the "before" part of the calculation,
  resulting in unrealistically high numbers in the log.
* `InstructionApplier` now rejects a changeset if it attempts to add a column
  twice (based on the name of the column).
* The merge algorithm now also throws an error if two `AddColumn` instructions
  with diverging `container_type` (but otherwise identical) meet one another.
* Permissions now log warnings about setups that look erroneous.
* The server now automatically creates the `__ResultSets` table when a client
  connects through partial sync if the client hasn't already created it. This
  also solves a common gotcha, where permission metadata would not be
  synchronized to the client before the client created the first partial sync
  subscription.
* A use-after-free bug was fixed which could cause arrays of primitives to
  behave unexpectedly. Specifically, the pattern employed by the data connector
  triggered unexpected behavior.
* HTTP response on the client without a `Reason-Phrase` field is no longer
  considered malformed. This does not technically conform to the HTTP/1.1
  standard, but some proxies appear to produce these responses.
* Fixed a bug in the changeset indexation mechanism that could cause the merge
  algorithm to mistakenly let some instructions meet each other twice, causing
  mismerge.
* The is_admin() function accepts users with access level "manage" in the token
  as admin users to be compliant with ROS.

### Enhancements

* Improve error checking and reporting for schema errors in partial Realms.
* Support for erase columns for permission corrections.
* The server adds subscriptions to the internal permissions tables to partial
  sync clients.
* Partial Sync results can now be controlled with the sort/limit syntax. There
  are some limitations, particularly that the client-side still has to manually
  perform any pagination of results, and the server doesn't communicate a "total
  count" yet.
* Permission changes are made in a local write transaction in the reference
  Realm. The permission change is initiated in the receive_ident_message from a
  partial client. The change is made asynchronously by ServerFile.
* Changeset indexing has been overhauled and performance has been improved.

-----------

### Internals

* `AddColumn` with `type_Link` and `ContainerType::Array` is now equivalent to
  `AddColumn` with `type_LinkList` and `ContainerType::None`.
* Backlink queries are now explicitly rejected by partial sync. If the user
  uploads a query containing backlinks, zero results will be returned and the
  "error_message" field set to explain what happened.
* Unit test for SSL connection to the Realm Cloud.
* A function `Context::use_included_certificates()` in
  `src/realm/util/network_ssl.cpp` that includes a list of certificates from
  a header file in a SSL context.
* REALM_INCLUDE_CERTS variable to denote inclusion of SSL certificates in the
  client binary.
* Unit test for forbidden schema change in partial sync.
* Logging permission corrections.
* Asking about permissions on objects that don't exist in the database now
  always returns 0 (no access).
* Support for column and table removal in partial sync.

----------------------------------------------


# 2.3.10 Release notes

### Enhancements

* Configuration parameter `listen_backlog` added to sync server. Available as
  `--listen-backlog` or `-b` from the command line. This corresponds to
  `backlog` argument of `listen()` function as described by POSIX.

-----------

### Internals

* Test client can now include timestamps in log output (`-K`,
  `--log-timestamps`).
* Test client can now be asked to grow the number of peers over a period of time
  (`--num-growths` and `--time-between-growths`).
* In test client, short option for `--num-blobs` was changed from `-g` to `-B`.
* In test client, short option for `--generate-queryable` was changed from `-G`
  to `-Q`.

----------------------------------------------


# 2.3.9 Release notes

### Public

* Includes the changes from sync 2.2.13, 2.2.14, and 2.2.15.

### Enhancements

* `sync::Session::refresh()` will now cancel any reconnect delay in progress.
* Improved support for asynchronous network address resolution (DNS). An
  in-progress `util::networkREsolver::async_resolve()` operation no longer
  blocks the event loop.
* New facility (`<realm/util/enum.hpp>`) to wrap an enumeration type in a class
  type that allows for the enumeration values to be written to, and read from an
  STL stream.

-----------

### Internals

* `Server::wait_for_upstream_upload_completion()` and
  `Server::wait_for_upstream_download_completion()` will no longer complete
  immediately on a subtier server where the upstream URL is unspecified. This
  aligns with the original intention.
* Test client refactored into multiple source filess.
* Logging and error handling improved in test client.
* Fixed a number of accumulated regressions in the "changeset propagation time
  measurement" function of the test client.
* Log level for synchronization process of test client is now controlled
  separately from the log level of the testing process. The former is specified
  by `-k` or `--sync-log-level`, whereas the latter continues to be specified by
  `-l` or `--log-level`.
* Test client now has support for aborting on any error, not just fatal errors
  (enabled by `-E` or `--abort-on-all-errors`.
* The access token to be used by the test client can now be specified either as
  a file system path (`-P` or `--access-token-path`), or literally (`-A` or
  `--access-token`).
* The test client option `--disable-sync` renamed to `--disable-sync-to-disk`.
* The test client now has support for delaying the start of the test process
  (`--start-delay` and `--max-start-delay`).
* The test client now has support for specifying a metric labels prefix (`-M`,
  `--metrics-prefix`).

----------------------------------------------


# 2.3.8 Release notes

### Public

* Includes the changes from sync 2.2.12.

-----------

### Internals

* Disabled unit test `Sync_SSL_Certificates`.

----------------------------------------------


# 2.3.7 Release notes

### Public

* Includes the changes from sync 2.2.11.
* Upgraded Core dependency to 5.3.0.

-----------

### Internals

* Backlink queries are now explicitly rejected by partial sync. If the user
  uploads a query containing backlinks, zero results will be returned and the
  "error_message" field set to explain what happened.

----------------------------------------------


# 2.3.6 Release notes

### Bugfixes

* Destroy `ServerFile` objects in topological order to avoid dereferencing
  dangling pointers during destruction of `sync::Server` objects.
* Delete Realm files corresponding to partial views when the reference file is
  deleted on the server. This avoids a server crash when connecting to a partial
  view after the reference file is deleted.

-----------

### Internals

* Add unit test `Sync_Partial_DeleteServerSideRealmFile`.

----------------------------------------------


# 2.3.5 Release notes

### Public

* Upgrade the Core dependency to 5.2.0. This also includes the new query parser
  in Core, which means that most of the restrictions on query features available
  in Partial Sync have now been lifted.

### Enhancements

* Expose star topology config parameters to ROS.

-----------

### Internals

* Chomp loaded access token in test client (i.e., remove the final newline
  character if it is present).

----------------------------------------------


# 2.3.4 Release notes

### Bugfixes

* Prevent `sync::BadChangesetError` from being thrown by the server's event loop
  (which crashes the server) when a bad changeset is received from a client.
* Use a file identifier with value 1 (root node) for generating object
  identifiers on a subtier server node until the true file identifier is
  assigned. Previously, this was 0 or 1 depending on timing.

### Enhancements

* The `sync::Server` object now allows for external modifications of the Realm
  files managed by it via separate `SharedGroup` instances. However, the server
  needs to be notified about such changes, which done by the new function
  `sync::Server::recognize_external_change()`. There is also a new function,
  `sync::Server::map_virtual_to_real_path()`, that is needed to map virtual
  paths to realm file system paths to the Realm files managed by the server.

-----------

### Internals

* New unit tests `Sync_ServerSideModify_Randomize` and
  `Sync_Multiserver_ServerSideModify`.
* Make `test_util::compare_groups()` be descriptive about how the groups differ.

----------------------------------------------


# 2.3.3 Release notes

### Bugfixes

* Fixed bug in `ServerHistory::ensure_upstream_file_ident()`.

----------------------------------------------


# 2.3.2 Release notes

### Enhancements

* Support added for changes of local origin on a subtier server of a star
  topology server cluster.

----------------------------------------------


# 2.3.1 Release notes

### Enhancements

* The sync server can now act as a client towards an upstream server (star
  topology server cluster). See `doc/multiserver_sync.md` for details.

----------------------------------------------


# 2.3.0 Release notes

### Public

* Default value of the `max_download_size` configuration parameter was changed
  to 16 MiB (up from 128 KiB). This should drastically reduce initial download
  times in Realms with long transaction histories.

### Bugfixes

* Longstanding bug in `_impl::ServerHistory::verify()` was fixed. The bug was
  introduced as part of the rollout of core-level support for chunked binary
  data.

### Breaking changes

* Enumeration `sync::Server::Config::OperatingMode` was renamed to
  `sync::Server::BackupMode`, and the enumeration value `MasterWithNoSlave` was
  renamed to `Disabled`.
* Configuration parameter `operating_mode` in `realm::config::Configuration` was
  renamed to `backup_mode`.
* Reconnect modes `never` and `immediate` in enumeration
  `sync::Client::ReconnectMode` have been replaced by a single new "fused"
  testing mode called `testing`.
* Client error `bad_file_ident_pair` renamed to `bad_client_file_ident` in
  `sync::Client::Error` enumeration.
* The sync protocol version was bumped to 23. The server maintains the ability
  to service clients that use earlier versions of the protocol. If clients are
  upgraded to use this version of Realm sync, the server must be upgraded too.
* Member `latest_server_session_ident` of `sync::SyncProgress` renamed to
  `latest_server_version_salt`. The actual meaning is unchanged. The new name
  better reflects what it really is.
* Backup protocol version bumped to 2. No compatibility with earlier versions of
  the backup protocol is provided.
* History schema format for server-side Realm files bumped to version 4. This
  means that after the server has been upgraded, it cannot be downgraded again
  without restoring state from backup.
* Various changes to `sync::TransformHistory`. Most notably, the superfluous
  `not_from_remote_client_file_ident` argument was removed from several of its
  methods.
* Signature of `sync::make_transformer()` and
  `sync::Transformer::transform_remote_changesets()` have changed. The
  `local_file_ident` argument was moved from `make_transformer()` to
  `transform_remote_changesets()`.
* Method `report_merges()` in `sync::Transformer::Reporter` renamed to
  `on_changesets_merged()`.
* Member `origin_client_file_ident` renamed to `origin_file_ident` in classes
  `sync::HistoryEntry`, `sync::Transformer::RemoteChangeset`,
  `sync::ClientHistoryBase::UploadChangeset`, and `sync::Changeset`.
* Method `integrate_remote_changesets()` of `sync::ClientHistoryBase` was
  replaced with `integrate_server_changesets()`, which has a slightly different
  signature. The new method no longer throws on invalid changesets. Instead it
  reports errors using error code enumeration
  `sync::ClientHistoryBase::IntegrationError`.
* Class `sync::SyncProgress` was moved into `sync::ClientHistoryBase` and its
  members have now been recast in terms of the structures `SaltedFileIdent`,
  `SaltedVersion`, `DownloadCursor`, and `UploadCursor`.
* Memebers `client_version` and `server_version` of class
  `sync::ClientHistoryBase::UploadChangeset` were merged into a new `progress`
  memeber of type `UploadCursor`.
* Basic protocol integer types `version_type`, `file_ident_type`, `salt_type`,
  and `timestamp_type` are now defined in the `realm::sync` namespace by public
  header file `<realm/sync/protocol.hpp>`. This means that they are no longer
  available as members of classes such as `sync::HistoryEntry`,
  `sync::TransformHistory`, `sync::Transformer`, `sync::ClientHistory`, and
  `sync::Session`.

### Enhancements

* Full support for session specific ERROR messages in the sync protocol. In
  particular, the connection is no longer closed when one session fails, and
  there are other sessions on the same connection.
* The sync client now keeps connections open for a while (a linger time) after
  all sessions have been abandoned (or suspended by error).
* New `connection_linger_time_ms` option added to `sync::Client::Config`.
* The obsolete concept of a "server file identifier" has been removed from the
  sync protocol.
* Added support in the sync protocol for relayed subtier client file identifier
  allocation. For this purpose, the message that was formerly known as ALLOC was
  renamed to IDENT, and a new ALLOC message was added in both directions.
* The UPLOAD message of the sync protocol now has the capacity to specify
  individual origin client file identifiers for each uploaded changeset.
* The DOWNLOAD message of the sync protocol now carries an additional `<upload
  server version>` parameter.
* Added new sync protocol error codes 215 "Unsupported session-level feature"
  and 216 "Bad origin file identifier (UPLOAD)".
  and 216 "Bad origin client file identifier (UPLOAD)".
* Server-side (root node only) support for relayed client file identifier
  allocation in star topology server cluster.
* Server-side (root node only) support for UPLOAD messages with varying origin
  file identifiers.
* Server now takes the proxy file information into account when deciding what
  changesets should be downloaded to each client. This completes the server-side
  (root node) support for star topology server clusters.

-----------

### Internals

* Change to Sync_TokenWithoutExpirationAllowed test.
* Changesets of local origin now have `HistoryEntry::origin_file_ident == 0` on
  the server side. This brings the server into alignment with the client in that
  regard. This change could be made without migration, because the ability for
  the server to be the originator of new changesets has so far never been used
  in practice (partial sync does not count in this context).
  in preactice (partial sync does not count in this context).
* History entries on the server side now specify the client file identifier
  directly. Before, they specified the client file identifier minus one.
* Upstream client sync status added to server-side history schema.

----------------------------------------------


# 2.2.16 Release notes

### Public

* None.

### Bugfixes

* Prevent `sync::BadChangesetError` from being thrown by the server's event loop
  (which crashes the server) when a bad changeset is received from a client
  (backported from 2.3.4).

### Breaking changes

* None.

### Enhancements

* Additional error logging when the server encounters an uploaded Bad Changeset.
* get_lsof_output() function in src/realm/noinst.
* The sync server gets a log_lsof_period configuration parameter. The output from
  lsof for the server process is logged periodically with the configure period.
* The server logs lsof output when accept() fails due to lack of file descriptors.
* Add the log_lsof_period to the server configuration and command line
  executable server.
* Added an error callback to the node sync server that is called when the sync
  server throws an OutOfFilesError exception.

-----------

### Internals

* Unit test for Bad Changeset.

----------------------------------------------


# 2.2.15 Release notes

### Bugfixes

* Fixed race condition in handling of session bootstrapping in `client.cpp`.

----------------------------------------------


# 2.2.14 Release notes

### Bugfixes

* Added REALM_INCLUDE_CERTS to the build definitions for Windows in
  CMakeLists.txt. This fixes handling of SSL certificates for the sync client
  on Windows.

----------------------------------------------


# 2.2.13 Release notes

### Public

* Server::Config::authorization_header_name.
* Client side Session::Config::authorization_header_name.
* Client side Session::Config::custom_http_headers.
* Added authorizationHeaderName to the node.js sync server configuration.

-----------

### Internals

* Unit test for server config authorization_header_name.
* Unit test for client config authorization_header_name.

----------------------------------------------


# 2.2.12 Release notes

### Bugfixes

* A use-after-free bug was fixed which could cause arrays of primitives to
  behave unexpectedly. Specifically, the pattern employed by the data connector
  triggered unexpected behavior.

----------------------------------------------


# 2.2.11 Release notes

### Internals

* Unit test for included SSL root certificates
  extended to multiple servers.
* Introduce a logger in the ssl::Stream class.
* Implement root certificate checking using the
  OpenSSL verify_callback function.

----------------------------------------------


# 2.2.10 Release notes

### Public

* For OpenSSL, the sync client includes a fixed list of certificates in its
  SSL certificate verification besides the default trust store in the case
  where the user is not specifying its own trust certificates or callback.

### Enhancements

* Include a list of SSL root certificates in a header file.

-----------

### Internals

* Unit test for SSL connection to the Realm cloud.
* A function `Context::use_included_certificates()` in
  `src/realm/util/network_ssl.cpp` that includes a list of certificates from
  a header file in a SSL context.
* REALM_INCLUDE_CERTS variable to denote inclusion of SSL certificates in the
  client binary.

----------------------------------------------


# 2.2.9 Release notes

### Public

* Bumped Core dependency to 5.1.2.

----------------------------------------------


# 2.2.8 Release notes

### Internals

* Base-64 utility (`<realm/util/base64.hpp>`) moved to the Realm core
  repository.

----------------------------------------------


# 2.2.7 Release notes

### Bugfixes

* Removing the special case for class_ prefixes in ContainerInsert.
  Old Realms with invalid changesets must be migrated.

-----------

### Internals

* None.

----------------------------------------------


# 2.2.6 Release notes

### Bugfixes

* Avoiding double "class_" prefix in ContainerInsert
  for old Realms.

-----------

### Internals

*  Unit tests for double CreateObject instructions and issue 1895.
*  librealm-parser included in osx release

----------------------------------------------


# 2.2.5 Release notes

### Bugfixes

* Fixed race condition (and data races) in handling of session bootstrapping in
  `client.cpp`. This bug was exposed by running `Sync_MultipleServers` a large
  number of timers.

----------------------------------------------


# 2.2.4 Release notes

### Public

* None.

### Bugfixes

* None.

### Breaking changes

* None.

### Enhancements

* A new per-sync session "connection state change listener" has been introduced
  (`sync::Session::set_connection_state_change_listener()`). This deprecates the
  per-sync session "error handler" (`sync::Session::set_error_handler()`). The
  two cannot be used concurrently for a single session (installing one will
  replace the other). While the error handler is invoked only when the
  connection is lost, the new listener is invoked whenever the state of the
  connection changes between being "disconnected", "connecting", and
  "connected". The conditions under which the error handler is invoked, and
  those under which the listener is invoked with a state argument of
  `sync::Sesssion::ConnectionState::disconnected`, are precisely the same.

-----------

### Internals

* A new function execution triggering mechanism (class `Trigger`) has been added
  to the networking event loop library (`util::network`). Its main purpose is to
  allow for the execution of a function to be triggered in a way that is both
  thread-safe and nonthrowing. The triggered function will still be executed by
  the event loop thread, and may itself throw exceptions. This new triggering
  mechanism is similar in spirit to the "async handle" mechanism of libuv.
* The new "function execution triggering mechanism" was used to simplify
  `client.cpp`.

----------------------------------------------


# 2.2.3 Release notes

### Bugfixes

* Include core parser lib in cocoa build

----------------------------------------------

# 2.2.2 Release notes

### Bugfixes

* Include chunked_binary.hpp in installation.

----------------------------------------------

# 2.2.1 Release notes

### Public

* Bumped Core dependency to 5.0.1.

### Bugfixes

* For inward partial sync, the changeset added to the reference Realm
  is generated by the replicator during application. This ensures that
  missing nullify link instructions are included.
* Primary key objects created by a client that starts a subscription
  in the same transaction are handled correctly.
* Fix race condition in wait_for_session_terminations_or_client_stopped.
* Fix memory leak for callback in RealmServer::start() and RealmServer::stop()
  in js_realm_server.cpp. This bug was found by cppcheck.
* Fix ccpcheck error in server_history.cpp by initializing copied_bytes.
  The cppcheck error is strictly speaking a false positive, but it is not a
  problem to initialize the integer to 0.

### Breaking changes

* Virtual member functions `get_logger()` and `get_random()` renamed to
  `websocket_get_logger()` and `websocket_get_random()` respectively in
  `<realm/util/websocket.hpp>` (to avoid conflicts with nonvirtual member
  functions in derived classes), and both are now declared `noexcept`.
* Superfluous type `port_type` removed from `sync::Client` class. Use
  `sync::Session::port_type` instead.
* Previously deprecated `sync::ClientHistory::find_history_entry_for_upload()`
  has now been removed.
* Signature of `sync::ClientHistory::integrate_remote_changesets()` has
  changed. The type of the transaction notification callback is now
  `sync::ClientHistory::SyncTransactReporter*`.
* Signature of `util::network::ssl::Stream::use_verify_callback()` has
  changed. The type of the callback function argument is now `const
  std::function<util::network::ssl::Stream::SSLVerifyCallback>&`.

### Enhancements

* Parsing of partial sync queries is now handled by core's query parser.

-----------

### Internals

* All non-class tables are now actively ignored by sync. This means that a
  client can freely create and populate tables with names not beginning with the
  string `class_` and expect them to remain local and private.
* A unit test to illustrate that substring operations
  do not have higher order convergence.
* A sync::ObjectIDSet class is added.
* The sync client code has been refactored into two layers. The lower layer
  (i.e., the single-threaded protocol logic) is now presented via
  `<realm/noinst/client_impl_base.hpp>`. The higher layer remains in
  `realm/sync/client.cpp`. The purpose of the split is to allow for the lower
  layer to be used in a 2nd tier server of a star topology server cluster.
* Unit test to verify that it is possible to destroy a session inside the
  progress handler without deadlocking.

----------------------------------------------

# 2.1.10 Release notes

### Bugfixes

* HTTP responses 502, 503 and 504 are not considered fatal any more,
  this fixes the long reconnection that happens when a proxy in front
  of the sync worker returns one of those.

----------------------------------------------


# 2.1.8 Release notes

### Enhancements

* The `realm-backup` binary is now statically linked with libcrypto.
  This removes the burden of installing libcrypto from the user.

-----------

### Internals

* Introducing a function that explicitly initializes the schema in
  a new partial Realm. The use of the schema initialization function
  avoids a potentially long history traversal.
* Unit test for partial sync that checks that the partial tables are emptied when
  all queries are removed.
* A bench mark for partial sync performance.
* A markdown report describing the performance of partial sync and compares it to
  sync.

----------------------------------------------


# 2.1.7 Release notes

### Bugfixes

* Fix an issue where log compaction would cause deleted-then-recreated objects
  with identical primary keys to become empty (#1831).
* Outward partial sync is changed to ensure convergence of partial sync in the
  case where the client creates a primary key object, that is already present on
  the server, and subscribes to it in the same transaction.

-----------

### Internals

* Unit test for partial sync leading to divergence; a client creates a primary
  key object that also exists in the reference Realm and adds a query that
  includes the object.
* Remove the continuous backup because it has been superseded by the
  synchronous backup.

----------------------------------------------


# 2.1.6 Release notes

### Public

* None.

### Bugfixes

* Add clamped_hex_dump.hpp to CMakeLists.
* Make sure `realm-backup` is bundled with the `realm-sync-server` npm package.

### Breaking changes

* None.

### Enhancements

* None.

-----------

### Internals

* A unit test illustrating that our merge rules do not
  have higher order convergence. In other words, a "natural"
  peer to peer system would not work with our current rules
  without calculating diff corrections to the states. The
  test employs one move_last_over and two link_list_set
  instructions to illustrate the principle.

----------------------------------------------


# 2.1.5 Release notes

### Public

* None.

### Bugfixes

* Cooked changesets over 16MB in size are now correctly returned by
  `ClientHistory::get_cooked_changeset`.

### Breaking changes

* None.

### Enhancements

* Clamp size of hex dumps in log to 1024 raw bytes per dump.

-----------

### Internals

* None.

----------------------------------------------


# 2.1.4 Release notes

### Public

* None.

### Bugfixes

* Creating an object with the null string primary key would generate an
  instruction that created an object with the empty string as the primary key
  instead.

### Breaking changes

* None.

### Enhancements

* None.

-----------

### Internals

* None.

----------------------------------------------


# 2.1.2 Release notes

### Public

* None.

### Bugfixes

* Do not fail "migration from legacy file format" when there is no `metadata`
  table.

### Breaking changes

* None.

### Enhancements

* None.

-----------

### Internals

* None.

----------------------------------------------


# 2.1.1 Release notes

### Public

* None.

### Bugfixes

* Fixed a minor issue with the config option in the ServerImpl::start()
  function.
* Made the link_target_table in ContainerInsert and ContainerSet use selected
  link target table in log compaction. This problem is due to an inconsistent
  use of the "class_" prefix in the protocol.
* A line in InstructionReplication::link_list_insert is removed.  This line set
  the link_target_table to the value with a class_ prefix.

### Breaking changes

* None.

### Enhancements

* Introduce a parameter Server::Config::max_download_size that sets the size of
  the batches of changesets that are used in the download messages.
* The server logs the log level at start up.
* The server logs the max download size at start up.
* Added the maxDownloadSize config option to the node sync server.

-----------

### Internals

* Remove all compiler warnings for clang on mac.
* Remove unnecessary -lcrypto flags.
* A unit test for link list insert and link list set in connection with log
  compaction.


----------------------------------------------


# 2.1.0 Release notes

### Public

* None.

### Bugfixes

* The client accepts an ALLOC message even if it is enlisted to send a REFRESH
  message.
* The client send_refresh_message() only enlists to send again if the session
  has a file ident pair.
* The server accepts a REFRESH message for an unactivated session.
* Fix a crash that could occur when starting a sync server using the
  realm-sync-server node package.

### Breaking changes

* Moved the /info endpoint to /api/info and it now requires an admin user to
  access it. In practice, this change is not breaking since /info is not used.

### Enhancements

* For a client attempting to perform partial sync on a server that does not
  have partial sync enabled, replace the exception with an error message.
* An /api/ok endpoint that always replies 200 OK. It can be used for health
  checks on the sync server.
* Deletion of empty parent directories when a Realm is deleted.

-----------

### Internals

* Unit test for token refresh right after session bind.
* The description of the session state transitions in client.cpp is updated to
  include the REFRESH message.
* Refactor the receive_bind_message() on the server to check validity of the
  virtual path without throwing exceptions. Check the path for partial sync
   early.
* Unit test for client attempting partial sync with a backup enabled server.
* Unit test triggering the "illegal realm path" error on the server.
* Unit tests for the /api HTTP end points.
* Improved the unit test for Realm deletion to include various Authorization
  headers.
* Unit test for Realm deletion of parent directories.

----------------------------------------------


# 2.0.2 Release notes

### Public

* None.

### Bugfixes

* None.

### Breaking changes

* Feature tokens now gate sync labels in user tokens, preventing
  from using non-default sync labels without the proper feature token.
  The feature token should contain `LoadBalancing` key for that.

### Enhancements

* None.

-----------

### Internals

* None.

----------------------------------------------


# 2.0.1 Release notes

### Public

* None.

### Bugfixes

* Fixed a client crash caused by attempting to reconnect while a reconnect
  delay is in progress. This would happen on `override_server()`.

### Breaking changes

* None.

### Enhancements

* None.

-----------

### Internals

* None.

----------------------------------------------


# 2.0.0 Release notes

### Public

* Update Core dependency to version 4.0.2.
* Windows support has been added to both server and client.
* The server attempts to reduce the size of DOWNLOAD messages by running an
  optimistic log compaction algorithm. The algorithm tries to look for
  instructions that are made redundant by later instructions, and discards them.
* Arrays of primitives are now syncable.
* Many log messages on the client side have had their severity reduced from
  `info` to `detail` or `debug`. This reduces the output of the Realm Object
  Server in a default setup.
* Gauge metrics are now reported as absolute values instead of relative. This
  includes metrics such as number of open connections, which will now be
  reported as absolute values, giving a better picture when reading the metrics.
* Added experimental support for query-based partial synchronization (see
  [`/doc/partial_sync.md`](doc/partial_sync.md) for more details).
* When downloading multiple changesets from the server, the merge algorithm is
  run across all available changesets, yielding O(n log n) performance instead
  of O(n*n).
* A schema mismatch detected by the merge algorithm will now output a more
  readable message in the server and client logs.

### Bugfixes

* Client side sync history is now properly trimmed (no longer growing
  indefinitely) for read-only clients and clients that only rarely make changes
  of their own (test case `Sync_ReadOnlyClientSideHistoryTrim`).
* The merge rule for ContainerSwap vs. ContainerMove (used in linklists and
  arrays of primitives) was wrong, and has been fixed. This problem was
  originally found by AFL.
* Case insensitive verification of the "Connection" and  "Upgrade"
  WebSocket HTTP headers.
* Add log level to the node sync server config and pass it through
  to the sync server.
* Fixing race condition in unit tests "migrations" in
  src/node/sync-server/src/index.spec.ts.
* The server returned status 404 instead of 400 on bad request.
* Two clients adding the same table with different primary key columns now
  causes an error to be reported in the log.
* Uninitialized value in class ServerFile.

### Breaking changes

* Sync protocol version bumped to 22.
* Bump history file format to prevent opening new files with old incompatible
  versions of Realm.
* Changed the structure of the HTTP request for the WebSocket handshake that
  starts a sync session:
  * Changed `X-Realm-Access-Token` to `Authorization`.
  * `Authorization: Realm-Access-Token version=1 token="${signed_user_token}"`
  * Removed `X-Realm-Path`.
  * Changed the URL to "/realm-sync" + "/" + URL_encoded(realm-path).
  * The prefix "/realm-sync" is configurable in the client `Session::Config`.
* The UPLOAD message is enhanced to deliver multiple changesets.
* The UPLOAD message is zlib compressed.
* Instructions within changesets refer to tables without the `class_` prefix, as
  per the Object Store convention. Tables without the prefix are no longer
  supported.
* The properties featureToken and enableDownloadLogCompaction are added to the
  configuration of the node-sync-server.
* Changed the format of HTTP auth header for the backup connection, it is now
  like:
    `Authorization: Realm-Backup version=1 id="${slave_id}" secret="${secret}"`
* Change of HTTP header from `X-Realm-Protocol-Version` to
  `Sec-WebSocket-Protocol`.
* Change of HTTP header from `X-Realm-Backup-Protocol-Version` to
  `Sec-WebSocket-Protocol`.
* Change of HTTP header from `X-Realm-Master-Slave-Shared-Secret` to
  `Authorization`.
* Member `clock` renamed to `token_expiration_clock` in `sync::Server::Config`,
  and type `Clock` renamed to `TokenExpirationClock` in `sync::Server`.
  Finally, `TokenExpirationClock::now()` is now declared `noexcept`.
* Feature tokens added to gate backup for the sync server.
* Error code for timout on reception of PONG message moved from protocol errors
  enum (`ProtocolError::pong_timeout`) to client errors enum
  (`Client::Error::pong_timeout`) where it belongs. The protocol errors enum is
  only for errors reported by the server.
* Unused error code `ProtocolError::malformed_http_request` removed from
  protocol errors enum (was never generated).

### Enhancements

* The sync worker's log output is now much less chatty by default, as log
  messages indicating normal functioning of the server and of no immediate
  interest to an end-user have been downgraded to the "detail" loglevel.
* Add a `tcp_no_delay` option to sync client and server, as well as to backup
  client and server. This option will disable the Nagle algorithm on TCP/IP
  sockets. In some cases, this can be used to decrease latencies, but possibly
  at the expense of scalability. Be sure to research the subject before you
  enable them.
* Added an `override_server` method to the Session, which allows to change
  the server endpoint without destroying the session. It causes a reconnection.
* The server now has an `id` field, which can be provided in config file or
  config object.
* Client::Config::enable_upload_log_compaction parameter added.
* Log compaction is performed per changeset for the UPLOAD message (configurable
  with the configuration parameter
  `Client::Config::enable_upload_log_compaction`).
* `detach()` added to `sync::Session`, whose function is to initiate termination
  of the session and to detach the session object from the client
  object. `detach()` is called implicitly from the destructor.
* Allow for a `sync::Session` object to be created in detached state (default
  constructor).
* `wait_for_upload_complete_or_client_stopped()` and
  `wait_for_download_complete_or_client_stopped()` in `sync::Session` now return
  true if the wait operation was not terminated by the exit of the event loop.
* `wait_for_session_terminations_or_client_stopped()` added to
  `sync::Client`. It allows the application (object store) to wait until no
  session specific callback functions can be executing any longer for any
  session whose termination was already initiated.
* "Realm deletion" removes the `.lock` file and the `.management` directory.
* The sync worker now reports additional stats: changeset integration, download
  message construction and ping rtt.
* Additional logging in the Sync server when it receives an invalid WebSocket
  request. The extra logging should help users that have set up a WebSocket
  proxy with a configuration that violates the protocol.
* The `Client::Config` is enhanced to take a ssl verify callback argument. The
  callback function can be used to verify certificates using external means such
  as Android APIs in Java.

-----------

### Internals

* Enable `tcp_no_delay` option on sync client and server, as well as to backup
  client and server during unit testing. On Linux, this causes a massive speedup
  during execution of the test suite, and leads to a much improved CPU
  utilization.
* Client-side logging has been reduced by downgrading the severity of DNS
  resolution and file cache messages from 'info' to 'detail'.
* The manual backup had been improved and made ready for ROS 2.0.
* More unit testing of the manual backup.
* Artifacts for Android are now compiled with `-O1` instead of `-Os` in order
  sidestep what appears to be an optimizer bug on GCC 4.9.
* CI now builds and packages for Windows and UWP.
* Unit tests for log levels in the node sync server.
* The backup master is now tracking the up-to-dateness of the slave.  The slave
  state is reported through a callback, which is configurable in the server
  config structure and in the node wrapper.
* Unit test Backup_Synchronous_SlaveCatchUp captures the case where the server
  Realm is created before the backup slave connects.
* In class ServerFile, async_integrate_changeset takes a vector of
  changesets and a start index as arguments. This version of
  async_integrate_changeset replaces the previous single changeset version.
* Unit test for upload message batching
* Unit tests for upload log compaction enabled and disabled, respectively.
* Unit test that exercises an object removal followed by clear table.
* Reduced memory consumption in unit test Sync_MergeLargeBinary and
  introduction of new unit test Sync_MergeLargeBinaryReducedMemory.
* Make it such that if exceptions are thrown from client or server event loops
  in `ClientServerFixture` in `test/test_sync.cpp`, then the exception type and
  message is logged immediately.
* Added URI encode and decode functions in realm::util.
* Updated the unit test Sync_RealmDeletion and the handling of receipt of a
  Realm Deletion request.
* Config variable REALM_EXCLUDE_FEATURE_TOKENS added.
* Unit tests for feature gating.
* New unit test for "Realm deletion".
* WebSocket code handles Sec-WebSocket-Protocol as a special header.
* Improve ASAN and TSAN build modes (`sh build.sh asan` and `sh build.sh tsan`)
  such that they do not clobber the files produced during regular builds, and
  also do not clobber each others files. Also `UNITTEST_THREADS` and
  `UNITTEST_PROGRESS` options are no longer hardcoded in ASAN and TSAN build
  modes.
* More unit tests for the verification of SSL certificates.
* Compat test now dumps the log in case it fails.
* A recent change in the test client made it such that invalid command line
  option values were silently ignored. This has now been fixed. Additional
  details are now also provided in such cases.
* The immediate call of the progress handler is posted to the event
  loop to avoid calling the progress handler under a `Client::m_mutex` lock.
  This avoids a dead lock in the case where the progress handler creates new
  sessions.
* Disable the check for premature_end_of_input in the test
  Util_Network_SSL_PrematureEndOfInputOnHandshakeRead on Mac OS.
* Additional error codes for the WebSocket request.


----------------------------------------------


# 1.10.9 Release notes

### Public

* None.

### Bugfixes

* None.

### Breaking changes

* None.

### Enhancements

* None.

-----------

### Internals

* Jenkinsfile checkout scm changed to clone the tags.
* Bump required core version to 2.9.2.

----------------------------------------------

# 1.10.6 Release notes

### Public

* None.

### Bugfixes

* Fixed the server crash caused by a segfault when client reconnected after
  sending conflicting changesets.

### Breaking changes

* A new error code Client::Error::ssl_server_cert_rejected is added.
  If the client SSL handshake fails, the client error callback will
  be called with either Client::Error::ssl_servercert_rejected or with
  an underlying implementation defined error code.

### Enhancements

* The sync worker now reports additional stats: changeset integration, download
  message construction and ping rtt.

-----------

### Internals

* OpenSSL and secure transport error categories are moved to the
  realm::util::network::ssl level.
* A realm::util::network::ssl error condition is added.
* Expose `realm::sync::set_feature_token` and `realm::sync::is_feature_enabled`
  API to allow bindings to validate feature tokens.


----------------------------------------------


# 1.10.5 Release notes

### Public

* None.

### Bugfixes

* None.

### Breaking changes

* None.

### Enhancements

* None.

-----------

### Internals

* Dependency in Jenkins file.

----------------------------------------------


# 1.10.4 Release notes

### Public

* None.

### Bugfixes

* None.

### Breaking changes

* None.

### Enhancements

* None.

-----------

### Internals

* Bump required core version to 2.8.6.

----------------------------------------------


# 1.10.3 Release notes

### Public

* None.

### Bugfixes

* Fix the release Dockerfile.

### Breaking changes

* None.

### Enhancements

* None.

-----------

### Internals

* None.

----------------------------------------------


# 1.10.2 Release notes

### Public

* None.

### Bugfixes

* None.

### Breaking changes

* All SSL configuration is moved to Session::Config.

### Enhancements

* A multiplex identifier is introduced in Session::Config
  that allows the user to force sessions to be carried by
  distinct TCP/SSL connections.
* SSL certificate verification is controlled at the
  session level.
* The Websocket header "Connection: upgrade" is now
  accepted alongside the standard "Connection: Upgrade"
  header. This is done to avoid closing of the Sync
  connection in case of a proxy that is configured with
  "Connection: upgrade".

-----------

### Internals

* A session is given all needed information in the constructor.
  A Session::bind() method without arguments is introduced.
  The previous versions of Session::bind() remain as convenience
  functions.
* Fix of some unit tests.
* New unit tests for SSL and session multiplexing.
* Bump required core version from 2.8.4 to 2.8.5.
* Make `sh build.sh build-node-sync-worker` and `sh build.sh
  build-node-sync-server` work on Linux by not using non-POSIX `pushd`/`popd`
  commands in `build.sh`.
* realm-sync-server NodeJS module is now built for NodeJS 8

----------------------------------------------


# 1.10.1 Release notes

### Public

* Additional logging in the Sync server when it receives an invalid WebSocket
  request. The extra logging should help users that have set up a WebSocket
  proxy with a configuration that violates the protocol.

### Bugfixes

* m_prev_session_ident protected by m_mutex.
* Thread safety in Sync_ServerDropsIdleConnections unit test.
* Fix order of destruction of condition variable and Fixture in
  Sync_UploadDownloadProgress_5 unit test.
* In the test Sync_UploadDownloadProgress_1 make some variables atomic, move
  the definition of a condition variable and change some checks to reflect that
  the immediate progress callback happens after bind().

### Breaking changes

* None.

### Enhancements

* The Client::Config is enhanced to take a ssl verify callback
  argument. The callback function can be used to verify certificates
  using external means such as Android APIs in Java.
* Improve ASAN and TSAN build modes (`sh build.sh asan` and `sh build.sh tsan`)
  such that they do not clobber the files produced during regular builds, and
  also do not clobber each others files. Also `UNITTEST_THREADS` and
  `UNITTEST_PROGRESS` options are no longer hardcoded in ASAN and TSAN build
  modes.

-----------

### Internals

* More unit tests for the verification of SSL certificates.
* Compat test now dumps the log in case it fails.
* A recent change in the test client made it such that invalid command line
  option values were silently ignored. This has now been fixed. Additional
  details are now also provided in such cases.
* The immediate call of the progress handler is posted to the event
  loop to avoid calling the progress handler under a client::m_mutex lock.
  This avoids a dead lock in the case where the progress handler creates new
  sessions.
* Disable the check for premature_end_of_input in the test
  Util_Network_SSL_PrematureEndOfInputOnHandshakeRead on Mac OS.
* Additional error codes for the WebSocket request.

----------------------------------------------


# 1.10.0 Release notes

### Public

* None.

### Bugfixes

* Do not crash when send_next_message() is called while the client is sending a ping.
* Prevent application thread from accessing session state (SessionImpl::m_file)
  that is private to the clients event loop thread.

### Breaking changes

* First callback of upload/download progress is postponed till after bind().

### Enhancements

* None.

-----------

### Internals

* None.

----------------------------------------------


# 1.9.2 Release notes

### Public

* Uses core 2.8.1

### Bugfixes

* None.

### Breaking changes

* None.

### Enhancements

* None.

-----------

### Internals

* None.

----------------------------------------------


# 1.9.1 Release notes

### Public

* Use core 2.8.0.

### Bugfixes

* sum_of_history_entry_size() uses ChunkedBinaryData.

### Breaking changes

* None.

### Enhancements

* None.

-----------

### Internals

* None.

----------------------------------------------


# 1.9.0 Release notes

### Public

* Use core 2.7.0.

### Bugfixes

* When an empty string is passed as `signed_uder_token` to
  `sync::Session::bind()`, behave the same was as if any other invalid signed
  user token was passed. Don't crash.

### Breaking changes

* None.

### Enhancements

* None.

### Breaking changes

* The progress handler for upload/download progress is given an extra argument
  `snapshot_version`.
* The protocol is changed such that <session ident> is enlarged to a maximum of 63 bits.
* The protocol version is bumped to version 18.

### Enhancements

* A disconnected client session can use the logger.
* Logging of the upload/download progress calls.

-----------

### Internals

* None.

----------------------------------------------

# 1.8.3 Release notes

### Public

* None.

### Bugfixes

* Link backup, backup-server & backup-client statically.

### Breaking changes

* None.

### Enhancements

* None.

-----------

### Internals

* Add config variables `REALM_CORE_LDFLAGS` and `REALM_CORE_DEBUG_LDFLAGS`.

----------------------------------------------

# 1.8.2 Release notes

### Public

* Uses realm-core 2.6.2.

### Bugfixes

* None.

### Breaking changes

* None.

### Enhancements

* None.

-----------

### Internals

* None.

----------------------------------------------


# 1.8.0 Release notes

### Public

* The dashboard finally has a "delete realm" button (a trash can) which
  triggers a chain of calls culminating in server-side realm file
  deletion and (hopefully) client resets. Dev use only.
  Depends on the vg-delete-realm branch of realm-sync, PR#1307.

### Bugfixes

* Fix a crash on ping after reconnection.

### Breaking changes

* None.

### Enhancements

* None.

-----------

### Internals

* Added `sync::Server::close_connections()` for debugging purposes.
* Changed the type of ServerImpl::m_files
* Changed the logic of get_virt_path_of_file().

----------------------------------------------


# 1.7.0 Release notes

### Public

* None.

### Bugfixes

* The 16MB limit for the size of a transaction is lifted.
* Use of REALM_FORCE_OPENSSL in the build system fixed.

### Breaking changes

* Client::Config has lost the two properties
  that relate to verifying a server's SSL certificate.
  The functionality has been moved to Session::bind().

### Enhancements

* Session::bind() has got two new parameters withe default values:
    verify_servers_ssl_certificate (default true)
    ssl_trust_certificate_path (default util::none)
  used to verify the server's SSL certificate.
* WebSocket code enhanced to start the framing part of the protocol without
  a handshake on the server.
* The sync server can accept any HTTP request after connection initiation. The
  sync server can route the incoming connections based on the HTTP request.
* The sync server now has a REST API (implements realm deletion)
* The sync server replies with a simple txt web page on /info.
* Sync workers now report protocol version usage to statsd.

-----------

### Internals

* A server file module that keeps track of conversion from virt_path to
  realm path and creates intermediate directories, gets a list of all
  server Realms, reads the content of a Realm, writes a new Realm,
  and removes a Realm.
* The server keeps track of all its Realm files in a std::set.
* SSL context is moved from Client level to Connecion level.
* Session that differ in SSL parameters but have the same server
  url will be assigned to distinct connections.

----------------------------------------------


# 1.6.0 Release notes

### Public

* None.

### Bugfixes

* Reciprocal histories are now trimmed on the server side. In cases with many
  clients, this will probably reduce the file size significantly.

### Breaking changes

* The format of server-side Realm files has changed due to the introduction of
  server-side Realm states. Old server-side Realm files need to be migrated to
  the new format. This will happen automatically during server startup.
* `sync::Server::init_directory_structure()` replaced by
  `sync::prepare_server_directory()`. This function now also handles migration
  of server-side files from the legacy format.

### Enhancements

* Realm states are now available on the server-side. This will allow it to run
  queries, which is a necessary feature for partial sync.
* Server now fully validates incoming changesets. The upside of that is that the
  server will no longer cause well behaving clients to crash by handing out
  corrupt changeset injected by malfunctioning clients.
* Support for server-side Realm modification, although if it happens via a
  separate `SharedGroup`, changes will not necessarily be picked up by server
  due to a lack of a notification mechanism.
* The server now performs stricter validation of UPLOAD.`<server version>`.
* Steps have been taken towards supporting history trimming (i.e., the removal
  of a prefix if the history).

-----------

### Internals

* The server now stores a *server version salt* in each history entry rather
  than in a "server sessions" table. This will cause a small relative
  enlargement of the file (+6 bytes per history entry). This change was
  necessary to support server-side Realm modification via separate `SharedGroup`
  objects.
* The server no longer cares about server file identifiers, because their role
  is completely superseded by the effect of client file identifier salts.
* The manual and continuous backup are changed to reflect the server side histories
  and the presence of migration directories.
* The backup is built by the general build system and not by Makefiles in
  the backup directories.

----------------------------------------------


# 1.5.3 Release notes

### Public

* Uses realm-core 2.6.1.

# 1.5.2 Release notes

### Public

* Uses realm-core 2.6.0.

### Bugfixes

* None.

### Breaking changes

* None.

### Enhancements

* None.

-----------

### Internals

* None.

----------------------------------------------


# 1.5.1 Release notes

### Public

* None.

### Bugfixes

* Fix a bug causing `Client::cancel_reconnect_delay()` to do nothing.

### Breaking changes

* None.

### Enhancements

* Fix a bug causing the client to never reconnect after disconnecting
  voluntarily between sessions in test suite.

-----------

### Internals

* None.

----------------------------------------------


# 1.5.0 Release notes

### Public

* Uses realm-core 2.5.1

### Bugfixes

* None.

### Breaking changes

* Class `SyncHistory` and function `make_sync_history()` in namespace
  `realm::sync` renamed to `ClientHistory` and `make_client_history()`
  respectively. This was done to avoid confusion between client sand server-side
  histories.

### Enhancements

* Stronger client-side validation of incoming DOWNLOAD messages (strictly
  increasing per-changeset server version, "weakly" increasing per-changeset
  last integrated client version).
* Close loophole where a corrupt changeset could make the client crash (due to
  uncaught `_impl::TransactLogParser::BadTransactLog` exception).
* New enum member `sync::Client::Error::bad_client_version` with meaning "Bad
  last integrated client version in changeset header (DOWNLOAD)".
* Until now, timestamps assigned to changes of local origin would be "warped" to
  ensure that they never preceded timestamps already in the history (was known
  as the *causal consistency* constraint). This turned out to not be necessary,
  and to also potentially have a negative impact on how well conflict
  resolutions match intuition. Hence, this is no longer done. Fortunately, this
  change can be rolled out without interfering with preexisting unmerged
  changes, as no preassigned timestamps will be changed.

-----------

### Internals

* Fix `Sync_UploadDownloadProgress_2` unit test.

----------------------------------------------

# 1.4.2 Release notes

### Public

* None.

### Bugfixes

* Fix linking manual backup on ubuntu.

### Breaking changes

* None.

### Enhancements

* A sync Session can now be opened with an encryption key for the local realm file.

-----------

### Internals

* None.

----------------------------------------------

# 1.4.1 Release notes

### Public

* None.

### Bugfixes

* NodeJS sync-server is now linked with openssl provided by NodeJS.  This
  ensures that the built NPM packages work on all linux variants.

### Breaking changes

* None.

### Enhancements

* None.

-----------

### Internals

* None.

----------------------------------------------


# 1.4.0 Release notes

### Public

* None.

### Bugfixes

* None.

### Breaking changes

* Added heartbeats, which are used for keeping connection alive and dropping
  idle connections. This also bumped the protocol version to 17.

### Enhancements

* Restructured the metrics which get sent to statsd.

-----------

### Internals

* The sync test client is now build part of the release process for
  Ubuntu 16.04 and uploaded to packagecloud.io

----------------------------------------------


# 1.3.2 Release notes

* * Uses core 2.4.0

# 1.3.1 Release notes

* * Uses core 2.3.3

# 1.3.0 Release notes

### Public

* None.

### Bugfixes

* None.

### Breaking changes

* None.

### Enhancements

* None.

-----------

### Internals

* None.

----------------------------------------------


# 1.3.2 Release notes

### Public

* Uses realm-core 2.4.0

### Bugfixes

* None.

### Breaking changes

* None.

### Enhancements

* None.

-----------

### Internals

* None.

----------------------------------------------


# 1.3.1 Release notes

### Public

* Uses core 2.3.3

### Bugfixes

* None.

### Breaking changes

* None.

### Enhancements

* None.

-----------

### Internals

* None.

----------------------------------------------


# 1.3.0 Release notes

### Public

* None.

### Bugfixes

* None.

### Breaking changes

* Type of `changeset_cooker` member of `sync::Client::Config`,
  `sync::Session::Config`, and `sync::SyncHistory::Config` changed from
  `sync::SyncHistory::ChangesetCooker*` to
  `std::shared_ptr<sync::SyncHistory::ChangesetCooker>`.

### Enhancements

* None.

-----------

### Internals

* None.

----------------------------------------------


# 1.2.1 Release notes

### Public

* None.

### Bugfixes

* Uses realm-core 2.3.2

### Breaking changes

* None.

### Enhancements

* None.

-----------

### Internals

* None.

----------------------------------------------


# 1.2.0 Release notes

### Public

* None.

### Bugfixes

* None.

### Breaking changes

* None.

### Enhancements

* The upload/download progress callback is given an extra parameter,
  the progress_marker which denotes whether there has been any server
  contact in the current session.
* The server always sends a DOWNLOAD message in the beginning of a session
  The DOWNLOAD message will update the client with progress information.

-----------

### Internals

* Added compatibility tests to the main Jenkinsfile.
* Fixed broken build system on Linux (was broken recently by
  https://github.com/realm/realm-sync/pull/1175).
* Fixed bug in `generic.mk` that would cause trouble when `LDFLAGS` for a
  convenience library contains commas (`,`).
* Fixed bug in `generic.mk`: Avoid removing duplicate words from `LDFLAGS` when
  linking against convenience libraries.
* Now building programs `realm-sync-worker`, `realm-backup-server`, and
  `realm-backup-client` with static linkage against `sync`, `server`, and
  `backup` libraries.

----------------------------------------------


# 1.1.0 Release notes

### Public

* According to the previous version of the API, the cooked changeset consumption
  progress (`sync::SyncHistory::CookedProgress`) was made up in part by a
  version field. This made no sense, as it was effectively a mere index into the
  total sequence of cooked changesets, and therefore had nothing to do with a
  version. This situation arose with the changes imposed by
  https://github.com/realm/realm-sync/pull/1104, which in turn arose due to a
  conceptual flaw in the initial solution. This necessitated several changes in
  the cooked changesets API: Member `version` renamed to `changeset_index` in
  `sync::SyncHistory::CookedProgress`. Member function
  `fetch_next_cooked_changeset()` replaced by member functions
  `get_num_cooked_changesets()` and `get_cooked_changeset()` in
  `sync::SyncHistory`.

### Bugfixes

* Make sure that the condition uploaded_bytes == uploadable_bytes and
  downloaded_bytes == downloadable_bytes can be consistently checked on
  Realms that were created before the introduction of the upload/download
  progress system.

### Breaking changes

* None.

### Enhancements

* The server now replies with ERROR 202 (token expired) to `BIND`/`REFRESH`
  messages with expired token. Previously it was ERROR 203 (bad auth).

-----------

### Internals

* Link core and sync statically into realm-sync-worker
* Moved realm-js-sync-server repo into realm-sync
* Link dogless statically into NPMs

----------------------------------------------


# 1.0.5 Release notes

### Public

* None.

### Bugfixes

* Fixed init script filename for realm-object-server-backup-client on centos 6

### Breaking changes

* None.

### Enhancements

* None.

-----------

### Internals

* None.

----------------------------------------------


# 1.0.4 Release notes

### Public

* Use real-core 2.3.1

### Bugfixes

* Data race in unit test fixed.

### Breaking changes

* None.

### Enhancements

* None.

-----------

### Internals

* Eliminate warning from unit test `JSONParser_Basic`.

----------------------------------------------


# 1.0.3 Release notes

### Public

* None.

### Bugfixes

* `sync::Session::refresh()` failed to send a REFRESH message immediately in the
  case where a connection to the server exists but the 'write' channnel of the
  session is idle.
* Eliminated data race and possible dereference of dangling pointer in
  `sync::Session::refresh()` (unsafe capture of `this` in
  `SessionImpl::refresh()` in `realm/sync/client.cpp`).

### Breaking changes

* None.

### Enhancements

* None.

-----------

### Internals

* OpenSSL updated to 1.0.2k.

----------------------------------------------


# 1.0.2 Release notes

### Public

* None.

### Bugfixes

* Do not prevent sending messages to sessions with expired token.
* Remove root_dir/tmp from manual backup.

### Breaking changes

* None.

### Enhancements

* None.

-----------

### Internals

* Upgraded the test-client to insert multiple
  blobs per transaction.

----------------------------------------------


# 1.0.1 Release notes

### Public

* Fix implicit conversion warning in protocol.hpp.
* Bugfix: Make the server skip sending messages to sessions with expired token.

### Bugfixes

* None.

### Breaking changes

* None.

### Enhancements

* None.

-----------

### Internals

* Manual backup has been changed to skip internal_data.
* Do not force `one_connection_per_session = true`, just default to `true`. This
enables a couple of token expiration tests which need it to be `false`.

----------------------------------------------


# 1.0.0-BETA-7.0 Release notes

### Enhancements

* None.

-----------

### Internals

* .gitignore for realm-sync-worker binary

----------------------------------------------


# 1.0.0 Release notes

### Public

* None.

### Bugfixes

* Remove the upload/download progress call happening
  right after session::bind().

### Breaking changes

* realm-server has been renamed to realm-sync-worker.

### Enhancements

* None.

-----------

### Internals

* update doc/protocol_16.md
* .gitignore for realm-sync-worker binary

----------------------------------------------


# 1.0.0-BETA-7.2 Release notes

### Public

* None.

### Bugfixes

* set_progress_handler posts to the event loop to avoid concurrent access to
  the file cache.

### Breaking changes

* None.

### Enhancements

* None.

-----------

### Internals

* None.

----------------------------------------------


# 1.0.0-BETA-7.1 Release notes

### Public

* None.

### Bugfixes

* Memory error in websocket.stop() from resetting the http_server object.

### Breaking changes

* None

### Enhancements

* None

-----------

### Internals

* None.

----------------------------------------------


# 1.0.0-BETA-7.0 Release notes

### Public

* None.

### Bugfixes

* Moved ssl reset above socket destruction in the client code to avoid
  use-after-free during ssl reset.

### Breaking changes

* None.

### Enhancements

* Upload and download progress.
* The upload/download progress handler is called immediately on registration.
* Protocol version 16. Downloadable bytes included in the DOWNLOAD message in
  order to support download progress.
* Protocol 16 sends the protocol version in the initial HTTP request from the
  client to the server. The CLIENT message is deprecated. The server still
  understands the CLIENT message in order to speak to old clients.
* The server speaks protocol 15 and 16, so protocol version 16 is not a
  breaking change.
-----------

### Internals

* Refactoring the Sync protocol into protocol.hpp and protocol.cpp.
* Improvements of memory handling in the Download message.

----------------------------------------------


# 1.0.0-BETA-6.5 Release notes

### Public

* None.

### Bugfixes

* Fixed: a new `connect` operation was sometimes scheduled from the `read`
  handler while an ongoing `write` operation was still there on the queue.

### Breaking changes

* None.


### Enhancements

* None.

-----------

### Internals

* Schema version and migration for server Realms.

----------------------------------------------


# 1.0.0-BETA-6.4 Release notes

### Public

* None.

### Bugfixes

* Use the same root path for server files on Linux as the ROS.

### Breaking changes

* None.

### Enhancements

* None.

-----------

### Internals

* None.

----------------------------------------------


# 1.0.0-BETA-6.3 Release notes

### Public

* None.

### Bugfixes

* None.

### Breaking changes

* None.

### Enhancements

* Package continous backup.

-----------

### Internals

* None.

----------------------------------------------


# 1.0.0-BETA-6.2 Release notes

### Public

* None.

### Bugfixes

* Tokens now actually expire if they have the expiration time set.
* WebSocket properly reset after failure during delivery of message.
* Fixed: Reconnect timer in `sync::Client` was not always scheduled due to
  `return` in place of `break`.
* The WebSocket callbacks functions are given a Boolean return value. The
  Boolean return value tells the WebSocket object whether it should continue
  processing messages. If the WebSocket object is destroyed during callback
  execution, the callback must return false. This change fixes a crash in the
  Sync_FailingReadsOnServerSide unit test, because that unit test destroys
  the WebSocket object during callback handling.

### Breaking changes

* Support for client-level error handler was removed
  (`sync::Client::set_error_handler()`). Now there are only session-level error
  handlers (`sync::Session::set_error_handler()`), and all errors are now
  reported via those.
* Sync session error handlers are now invoked for all errors that cause a
  session to become disconnected, or causes the establishment of a connection to
  fail. Previously, it was only called when a session was terminated due to an
  error reported by the server (by way of a sync protocol ERROR message).
* Signature changed for sync session error handlers. It changed from `void(int
  error_code, std::string)` to `void(std::error_code, bool is_fatal, const
  std::string&)`. This allows for different categories of errors to be reported
  (not just errors reported by the server). See `sync::Session` documentation
  for further details.
* ProtocolError::invalid_error removed.
* `sync::Client::errors_seen()` was removed. Applications will now have to
  register an error handler to know whether errors occur.
* An `std::error_code` argument was added to
  `util::websocket::Config::websocket_protocol_error_handler()`.
* `util::network::Resolver::resolve()` now returns the endpoint list (an object
  of type `util::network::Endpoint::List`) rather than updating the list that
  was passed as reference argument.
* Enumeration `sync::Client::Reconnect` renamed to
  `sync::Client::ReconnectMode`. Also, `ReconnectMode::never` was added. This is
  a debugging feature. See the documentation for details.

### Enhancements

* `sync::Client::cancel_reconnect_delay()` and
  `sync::Session::cancel_reconnect_delay()` were added. Call them to avoid
  excessive reconnect delays after the device/system regains network
  connectivity, and when an end-user explicitly asks for a retry. Be careful not
  to call them too often as that can degrade server hammering protection (see
  documentation fo details).
* New error enumeration `util::websocket::Error` was added, and a corresponding
  `std::error_category` was provided too.
* New error enumeration `sync::Client::Error` was added, and a corresponding
  `std::error_category` was provided too. These errors are reported when the
  client detects that the server violates the protocol.
* `util::network::Resolver::async_resolve()` was added, even though asynchronous
  DNS lookups are still not supported. The upside is that now the API exists and
  works. It just is not fully asynchronous. The risk is that the caller will be
  blocked for extended periods of time during the synchronous lookup. A proper
  asynchronous solution is underway.
* `util::network::Resolver::cancel()` was added for the purpose of canceling
  asynchronous resolve operations.
* `util::network::Endpoint::List::empty()` was added.
* YAML configuration files for the backup.
* enable flag in the YANML configration for the backup server.

-----------

### Internals

* A number of changes were made to the client-server fixtures
  (`ClientServerFixture` and `MultiClientServerFixture`) in
  `test_sync.cpp`. `set_session_error_handler()` was renamed to
  `set_client_side_error_handler()`. That function sets an error handler to be
  used for all sessions of a particular client. `set_client_error_handler()` was
  removed. `allow_client_errors()` was removed (obsolete). The fixture now
  allows errors for a particular client if, and only if an error handler has
  been specified for the sessions of that client. The reconnect delay is now
  disabled again for clients of the fixture, as was always the intention. This
  is important for the proper operation of `Sync_FailingReadsOnClientSide` and
  `Sync_FailingReadsOnServerSide`.
* `identity` in access tokens is now ignored by the server (obsolete) and
  has been removed from the protocol documentation.
* Refactor the reopening file logger and use it in continuous backup.
* Change of log messages in websocket and message receipt.

----------------------------------------------


# 1.0.0-BETA-5.0 Release notes

### Public

* None.

### Bugfixes

* Prevent a server crash when system call `shutdown()` fails with
  `ENOTCONN`. See `Connection::handle_write_error()` in
  `src/realm/sync/server.cpp`.

### Breaking changes

* Use `std::error_code` instead of `std::error_condition` for returning error
  codes in compression API (`<realm/util/compression.hpp>`).
* In namespace `realm::util::compression` (`<realm/util/compression.hpp>`),
  `deflate_bound()`, `deflate()`, and `inflate()` were renamed to
  `compress_bound()`, `compress()`, and `decompress()` respectively. Also,
  `compression_error_category()` was renamed to `error_category()`.
* Renamed `sync::Error` to `sync::ProtocolError` (because there are other
  categories of sync related errors beyond those defined by that enum).

### Enhancements

* New functions to wait asynchronously for upload, download, or upload+download
  completion (`async_wait_for_upload_completion()`,
  `async_wait_for_download_completion()`, and `async_wait_for_sync_completion()`
  in `sync::Session`).
* Introduce `std::error_category` for sync protocol errors
  (`sync::make_error_code(ProtocolError)`).
* Bump Realm core version to 2.2.0 (`dependencies.list`).
* Continuous backup version 1.

-----------

### Internals

* None.

----------------------------------------------


# 1.0.0-BETA-4.0 Release notes

### Public

* None.

### Bugfixes

* Cancellation of wait operation after completion.
* SSL SecureTransport partial write.

### Breaking changes

* `util::network::Socket` functions `read()`, `write()`, `read_until()`,
  `read_some()`, `write_some()`, and `shutdown()` are no longer
  `noexcept`. Likewise for `util::network::ssl::Stream` functions `handshake()`,
  `read()`, `write()`, `read_until()`, `read_some()`, `write_some()`, and
  `shutdown()`.

### Enhancements

* Support for Linux epoll and Kqueue in network abstraction API
  (`realm::util::network`).

-----------

### Internals

* Bug fix: Dangling references from lambdas in test client.
* Changed the format of the node lib package to tar.gz to match the core one.
* `util::network::ssl::Stream` now used operator slots (`m_read_oper`,
  `m_write_oper`) of `SocketBase` rather than introducing its own set of slots.
* Stream concept functions `do_init_read_sync()` and `do_init_write_sync()` in
  `util::network::Socket` and `util::network::ssl::Stream` have been elimintaed.
* Resolver, socket, and timer objects now refer directly to
  `util::network::Service::Impl` rather than indirectly via
  `util::network::Service`.
* File descriptor flag `FD_CLOEXEC` is now set on all sockets and pipe endpoints
  created by network abstraction API.
* New `WakeupPipe` helper class in `util/network.cpp`.
* Refactorization of network abstraction API in preperation of epoll/Kqueue
  support (`Descriptor` + `IoReactor`).

----------------------------------------------


# 1.0.0-BETA-3.3 Release notes

### Public

* None.

### Bugfixes

* None.

### Breaking changes

* None.

### Enhancements

* Prevent multiple concurrent sync agents per Realm file access session (by
  overriding `Replication::is_sync_agent()`).

-----------

### Internals

* Uses core 2.1.4

----------------------------------------------


# 1.0.0-BETA-3.2 Release notes

### Public

* None.

### Bugfixes

* The backup system has been enhanced to backup
Realm files of history types hist_Sync and
hist_in_realm correctly. More detailed unit test
for the backup has been written. The backup system
has been tested on the RMP.

### Breaking changes

* None.

### Enhancements

* None.

-----------

### Internals

* None.

----------------------------------------------


# 1.0.0-BETA-3.1 Release notes

### Public

* None.

### Bugfixes

* Uses realm-core 2.1.3

### Breaking changes

* None.

### Enhancements

* None.

-----------

### Internals

* None.

----------------------------------------------


# 1.0.0-BETA-3.0 Release notes

### Public

* None.

### Bugfixes

* None.

### Breaking changes

* Classes renamed in `util::network`: `stream_protocol` -> `StreamProtocol`,
  `ip_address` -> `Address`, `endpoint` -> `Endpoint`, `Endpoint::list` ->
  `Endpoint::List`, `io_service` -> `Service`, `resolver` -> `Resolver`,
  `Resolver::query` -> `Resolver::Query`, `socket_base` -> `SocketBase`,
  `socket` -> `Socket`, `acceptor` -> `Acceptor`, `deadline_timer` ->
  `DeadlineTimer`. Functions renamed in `util::network`:
  `Resolver::get_io_service()` -> `Resolver::get_service()`,
  `SocketBase::get_io_service()` -> `SocketBase::get_service()`,
  `DeadlineTimer::get_io_service()` -> `DeadlineTimer::get_service()`. None of
  these classes or functions are currently directly used by bindings.
* A server session is disabled if another session attempts to identify with
  the same client_file_ident for the same Realm.
* New error message Error::disabled_session

### Enhancements

* Device default certificates for the OpenSSL SSL implementation.
* The backup system is enhanced to include all Realms used by the ROS.
* The backup command is built statically and included in the ROS.

-----------

### Internals

* New test client feature: Perform transactions with configurable time
  separation (`--transact-period`).
* New test client feature: Meassure 1->N changeset propagation times
  (`--num-requests`, `--request-period`, `--receive-requests`,
  `--originator-ident`).
* New test client feature: Support for StatsD reporting via Dogless library
  (`--statsd-address`, `--statsd-port`).
* A simple test client that opens a high number of connections to the
  server and performs the WebSocket handshake but does not proceed with
  the Sync protocol. The purpose of the client is to test the maximum
  number of open connections on the server.
* New test client feature: Perform transactions with configurable random time
  separation (`--max-transact-period`).

----------------------------------------------


# 1.0.0-BETA-2.0 Release notes

### Public

* None.

### Bugfixes

* Lots of merge bugs relating to primary keys were fixed.

### Breaking changes

* The merge rules have changed as a consequence of fixing the above-mentioned
  bugs. Therefore, the protocol version has been increased.

### Enhancements

* None.

-----------

### Internals

* Update to core 2.1.0.

----------------------------------------------

# 1.0.0-BETA-1.3 Release notes

### Internals

* Update to core 2.0.1.

----------------------------------------------

# 1.0.0-BETA-1.2 Release notes

### Public

* None.

### Bugfixes

* Fixed starting the stats send timer in dogless.

### Breaking changes

* None.

### Enhancements

* None.

-----------

### Internals

* None.

----------------------------------------------

# 1.0.0-BETA-1.1 Release notes

### Public

* Use OpenSSL 1.0.2j.

### Bugfixes

* Remove the unused "permissions.realm"

### Breaking changes

* None.

### Enhancements

* None.

-----------

# 1.0.0-BETA-1.0 Release notes

* Public beta!

# 1.0.0-beta-37.2 Release notes

### Public

* None.

### Bugfixes

* Add `<sync/version.hpp>` to list of installed headers
  (`nobase_subinclude_HEADERS` in `src/realm/Makefile`).
* Use `CFLAGS_DEBUG=Oz`when building Cocoa.

### Breaking changes

* None.

### Enhancements

* None.

-----------

### Internals

* Don't create the unused `permissions.realm`.

----------------------------------------------


# 1.0.0-beta-37.1 Release notes

### Internals

* Uses core 2.0.0

# 1.0.0-beta-37.0 Release notes

### Public

* None.

### Bugfixes

* Connection initiation flow and handling of reconnect delay have been
  fixed. They were left in a half-broken state since the integration of
  WebSocket and SSL support. The immediate consequences were suboptimal logging
  and suboptimal determination of reconnect delay.
* Fixes LinkList / primary key merge issues found with AFL #820.

### Breaking changes

* Bumped protocol version to 14.

### Enhancements

* Add support for LinkListSwap instruction.
* Add support on the client side for setting a host name that must be checked
  in the server's certificate and for setting custom trust certificates.
* Sync server command (`src/realm/realm-server`) now has options to enable SSL
  (`--ssl`, `--ssl-certificate`, `--ssl-private-key`).

-----------

### Internals

* network_ssl is updated to check certificates for host name
  and to load arbitrary trust/anchor certificates.
* New client features for load testing
  (`sync::Client::Config::one_connection_per_session`,
  `sync::Client::Config::dry_run`). These are also made available via the test
  client (`test/client/test-client`).
* The test client is given the possibility to load trust certificates from the
  command line.
* New option `--access-token` (or `-A`) added to test client
  (`test/client/test-client`) to allow use of custom access tokens.

----------------------------------------------

# 1.0.0-beta-36.0 Release notes

### Public

* Bumped protocol version to 13.

### Bugfixes

* Fixed LinkedList merge issues found with AFL #768

### Breaking changes

* Bumped protocol version to 13.

### Enhancements

* None.

-----------

### Internals

* None.

----------------------------------------------

# 1.0.0-beta-35.0 Release notes

### Public

* Sync client now uses ports 80 and 443 by default for URI schemes `realm:` and
`realms:` respectively.

### Bugfixes

* Fix memory leak in `util/websocket.cpp`.

### Breaking changes

* Added `Client::Config::ssl_trust_certificate_path`.
* Sync client now uses ports 80 and 443 by default for URI schemes `realm:` and
  `realms:` respectively. This is done via a default enabled
  `sync::Client::Config::enable_default_port_hack`. It was done that way to make
  it clear that the change in default ports ought to have been tied to a change
  in URI schemes (`http:`/`https:` or `ws:`/`wss:`).


### Enhancements

* None.

-----------

### Internals

* None.

----------------------------------------------

# 1.0.0-beta-34.1 Release notes

### Bugfixes

*  Fix path deduction to happen in Node as well as standalone.

### Enhancements

* WebSocket is enhanced with an internal reset() function.
  This makes it possible to reuse the same WebSocket object
  for a new connection.
* Updated network_ssl to support OpenSSL version 1.1

-----------

### Internals

* Certificate Authority.

----------------------------------------------

# 1.0.0-beta-34.0 Release notes

### Public

* Support for sync over SSL.

### Bugfixes

* None.

### Breaking changes

* Client-side configuration parameter `sync::Client::Config::event_loop_impl`
  removed.
* The intermediate event loop abstraction layer (`<realm/util/event_loop.hpp>`)
  has been moved to the attic (`/attic/event_loop/`).
* The API for buffered reads has changed significantly
  (`network::ReadAheadBuffer` class replaces `network::buffered_input_stream`
  class). This change achieves two things: It make it possible to reuse the
  buffering code across SSL and non-SSL streams, and it brings us one step
  closer to ASIO API alignment.

### Enhancements

* Added packages for Ubuntu 16.04.
* Added SSL support based on OpenSSL or Apple SecureTransport as an optional
  extension to the POSIX level networking API (`util/network.hpp`). Supports
  synchronous and asynchronous HANDSHAKE, READ, WRITE, and SHUTDOWN
  operations. Supports buffered (`read()`, `read_until()`), unbuffered reads and
  writes (`read()`, `write()`), and partial reads and writes (`read_some()`,
  `write_some()`)), as well as all the corresponding asynchronous operations.
* New client-side configuration parameter
  `sync::Client::Config::verify_servers_ssl_certificate`.
* New server-side configuration parameters `sync::Server::Config::ssl`,
  `sync::Server::Config::ssl_certificate_path`, and
  `sync::Server::Config::ssl_certificate_key_path`.

-----------

### Internals

* Several new SSL related unit tests have been added..
* Sync client is no longer using the intermediate event loop abstraction layer
  `<realm/util/event_loop.hpp>`.

----------------------------------------------

# 1.0.0-beta-33.0 Release notes

### Public

* None.

### Bugfixes

* None.

### Breaking changes

* Uses core 2.0.0-rc4, with API breaking changes since 2.0.0-rc3.

### Enhancements

* Server Config object with support for SSL.

-----------

### Internals

* client.cpp uses util::network::io_service
  and util::network::socket.

----------------------------------------------

# 1.0.0-beta-32.0 Release notes

### Public

* Added support for the WebSocket protocol.

### Bugfixes

* None.

### Breaking changes

* WebSocket protocol for client/server communication.
* Sync protocol version bumped from 11 to 12.

### Enhancements

* Separate Crypto libraries for apple and other platforms.
* Separate Crypto libraries for server and general sync.

-----------

### Internals

* None.

----------------------------------------------

# 1.0.0-beta-31.0 Release notes

### Public

* None.

### Bugfixes

* Includes fixes for Link List and ChangeLinkTargets merge rules

### Breaking changes

* Uses core 2.0.0-rc3, with API breaking changes since 2.0.0-rc2.
* Sync protocol version bumped from 10 to 11.

### Enhancements

* None.

-----------

### Internals

* sha1() function implementation.

----------------------------------------------

# 1.0.0-beta-30.0 Release notes

### Public

* None.

### Bugfixes

* None.

### Breaking changes

* Pass the old and new version to the sync transact callback (#678).
* Uses core 2.0.0-rc2, with API breaking changes since 2.0.0-rc0.
* The macOS build products names and folder structure has been updated.

### Enhancements

* None.

-----------

### Internals

* None.

----------------------------------------------

# 1.0.0-beta-29.0 Release notes

### Enhancements

* Adopted a more advanced scheme for determining the delay between reconnect
  attempts. The general scheme is that the delay is one second if the previous
  connection was successfully established, but counting from the time where the
  previous connection was initiated. This means that in most cases the actual
  delay will be zero. On the other hand, if the previous connection was not
  successfully established, then the delay is twice the previous delay, up to a
  maximum of one minute. See `Connection::initiate_reconnect_wait()` in
  `sync/client.cpp` for further details.
* Properly seed the pseudo random number generator used by the server. This is
  important because the server is responsible for generating random identifiers
  of high quality.
* Changed the behavior of Primary Keys to more closely follow common
  expectations and use cases. Rows with primary key collisions are now merged
  according to the same rules as if they had always been the same row.

-----------

### Internals

* sha1 hash function in ther crypto package.
* base64 encode function.

----------------------------------------------

# 0.28.0 Release notes

### Bugfixes

* Make sure that `deflateEnd` is called at all relevant exit points of deflate.

### Breaking changes

* Uses Realm Core 1.5.0

### Enhancements

* Use a single call to send the client messages' header and body.

----------------------------------------------

# 0.27.4 Release notes

### Bugfixes

* Server no longer crashes if it receives the UNBIND message before the IDENT
  message for a particular session.

### Enhancements

* Server now prints out the path of the directory holding the persistent state
  (server-side Realm files).

----------------------------------------------

# 0.27.3 Release notes

### Bugfixes

* Uses core 1.4.2, as the latest is not yet supported by the bindings.

----------------------------------------------

# 0.27.2 Release notes

### Bugfixes

* Avoid passing `nfds` > `RLIMIT_NOFILE` to system `poll()`, as that causes it
  to fail with `EINVAL`. The fix is to only ever include entries in the `fds`
  array that are associated with open file descriptors, but this required
  nontrivial changes in `util/network.cpp`. Fortunately, these changes will have
  general performance-wise benefits, as the list of `pollfd` entries to check is
  now minimal.
* Be more diligent when handling the `stats.realm` file. Because some parts of
  the ROS use the ObjectStore to access this Realm file, and others use the raw
  realm-core APIs, some care has to be taken when interacting with the file.

### Enhancements

* The `statsd` metrics naming has been reviewed and updated across the code
  base. Please see `doc/monitoring.md` for more information.

----------------------------------------------

# 0.27.1 Release notes

### Bugfixes

* Fix memory leak in compression system. #590

----------------------------------------------

# 0.27.0 Release notes

### Bugfixes

* Sync server: Accept REFRESH message at any time (also before IDENT message).

### Breaking changes

* Introduce zlib compression of the DOWNLOAD message.
* `sync::Server` constructor now takes a `sync::Server::Config` argument (same
  idea as for `sync::Client`).
* Server metric `number_of_open_files` removed. This metric no longer has value
  (or at least very little value), as the number of open files is going to be
  equal to `sync::Server::Config::max_open_files` most of the time.
* `sync::Server::Config` now sets `stats_db` to null by default. Null prevents
  creation and/or updating of the Realm file used to communicate information to
  the dashboard.
* `util::network::protocol` and `util::network::address` renamed to
  `util::network::stream_protocol` and `util::network::ip_address` respectively
  to more closely align with ASIO.
* Public/private virtual path (or URL) scoping scheme replaced by tilde
  substitution (`/foo/~/bar` -> `/foo/<user-id>/bar`). This substitution is
  performed by the authorization server, and the sync server now treats all
  virtual paths alike.
* Error codes reordered (now categorized as either connection or session level
  errors).
* Sync protocol version bumped from 9 to 10.

### Enhancements

* Sync server no longer keeps all files open all the time. Instead, files are
  opened on demand, and it now uses an LRU cache to keep a certain maximum
  number of files open to avoid having to reopen on every access.
* Ability to assign native socket handle (integer) to socket object
  (`util::network::socket::assign()`) and a corresponding convenience
  constructor.

-----------

### Internals

* Changes in connection with the DOWNLOAD message.
* Removed `m_pending_changesets`.
* Removed client::flush() and made changes in the logic of the client run loop.
* Config object introduced to simplify use of `ClientServerFixture` in
  `test/test_sync.cpp`.
* `realm/util/uri{h|c}pp` moved from core.

----------------------------------------------


# 0.26.3 Release Notes

### Bugfixes

* Fix missing short argument options

-----------

### Internals

* Added missing merge rule for MoveColumn and SelectLinkList.
* Added missing merge rule for ClearTable and SwapRows.
* Added missing merge rules for substring operations and string update.
* Implemented missing merge rule for MoveGroupLevelTable and InsertColumn.

----------------------------------------------


# 0.26.2 Release Notes

### Bugfixes

* Fix implementation of several configuration options

----------------------------------------------


# 0.26.1 Release Notes

### Bugfixes

* Fix missing parts in configuration file.

----------------------------------------------


# 0.26.0 Release Notes

### Breaking changes

* Changed configuration file format so it would support configuration settings
  for realm-sync-services.

### Enhancements

* Added hooks to expose client and session errors to bindings.

-----------

### Internals

* Lorem ipsum.

----------------------------------------------


# 0.25.1 Release Notes

### Enhancements

* Uses core 1.4.0.

# 0.25.0 Release Notes

### Breaking changes

* Sync protocol version bumped from 8 to 9.
* Changed the format of the DOWNLOAD message to batch changesets and
  support progress reporting on the client.

----------------------------------------------


# 0.24.1 Release Notes

### Bugfixes

* Uses core 1.3.0.

----------------------------------------------


# 0.24.0 Release Notes

### Breaking changes

* `sync::Client` constructor now takes a configuration object as argument
  instead of taking each configuration parameter as a separate argument.
* `sync::History::initialize_and_get_status()` was changed to
  `sync::History::get_status()`. The initializing aspect of that function was
  removed. Explicit initialization is no longer needed.
* Server log level is now specified as one of `all`, `trace`, `debug`,
  `detail`, `info`, `warn`, `error`, `fatal`, or `off`, with `info` being the
  default level.
* Sync protocol error code (`bad_authentication`) moved from 200-range to
  300-range because it is now session specific. Other error codes were
  renumbered.
* Sync protocol version bumped from 7 to 8.

### Enhancements

* Server now logs core and sync library versions, as well as the sync protocol
  version when it is started.
* `sync::Client` now opens Realm files on demand to avoid having too many open
  files at once. It uses a LRU cache of open Realm files to amortize the cost of
  opening a Realm file.
* New client configuration parameter `max_open_files` sets the maximum number of
  Realm files that the Client will keep open concurrently. The default is 256.
* It is now possible to redirect log messages to a file (`-P`), and when doing
  that, all messages will be marked with a timestamp. Also, sending signal HUP
  to the server process will make it reopen the file when the next message is
  logged (for log rotation).

-----------

### Internals

* Add blob size control to test client.
* Allow for choosing between insert rows or overwrite last row modes in test
  client.

----------------------------------------------


# 0.23.2 Release Notes

### Bugfixes

* Uses Core v1.1.2
* Fix server positional arguments detection

----------------------------------------------


# 0.23.1 Release Notes

### Bugfixes

* Uses Core v1.1.1

----------------------------------------------


# 0.23.0 Release Notes

### Breaking changes

* Bumps sync protocol version from 6 to 7.
* API changed for `Session` class. Setting up a new session is now a multi-stage
  process ending with a call to `Session::bind()` (see
  `<realm/sync/client.hpp>`).
* The ALLOC message is enhanced to contain a client_file_ident_secret.
* The IDENT message is enhanced to contain a client_file_ident_secret.
* Single argument `Session::bind()` now accepts the `realms:` URL scheme. This
  corresponds to explicitly selecting `Protocol::realm_ssl` as protocol.
* Signature of multi-argument `Session::bind()` was changed to allow for
  protocol specification (non-SSL or SSL) and for passing zero for `server_port`
  to get the default port for the selected protocol.
* The use of Dogless in `server_command.cpp` is now optional and based on a new
  configuration variable `REALM_HAVE_DOGLESS`. Configure with
  `REALM_HAVE_DOGLESS=yes` to enable the use of Dogless. Leave
  `REALM_HAVE_DOGLESS` empty, or set it to `auto` to have `build.sh` try to
  autodetect the presence of the Dogless library. **Note:** For safety's sake,
  builds done through continuous integration (Jenkins) must set
  `REALM_HAVE_DOGLESS=yes` when running `sh build.sh config`.
* Add support fo a configuration file that can replace the flags and use that in
  the  CentOS/RHEL packages.

### Bugfixes

### Enhancements

* The server verifies the client_file_ident of connecting clients.
  The verification is useful to avoid spoofig and to catch a subtle
  error after backup recovery.
* Client now uses the new event loop API for networking and timers. Until now it
  was using the POSIX style API offered in `util::network`.
* New `--disable-sync` option on server command.
* New `--num-transacts`, `--follow`, and `--disable-sync` options on test
  client.

### Internals

* Dogless library no longer called directly from sync server. Instead there is
  now an abstract metrics interface (`sync::Metrics`) in
  `<realm/sync/metrics.hpp>` and a Dogless based implementation in
  `server_command.cpp`.

----------------------------------------------

# 0.22.0 Release notes

### Breaking changes

* Bumps sync protocol version from 4 to 6.
* Renames IDENT message to CLIENT.
* Renames ALLOC message (client->server) to IDENT.
* Adds `<client info>` parameter to CLIENT message.
* The part of the protocol that deals with the clients acquisition of a server
  allocated file identifier pair has been changed. Exchange of ALLOC and IDENT
  messages now occur as part of a session.
* Protocol error messages reworked and renumbered to reflect this change.
* New error code for the case of overlapping reuse of session identifiers
  (`Error::reuse_of_session_ident`).
* New error code for the case of a client side file already being bound in
  another session (`Error::bound_in_other_session`).
* New error code for the case of a client side file disagreeing with the
  server about the history (`Error::divergent_history`).
* File-format breaking change: Client-side history format was updated with
  the required information to be able to detect divergent histories.

### Bugfixes

* The server no longer uses a queue of output messages to manage the
  interleaving of messages sent by different sessions. Instead it now uses a
  queue of sessions that are ready to send a message (just like on the client
  side). This means that messages are now never generated before they are
  needed, and also solves some problems, and fixes a bug relating to session
  life cycle management on the server side.
* Session level post handlers now hold a counted session reference to avoid
  accessing a destroyed session.

### Enhancements

* It is no longer possible for clients to resume synchronization with a server
  that has been restored from backup to a previous state, if that client has
  received changes that we lost in the recovery.

### Internals

* Client side session ownership is now managed by reference counting.
* Introduction of two new life-cycle states for client-side sessions (Uninitiated, Zombie).
* Add unit test Sync_MultipleServers.
* Fixed bug in MultiClientServerFixture (unit testing).

----------------------------------------------

# 0.21.0 Release notes

### Breaking changes

* Use protocol version 4 (see doc/protocol.md for details).
* Concatenate syncIdentity and syncSignature as syncUserToken.

### Bugfixes

* None

### Enhancements

* None

### Internals

* None
