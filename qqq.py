# -*- coding: utf-8 -*-
import sys
reload(sys)
sys.setdefaultencoding('utf-8')


#from timeit import Timer


import Query 

qq=Query.Res_Query(0)

#print qq.gres('中国农业大学',1)
li=['教务处','体育部数学','中国农业银行','大大的猪头','开放的中国农业大学欢迎您']

for i in li:
    print i
    print qq.gres(i,1)
