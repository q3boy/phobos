if (require.extensions['.coffee'] === undefined) {
  require('coffee-script/register')
}
module.exports = require('./lib/index')