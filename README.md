# Phobos

A mock server for mars


## Example

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
app.use('/mock', phobos(options));

// start server
http.createServer(app).listen(8080);

```

## About `.phobosrc`

This is a js file **NOT A JSON**. Never forget to add module.exports on it's head.

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

## About define files

### Structure of directory

    $PWD/.phobos
    ├── item.json        => /mock/item
    └── user
        ├── get.json     => /mock/user (with method GET)
        ├── list.json    => /mock/user/list
        └── put.json     => /mock/user (with method POST)

Usable methods: `GET`, `POST`, `DELETE`, `PUT`

### Define file

define file is a JSON file. you can use `#{name [arg1[, arg2...]]}` to access predefined variables (base on mars-deimos).

```json
{
  "name" : "#{person.name}",
  "age" : "#{person.age}",
  "city" : "#{address.city}",
  "zipcode": "#{address.zipcode}",
  "intro": "#{lorem.sentence 1}",
  "friends_number": "#{number}",
  "lastLocation": {
    "lati" : "#{number.float -180, 180, '0[.]0000'}",
    "long" : "#{number.float -180, 180, '0[.]0000'}"
  }
}
```

#### Predefined variables list

| address |  |
| :----- | :----- |
| #{address} | 重庆省晋州县合山镇 原平巷363号 绿城星洲公寓 6-30 |
| #{address.country} | 中国 |
| #{address.stateName} | 重庆 |
| #{address.stateSuffix} | 省 |
| #{address.cityName} | 晋州 |
| #{address.citySuffix} | 县 |
| #{address.countyName} | 合山 |
| #{address.countySuffix} | 镇 |
| #{address.roadName} | 原平 |
| #{address.roadSuffix} | 巷 |
| #{address.no} | 363号 |
| #{address.buildingName} | 绿城星洲 |
| #{address.buildingSuffix} | 公寓 |
| #{address.buildingNo} | 6-30 |
| #{address.zipcode} | 475811 |
| #{address.full} | 重庆省晋州县合山镇 原平巷363号 绿城星洲公寓 6-30 |
| #{address.state} | 重庆省 |
| #{address.city} | 晋州县 |
| #{address.county} | 合山镇 |
| #{address.road} | 原平巷363号 |
| #{address.building} | 绿城星洲公寓 6-30 |
[here](http://daringfireball.net/projects/markdown/syntax).

| date | (format with [Moment.js](http://momentjs.com)) |
| :----- | :----- |
| #{date} | 1954-08-17 08:57:36 |
| #{date.fulldate} | 1954-08-17 |
| #{date.fulltime} | 1954-08-17 08:57:36 |
| #{date.time} | 08:57:36 |
| #{date.year} | 1954 |
| #{date.month} | 8 |
| #{date.day} | 17 |
| #{date.week} | 34 |
| #{date.weekday} | 2 |
| #{date.hour} | 8 |
| #{date.minute} | 57 |
| #{date.second} | 36 |
| #{date.zone} | +08:00 |

| lorem |  |
| :----- | :----- |
| #{lorem} | 药房餐馆缔交宁死不屈综合开发上报岗位津贴谋害肯干？ |
| #{lorem.word} | 一眼 |
| #{lorem.words 5} | 实地考察流离失所万元 |
| #{lorem.words 3, 20} | 长存住家住房难为时不晚宝贝任人为贤这句话他的有名磺胺脒共同市场综合开发立春劳动部剪辑 |
| #{lorem.sentence} | 渊源同盟军重像脸上反应式经济力量淡化管理条例三军。 |
| #{lorem.sentences 1} | 袒胸露背拉丁文拼写流产现行制度抢险救灾三线唾骂？红色车水马龙加元派出原本， |
| #{lorem.sentences 2, 3} | 水道链式反应小百货禅师歪歪扭扭，互相照顾超车音质玻璃。 |
| #{lorem.paragraph} | 去粗取精光荣斑岩体外电位器稳操胜券贫富小标题禅师经济手段波长墒情老本糟粕。超音徇情深入人心轮胎一眼灯具流离失所住房难生活费用订购名烟光荣快报泥沙？预示酌情敬而远之推杆车水马龙为时不晚真核细胞土法生产乡民摩擦力实地考察缠绵列车员。 |
| #{lorem.paragraphs 1} | 搀和二者房租省去播音员科技服务本体曼谷，平方公里支队为时不晚三角皮带小时自然经济广泛开展！边防哨所见票后管理条例？ |
| #{lorem.paragraphs 2, 3} | 增高扩编目次肯干。戒除老本欧佩克领导同志迎战散乱废话雨季互相照顾医师西边？刨子进口国收藏轻武器酌情缔交自然经济迎着科技服务敷衍塞责提意见翻越深入人心？间接活化剂影像浅见互相照顾，具体意见长春好书惨状在外恩泽，泥沙刨子餐馆西周一如既往春雷大众更新村落，紧俏商品竖立模式毗邻冬季运动主航道煤田？生产者酿成荣归时值较强卫戍剪辑荣归豆子！灯具沟壑现行制度筹备结业！<br />技能由此而来脸上振幅新疆？并能药房遥遥？国歌灯具玻璃光荣验收报告照直老本涉嫌静平衡平方公里宁死不屈敷衍塞责大众？收买元老派出盘亘抢险救灾独裁凝集鱼种活受罪评注除开百炼成钢缩写粗沙，花花绿绿培训班哄抬危险品更新， |

| number | (format with [Numeral.js](http://numeraljs.com)) |
| :----- | :----- |
| #{number} | 1101357782 |
| #{number.int} | 234346672 |
| #{number.int 1000} | 37 |
| #{number.int 2000, 3000} | 2092 |
| #{number.int '0,0'} | 1,169,576,226 |
| #{number.int 10000, 99999, '0,0'} | 23,098 |
| #{number.float} | 47967.893 |
| #{number.float 1000} | 214.935 |
| #{number.float 2000, 3000} | 2643.600 |
| #{number.float '0,0[.]00'} | 59,334.45 |
| #{number.float 10000, 99999, '0,0[.]00'} | 23,589.14 |
| #{number.percent} | 145.94% |
| #{number.percent 1} | 59.56% |
| #{number.percent 2, 3} | 229.24% |
| #{number.percent '0[.]0000%'} | 58.6211% |
| #{number.percent 0.3, 0.5, '0[.]0000%'} | 43.2398% |

| person |  |
| :----- | :----- |
| #{person} | 王保 |
| #{person.name} | 王保 |
| #{person.lastName} | 王 |
| #{person.firstName} | 保 |
| #{person.gender} | 女 |
| #{person.age} | 61 |
| #{person.nominalAge} | 63 |
| #{person.birthday.fulldate} | 1954-08-17 |

| mobile |  |
| :----- | :----- |
| #{mobile} | 181-1334-1828 |
| #{mobile.country} | +86 |

| phone |  |
| :----- | :----- |
| #{phone} | 0519-13350160 |
| #{phone.country} | +86 |


