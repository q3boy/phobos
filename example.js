var phobos = require("./");
var connect = require("connect");
var http = require("http");

var options = {
  rewrite : [ // rewrite rules
    {
      test : "/aaa",
      target : "http://www.ali213.net/"
    },
  ]
};

app = connect();

// use as a connect middleware
app.use(phobos(options));

// start server
http.createServer(app).listen(8080, ()=>{
  console.log("listening on 8080");
});