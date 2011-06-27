# -*- coding: utf-8 -*-

import chardet

from query.query import Query

from timeit import Timer



#li=['中国','理学院','教务处','大学','领导','体育部数学','中国农业银行','红十字会','北京大学生','北京实验室','试探纪实','实验室','教务处']
li=['中国']

query = Query(0)

print query.get_res('中国',1)

