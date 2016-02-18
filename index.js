try {
  path = require.resolve('./dist/lib/phobos')
} catch (e) {
  if (require.extensions['.coffee'] === undefined) {
   require('coffee-script/register')
  }
  path = './lib/phobos'
}
module.exports = require(path)