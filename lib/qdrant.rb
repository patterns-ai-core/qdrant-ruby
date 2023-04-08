# frozen_string_literal: true

require_relative "qdrant/version"

module Qdrant
  autoload :Aliases, "qdrant/aliases"
  autoload :Base, "qdrant/base"
  autoload :Collections, "qdrant/collections"
  autoload :Client, "qdrant/client"
  autoload :Clusters, "qdrant/clusters"
  autoload :Collections, "qdrant/collections"
  autoload :Error, "qdrant/error"
  autoload :Points, "qdrant/points"
  autoload :Service, "qdrant/service"
  autoload :Snapshots, "qdrant/snapshots"
end
