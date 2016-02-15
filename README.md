## Phobos

A mock server for mars

## Usage
### Example

```javascript
var phobos = require("phobos");
var connect = require("connect");
var http = require("http");


var options = {
  locale : 'zh_CN',
  dir : "./phobos", // dir of mock define files
  data_list: [], // additional variables files list
  rewrite : [ // rewrite rules
    {
      test : "/wildcard/*",
      target : "/target/$1"
    }, {
      test : /^\/regexp\/(\?.*)?$/,
      target : "/target$1",
      method : "get"
    },{
      test : "/wildcard/*",
      target : "http://revert.proxy.com/$1"
    },
  ]
};
module.exports = {
  dir : "phobos_define",
  rewrite : [
    {
      test : "/aaa*",
      target : "/pp"
    },
    {
      test : /^\/bbb\/info(\?.*)?$/,
      target : "/pp$1",
      method : "get"
    }
  ]
}

app = connect();

// use as a connect middleware
app.use phobox(options).middleware()

// start server
http.createServer(app).listen(8080);

```



