
module.exports = [
  require 'art-standard-lib'
  require "art-class-system"
  require "art-config"

  require "./Binary"
  require "./Tools"

  package: _package = require "art-foundation/package.json"
  version: _package.version
]
