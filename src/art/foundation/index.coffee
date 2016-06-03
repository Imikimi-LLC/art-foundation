# generated by Neptune Namespaces v0.1.0
# file: art/foundation/index.coffee

(module.exports = require './namespace')
.includeInNamespace(require './_foundation')
.addModules
  Analytics:               require './analytics'
  BatchLoader:             require './batch_loader'
  Epoch:                   require './epoch'
  GlobalCounts:            require './global_counts'
  JsonStore:               require './json_store'
  ProgressAdapter:         require './progress_adapter'
  RestClient:              require './rest_client'
  SingleObjectTransaction: require './single_object_transaction'
  Stat:                    require './stat'
  Transaction:             require './transaction'
  WebWorker:               require './web_worker'
  WorkerRpc:               require './worker_rpc'
require './binary'
require './browser'
require './class_system'
require './standard_lib'