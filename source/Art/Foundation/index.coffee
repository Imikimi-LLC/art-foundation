# generated by Neptune Namespaces v1.x.x
# file: Art/Foundation/index.coffee

module.exports = require './namespace'
.includeInNamespace require './Foundation'
.addModules
  FoundationConfig: require './FoundationConfig'
require './Binary'
require './Browser'
require './ClassSystem'
require './StandardLib'
require './Tools'