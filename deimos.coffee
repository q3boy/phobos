deimos = require 'mars-deimos'

faker = deimos defaultSize :
  words : [2,  5]
  sentences : [2,  3]
  paragraphs : [2,  3]
list =
  address : [''
    'country', 'stateName', 'stateSuffix', 'cityName', 'citySuffix'
    'countyName', 'countySuffix', 'roadName', 'roadSuffix'
    'no', 'buildingName', 'buildingSuffix', 'buildingNo', 'zipcode',
    'full', 'state', 'city', 'county', 'road', 'building'
  ]
  date : [''
    'fulldate', 'fulltime', 'time', 'year', 'month', 'day',
    'week', 'weekday', 'hour', 'minute', 'second', 'zone'
  ]
  lorem : [''
    'word', 'words 5', 'words 3, 20'
    'sentence', 'sentences 1', 'sentences 2, 3'
    'paragraph', 'paragraphs 1', 'paragraphs 2, 3'
  ]
  number: [''
    'int', 'int 1000', 'int 2000, 3000', 'int \'0,0\'', 'int 10000, 99999, \'0,0\''
    'float', 'float 1000', 'float 2000, 3000', 'float \'0,0[.]00\'', 'float 10000, 99999, \'0,0[.]00\''
    'percent', 'percent 1', 'percent 2, 3', 'percent \'0[.]0000%\'', 'percent 0.3, 0.5, \'0[.]0000%\''
  ]
  person: [''
    'name', 'lastName', 'firstName', 'gender', 'age', 'nominalAge', 'birthday.fulldate'
  ]
  mobile : [''
    'country'
  ]
  phone : [''
    'country'
  ]

out = []
for k,v of list
  out.push "| #{k} |  |\r\n| :----- | :----- |"
  for name in v

    tpl = if name then "\#{#{k}.#{name}}" else "\#{#{k}}"
    # console.log tpl
    out.push "| #{tpl} | #{faker.fake(tpl).trim()} |"
  out.push ''
# console.log out
console.log out.join "\r\n"












