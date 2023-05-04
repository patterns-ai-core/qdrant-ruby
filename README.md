# Qdrant

<p>
    <img alt='Qdrant logo' src='https://qdrant.tech/images/logo_with_text.svg' height='50' />
    &nbsp;&nbsp;+&nbsp;&nbsp;
    <img alt='Ruby logo' src='https://user-images.githubusercontent.com/541665/230231593-43861278-4550-421d-a543-fd3553aac4f6.png' height='40' />
</p>

Ruby wrapper for the Qdrant vector search database API

![Tests status](https://github.com/andreibondarev/qdrant-ruby/actions/workflows/ci.yml/badge.svg) [![Gem Version](https://badge.fury.io/rb/qdrant-ruby.svg)](https://badge.fury.io/rb/qdrant-ruby)

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add qdrant-ruby

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install qdrant-ruby

## Usage

### Instantiating API client

```ruby
require 'qdrant'

client = Qdrant::Client.new(
  url: "your-qdrant-url",
  api_key: "your-qdrant-api-key"
)
```

### Collections

```ruby
# Get list name of all existing collections
client.collections.list

# Get detailed information about specified existing collection
client.collections.get(collection_name: "string")

# Create new collection with given parameters
client.collections.create(
    collection_name: "string",     # required
    vectors: {},                   # required
    shard_number: nil,
    replication_factor: nil,
    write_consistency_factor: nil,
    on_disk_payload: nil,
    hnsw_config: nil,
    wal_config: nil,
    optimizers_config: nil,
    init_from: nil,
    quantization_config: nil
)

# Update parameters of the existing collection
client.collections.update(
    collection_name: "string",    # required
    optimizers_config: nil,
    params: nil
)

# Drop collection and all associated data
client.collections.delete(collection_name: "string")

# Get list of all aliases (for a collection)
client.collections.aliases(
    collection_name: "string" # optional
)

# Update aliases of the collections
client.collections.update_aliases(
    actions: [{
        # `create_alias:`, `delete_alias` and/or `rename_alias` is required
        create_alias: {
            collection_name: "string", # required
            alias_name: "string"       # required
        }
    }]
)

# Create index for field in collection
client.collections.create_index(
    collection_name: "string", # required
    field_name: "string",      # required
    field_schema: "string",
    wait: "boolean",
    ordering: "ordering"
)

# Delete field index for collection
client.collections.delete_index(
    collection_name: "string", # required
    field_name: "string",      # required
    wait: "boolean",
    ordering: "ordering"
)

# Get cluster information for a collection
client.collections.cluster_info(
    collection_name: "test_collection" # required
)

# Update collection cluster setup
client.collections.update_cluster(
    collection_name: "string", # required
    move_shard: {              # required
        shard_id: "int",
        to_peer_id: "int",
        from_peer_id: "int"
    },
    timeout: "int"
)

# Create new snapshot for a collection
client.collections.create_snapshot(
    collection_name: "string", # required
)

# Get list of snapshots for a collection
client.collections.list_snapshots(
    collection_name: "string", # required
)

# Delete snapshot for a collection
client.collections.delete_snapshot(
    collection_name: "string", # required
    snapshot_name: "string"    # required
)

# Recover local collection data from a snapshot. This will overwrite any data, stored on this node, for the collection. If collection does not exist - it will be created.
client.collections.restore_snapshot(
    collection_name: "string", # required
    filepath: "string",        # required
    wait: "boolean",
    priority: "string"
)

# Download specified snapshot from a collection as a file
client.collections.download_snapshot(
    collection_name: "string",         # required
    snapshot_name: "string",           # required
    filepath: "/dir/filename.snapshot" #require 
)
```

### Points
```ruby
# Retrieve full information of single point by id
client.points.get(
    collection_name: "string", # required
    id: "int/string",          # required
    consistency: "int"
)

# Lists all data objects in reverse order of creation. The data will be returned as an array of objects.
client.points.list(
    collection_name: "string", # required
    ids: "[int/string]",       # required
    with_payload: nil,
    with_vector: nil,
    consistency: nil

)

# Get a single data object.
client.points.upsert(
    collection_name: "string", # required
    batch: {},                 # required
    wait: "boolean",
    ordering: "string"
)

# Delete points
client.points.delete(
    collection_name: "string", # required
    points: "[int/string]",    # either `points:` or `filter:` required
    filter: {},
    wait: "boolean",
    ordering: "string"
)

# Set payload values for points
client.points.set_payload(
    collection_name: "string", # required
    payload: {                 # required
        "property name" => "value" 
    },  
    points: "[int/string]",    # `points:` or `filter:` are required
    filter: {},
    wait: "boolean",
    ordering: "string"
)

# Replace full payload of points with new one
client.points.overwrite_payload(
    collection_name: "string", # required
    payload: {},               # required 
    wait: "boolean",
    ordering: "string",
    points: "[int/string]",
    filter: {}
)

# Delete specified key payload for points
client.points.clear_payload_keys(
    collection_name: "string", # required
    keys: "[string]",          # required
    points: "[int/string]",
    filter: {},
    wait: "boolean",
    ordering: "string"
)

# Delete specified key payload for points
client.points.clear_payload(
    collection_name: "string", # required
    points: "[int/string]",    # required
    wait: "boolean",
    ordering: "string"
)

# Scroll request - paginate over all points which matches given filtering condition
client.points.scroll(
    collection_name: "string", # required
    limit: "int",
    filter: {},
    offset: "string",
    with_payload: "boolean",
    with_vector: "boolean",
    consistency: "int/string"
)

# Retrieve closest points based on vector similarity and given filtering conditions
client.points.search(
    collection_name: "string", # required
    limit: "int",              # required
    vector: "[int]",           # required
    filter: {},
    params: {},
    offset: "int",
    with_payload: "boolean",
    with_vector: "boolean",
    score_threshold: "float"
)


# Retrieve by batch the closest points based on vector similarity and given filtering conditions
client.points.batch_search(
    collection_name: "string", # required
    searches: [{}],            # required  
    consistency: "int/string"
)

# Look for the points which are closer to stored positive examples and at the same time further to negative examples.
client.points.recommend(
    collection_name: "string", # required
    positive: "[int/string]",  # required; Arrray of point IDs
    limit: "int",              # required
    negative: "[int/string]",
    filter: {},
    params: {},
    offset: "int",
    with_payload: "boolean",
    with_vector: "boolean",
    score_threshold: "float"
    using: "string",
    lookup_from: {},
)

# Look for the points which are closer to stored positive examples and at the same time further to negative examples.
client.points.batch_recommend(
    collection_name: "string", # required
    searches: [{}],            # required
    consistency: "string"
)

# Count points which matches given filtering condition
client.points.count(
    collection_name: "string", # required
    filter: {},
    exact: "boolean"
)
```

### Snapshots
```ruby
# Get list of snapshots of the whole storage
client.snapshots.list(
    collection_name: "string" # optional
)

# Create new snapshot of the whole storage
client.snapshots.create(
    collection_name: "string" # required
)

# Delete snapshot of the whole storage
client.snapshots.delete(
    collection_name: "string", # required
    snapshot_name: "string"    # required
)

# Download specified snapshot of the whole storage as a file
client.snapshots.download(
    collection_name: "string", # required
    snapshot_name: "string"    # required
    filepath: "~/Downloads/backup.txt" # required
)


# Get the backup
client.backups.get(
    backend: "filesystem",
    id: "my-first-backup"
)

# Restore backup
client.backups.restore(
    backend: "filesystem",
    id: "my-first-backup"
)

# Check the backup restore status
client.backups.restore_status(
    backend: "filesystem",
    id: "my-first-backup"
)
```

### Cluster
```ruby
# Get information about the current state and composition of the cluster
client.cluster.info

# Tries to recover current peer Raft state.
client.cluster.recover

# Tries to remove peer from the cluster. Will return an error if peer has shards on it.
client.cluster.remove_peer(
    peer_id: "int",  # required
    force: "boolean"
)
```

### Service
```ruby
# Collect telemetry data including app info, system info, collections info, cluster info, configs and statistics
client.telemetry(
    anonymize: "boolean" # optional
)

# Collect metrics data including app info, collections info, cluster info and statistics
client.metrics(
    anonymize: "boolean" # optional
)

# Get lock options. If write is locked, all write operations and collection creation are forbidden
client.locks

# Set lock options. If write is locked, all write operations and collection creation are forbidden. Returns previous lock options
client.set_lock(
    write: "boolean" # required
    error_message: "string"
)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/andreibondarev/qdrant.

## License

qdrant-ruby is licensed under the Apache License, Version 2.0. View a copy of the License file.

