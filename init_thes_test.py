# -*- coding: utf-8 -*-

from parser.Init_Thes import Init_thesaurus 

thes=Init_thesaurus('store/wordBar')

thes.show()
print '-'*50
print 'end show() successfully!'

'''

print 'in try to find >>>>>>>>>'
wli=['中国','农业','欢迎','你','h']

index_li=[]
for w in wli:
    print w,thes.find(w)
    index_li.append(thes.find(w))
print 'begin to find whether it is right'

f=open('store/wordBar')
c=f.read()
f.close()
words=c.split()
for i,w in enumerate(index_li):
    print i,index_li[i],words[index_li[i]],'--',wli[i]
#thes.show()

'''

