# -*- coding: utf-8 -*-

import chardet

from query.query import Query

from timeit import Timer



li=['中国','教务处','体育部数学','中国农业银行','红十字会','北京大学生','北京实验室','试探纪实','实验室','教务处']


query = Query()

#query.find_words('中国农业大学')
#print query.get_res('严春伟',1)
#print query.get_res('中国农业大学',1)
'''
hashvalue=[232,2313232,434334,323,-23434334]
for i in hashvalue:
    query.init_hit_file(i)
'''
print '-'*100
print '试探 纪实' 
print query.get_res('农业部科教司',1)



for i in li:
    print i
    print query.get_res(i,1)
    #print query.get_res(1)

def find(word):
    print 'find',word
    print query.get_res(word,1)

print 'chunwei ---------------------------------------------------'
'''print   'find 中国'
print query.get_res('中国',1)
'''

'''
print '-'*100
t=Timer("find('%s')"%('严春伟'),"from __main__ import find")

print t.timeit(1)
'''


'''print query.get_res('中国',1)    

print query.get_res('中国农业大学',1)'''





