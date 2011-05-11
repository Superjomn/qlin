# -*- coding: utf-8 -*-
'''
Created on 2011-3-12

@author: chunwei
'''

from pyquery import PyQuery as pq
import xml.dom.minidom as dom

import chardet 

class HtmlParser():
    '''
    从html中提取出相关tag
    '''
        
    def init(self,html):
        self.d=pq(html)
    
    def get_a(self):
        '''
        返回 url 的字典 name:url
        '''
        a=self.d('a')
        aa={}
        for i in range(len(a)):
            aindex=a.eq(i)
            aa.setdefault(aindex.text(),aindex.attr('href'))
        return aa
    
    def get_as(self):
        '''
        返回 a文本
        '''
        print 'get_as running'
        a=self.d('a')
        text=''
        urls=''
        for i in range(len(a)):
            aindex=a.eq(i)
            #print aindex.text()
            text+=aindex.text()+' '
            if aindex.attr('href'):
                urls+=aindex.attr('href')+' '
        return [text,urls]
            
    def get_url(self):
        '''
        返回所有url的list
        对于理学院的网页 frame 的结构 加入了对iframe的提取
        '''
        a=self.d('a')
        aa=[]
        for i in range(len(a)):
            aindex=a.eq(i)
            href=aindex.attr('href')
            aa.append(href)
        frame=self.d('frame')
        for i in range(len(frame)):
            aindex=frame.eq(i)
            aa.append(aindex.attr('src'))
        return aa
        
    def get_node(self,node):
        b=self.d(node)
        bb=[]
        for i in range(len(b)):
            bb.append(b.eq(i).text())
        return bb

class Collector(HtmlParser):
    '''
    从html中提取相信息
    '''
    def get_nodes(self,node):
        '''
        提取标签文本
        适用于  title b h1 h2 h3 等标签
        '''
        nodes=self.get_node(node)
        text=''
        for n in nodes:
            text+=n
        return text
    
    def get_content(self):
        '''
        提取html中主内容
        '''
        #去除无用标签
        self.clear_other_node()
        return self.d('html').text()
    
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
        
    def trans_d(self,raw_url,rawurls):
        '''
        对获得url进行分析
        满足条件：
            在 home_url列表范围内
            转化为绝对地址
        '''
        urltest=Urltest() 

        while True:
            if len(rawurls)>0:
                item=rawurls.pop()
            else:
                break
            if (item == None)or(len(item)<3):   
                break  
            if item[0:4] == '\r\n':   
                item = item[4:]   
            if item[-1] == '/':   
                item = item[:-1]   
            #ipurl
            #change url to direct url
            #already direct url
            if len(item) >= len('http://') and item[0:7] == 'http://':
                for homepage in self.home_urls: 
                    #change wheather it is a subpage
                    length=len(homepage)
                    if len(item) >= length and item[0:length] == homepage:   
                        if self.list.find(item) == False:   
                            self.inqueue.put(item)   
                        break
                continue #return to while
            if item[0:5] == '/java' or item[0:4] == 'java':   
                pass
            else:
                if item[0:3]=='../':
                    item=self.urltest.absUrl(raw_url,item)
                elif item[0] != '/':   
                    item = '/' + item   
                    item = raw_url+ item   
                elif item[:2]=='./':
                    item=raw_url+item[2:]
                if self.list.find(item) == False:   
                    self.inqueue.put(item) 
        

if __name__=='__main__':
    html=pq(url='http://www.cau.edu.cn')
    htmlc=Collector()
    htmlc.init(html.html())
    ass=htmlc.get_as()
    print 'the b is --------------------------'
    print htmlc.get_nodes('b')
    
 
   
    
    
    
    
    
    
    
        
