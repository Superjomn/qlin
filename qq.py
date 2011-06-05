# -*- coding: utf-8 -*-

import chardet

from query.Title_query import Query

query = Query('store/hits','store/hits/hit_size.txt')

strr='中国农业'

print chardet.detect(strr)

query.find_words(strr)
