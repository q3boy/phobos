## Phobos

A mock server for mars

## Usage


### Example

```javascript
var phobos = require("phobos");
var connect = require("connect");
var http = require("http");

// read options from $PWD/.phobosrc by default
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

app = connect();

// use as a connect middleware
app.use phobox(options).middleware()

// start server
http.createServer(app).listen(8080);

```

### About .phobosrc

this is a js file **NOT A JSON**. never forgot add module.exports on it's head.

```javascript
module.exports = {
   rewrite : [ // use comments
    {
      test : "/wildcard/*",
      target : "/target/$1"
    }, {
      test : /^\/regexp\/(\?.*)?$/, // regexp directly
      target : "/target$1",
      method : "get"
    }
  ]
}
```




