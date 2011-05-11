#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
Created on 2011-5-8

@author: chunwei
'''
import sys
reload(sys)
sys.setdefaultencoding('utf-8')

import xml.dom.minidom as dom
from HtmlParser import HtmlParser

class collector():
    '''
    从html中提取相关tag内容
    '''
    def __init__(self,html):
        self.html=html
        self.d=pq(html)
        self.d('script').remove()
        self.d('style').remove()
        self.html_parser=HtmlParser(self.html)
       
        
    def clear_other_node(self):
        '''
        删除无用标签
        '''
        self.d('head').remove()
        self.d('h1').remove()
        self.d('h2').remove()
        self.d('h3').remove()
        self.d('b').remove()
        self.d('a').remove()
        
    def get_title(self):
        '''
        提取 title
        '''
        return self.d('title').text()
    
    def get_node(self,node):
        '''
        提取 字符型节点 字符串
        '''
        nodes=self.html_parser.get_node(node)
        text=''
        for i in nodes:
            text+=i
        return text
    
    def get_urls(self):
        '''
        返回url  与 get_as 想配套
        '''
    

    def xml(self,docID):
        '返回xml源码'
        #通过docID 在sortedurls 中确定 tem_home_url
        self.transurl.setTemHomeUrl(docID) #确定tem_home_url
        str='<html></html>'
        titleText=self.d('title').text()
        self.dd=dom.parseString(str)
        #print self.dd
        html=self.dd.firstChild
        #生成title
        htmlCtrl=htmlctrl(self.d.html())
        title=self.dd.createElement('title')
        html.appendChild(title)
        title.setAttribute('text',titleText)
        #生成b
        bb=htmlCtrl.gNode('b')
        b=self.dd.createElement('b')
        for i in bb:
            ii=self.dd.createElement('item')
            ii.setAttribute('text',i)
            b.appendChild(ii)
        html.appendChild(b)
        #生成h1
        bb=htmlCtrl.gNode('h1')
        b=self.dd.createElement('h1')
        for i in bb:
            ii=self.dd.createElement('item')
            ii.setAttribute('text',i)
            b.appendChild(ii)
        html.appendChild(b)
        #生成h2
        bb=htmlCtrl.gNode('h2')
        b=self.dd.createElement('h2')
        for i in bb:
            ii=self.dd.createElement('item')
            ii.setAttribute('text',i)
            b.appendChild(ii)
        html.appendChild(b)
        #生成h3
        bb=htmlCtrl.gNode('h3')
        b=self.dd.createElement('h3')
        for i in bb:
            ii=self.dd.createElement('item')
            ii.setAttribute('text',i)
            b.appendChild(ii)
        html.appendChild(b)
        #生成a
        aa=htmlCtrl.gA()
        a=self.dd.createElement('a')
        for i in aa:
            #i=self.transurl.trans_d(i) #对url转化为标准绝对地址
            aindex=self.dd.createElement('item')
            aindex.setAttribute('name',i)
            #aindex.setAttribute('href',self.a_trav(aa[i]))
            aindex.setAttribute('href',self.transurl.trans_d(aa[i]))
            a.appendChild(aindex)
        html.appendChild(a)
        #加入content
        htmltext=self.d.html().decode('gbk','ignore').encode('utf-8')
        ht=pq(htmltext)
        #bug 说明
        #此处  需啊注意 其中有html的特殊字符   &# 等等
        #在分词的时候另外说明
        content=ht.text()
        cc=self.dd.createElement('content')
        ctext=self.dd.createTextNode(content)
        cc.appendChild(ctext)
        html.appendChild(cc)
        #print self.dd.toprettyxml()
        return self.dd