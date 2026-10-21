## [Unreleased]

## [0.11.0] - 2026-10-21
- Fix `collections.restore_snapshot` to use PUT (POST always returned 404)
- Fix `clusters.remove_peer` to call `DELETE /cluster/peer/{peer_id}` instead of `POST /cluster/recover`
- `client.aliases` no longer caches the first response
- `points.list` now requires `ids:` (the API always required it)
- Deprecation warnings for `points.search`, `batch_search`, `recommend`, `batch_recommend` (use `points.query`), the lock API and `init_from:` (both removed in Qdrant 1.16)
- README: fix inaccurate examples and remove the nonexistent `backups` section

## [0.10.0] - 2026-08-12
- Drop Faraday dependency

## [0.9.10] - 2025-11-23

## [0.9.9] - 2024-04-11
- Allow sparse_vectors to be passed to collections.create
- Support query endpoint

## [0.9.8] - 2024-10-01
- Qdrant::Client constructor accepts customer logger: to be passed in

## [0.9.7] - 2024-01-19
- fix: points/delete api

## [0.9.6] - 2024-01-13
- Updated Points#delete() method: Removed the requirement to specify points: in parameters. Now generates an error if neither points: nor filters: are provided, aligning with delete_points documentation standards.

## [0.9.5] - 2024-01-12
- Bugfix: ArgumentError for filter in points delete

## [0.9.4] - 2023-08-31
- Introduce `Points#get_all()` method

## [0.9.0] - 2023-04-08
- Initial release
