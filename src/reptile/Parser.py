#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys
reload(sys)
sys.setdefaultencoding('utf-8')

from pyquery import PyQuery as pq
import chardet
from parser.HtmlParser import HtmlParser
class Parser:
    '''
    解析库
    将下载后的html源码同时转化为document 返回
    部分功能嵌入到spider中
    
    '''
    def __init__(self):
        self.ict=Ictclas('ICTCLAS50/') 
        
    def transDoc(self,html):
        '''
        传入html源码 
        转化为document文档
        返回xml数据
        '''
        res=chardet.detect(c)
        coding=res['encoding']
        #print 'the former coding',coding
        if coding!='utf-8':
            try:
                html=html.decode(coding)
            except:
                print 'something wrong'
                
        collec=collector(html)
        f.close()
        f=open(self.xmlph+'/'+hp,'w')
        try:
            return collec.xml(hp).toxml()
        except:
            return False
        num+=1

    def _debug(self):
        f=open(self.wbpath)
        c=f.read()
        for i in c.split():
            print i,hash(i)

if __name__=='__main__':
    p=parser('store/html','store/document','store/wordsplit','store/wordBar')
    #p.transDoc()
    #p.splitWord()
    #p.transWbar()
    p._debug()
