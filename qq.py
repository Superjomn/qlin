# -*- coding: utf-8 -*-

import chardet

from query.Title_query import Query

query = Query('store/hits','store/hits/hit_size.txt')

strr='出版社图书馆'


query.find_words(strr)

query.find_words('你好中国')
print query.get_res(1)

query.find_words('理学院')

print query.get_res(1)

