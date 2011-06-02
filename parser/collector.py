# -*- coding: utf-8 -*-
import sys
reload(sys)
sys.setdefaultencoding('utf8')

from pyquery import PyQuery as pq
import xml.dom.minidom as dom

import reptile.Urltest as urltest
import parser.HtmlParser
import re
import sys

#是否有必要将爬虫和收集器集合起来，进行处理
#爬虫下载后，同时进行解析
class collector():

    '''
    从html中提取相关tag内容
    '''

    def init(self,html):
        
        '''
        init
        '''

        self.html=html
        self.d=pq(html)
        self.d('script').remove()
        self.d('style').remove()
        
        self.urltest=urltest.Urltest()
        self.collector=parser.HtmlParser.Collector()
        self.collector.init(html)
        
               
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
        self.d('style').remove()
        self.d('script').remove()


    def xml(self,tem_home):

        '''
        返回xml源码
        '''

        #self.transurl.setTemHomeUrl(docID) #确定tem_home_url
        
        str='<html></html>'
        titleText=self.d('title').text()
        self.dd=dom.parseString(str)
        #print self.dd
        html=self.dd.firstChild
        #生成title
        
        title=self.dd.createElement('title')
        html.appendChild(title)
        title.setAttribute('text',titleText)

        #生成b
        bb=self.collector.get_node('b')
        b=self.dd.createElement('b')

        for i in bb:

            ii=self.dd.createElement('item')
            ii.setAttribute('text',i)
            b.appendChild(ii)

        html.appendChild(b)

        #生成h1
        bb=self.collector.get_node('h1')
        b=self.dd.createElement('h1')

        for i in bb:

            ii=self.dd.createElement('item')
            ii.setAttribute('text',i)
            b.appendChild(ii)

        html.appendChild(b)

        #生成h2
        bb=self.collector.get_node('h2')
        b=self.dd.createElement('h2')

        for i in bb:

            ii=self.dd.createElement('item')
            ii.setAttribute('text',i)
            b.appendChild(ii)

        html.appendChild(b)

        #生成h3
        bb=self.collector.get_node('h3')
        b=self.dd.createElement('h3')

        for i in bb:
            ii=self.dd.createElement('item')
            ii.setAttribute('text',i)
            b.appendChild(ii)

        html.appendChild(b)

        #生成a
        aa=self.collector.get_a()
        a=self.dd.createElement('a')

        for i in aa:

            #i=self.transurl.trans_d(i) #对url转化为标准绝对地址
            #取得url 对其进行判断  
            #如果判断合格 则建立 url 到document中  否则 不建立文件
            url=aa[i]
            print 'get url ',url
            print 'begain to transfer'
            url=self.urltest.abs_url_trans(tem_home, url)

            if url:
                aindex=self.dd.createElement('item')
                aindex.setAttribute('name',i)
                #aindex.setAttribute('href',self.a_trav(aa[i]))
                aindex.setAttribute('href',url)
                a.appendChild(aindex)

        html.appendChild(a)
        #加入content

        print '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
        print self.d.html()
        
        print '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'

        htmltext=self.d.html()#.decode('gbk','ignore').encode('utf-8')
        
        #print '----------------------------------------->>>>>>>>>>>>>>>'
        #print htmltext
        #print '----------------------------------------->>>>>>>>>>>>>>>'

        ht=pq(htmltext)
        #bug 说明
        #此处  需啊注意 其中有html的特殊字符   &# 等等
        #在分词的时候另外说明
        content=ht.text()

        cc=self.dd.createElement('content')

        ctext=self.dd.createTextNode(content)

        #print '----------------'
        #print content
        #print '----------------'

        cc.appendChild(ctext)
        html.appendChild(cc)
        #print self.dd.toprettyxml()
        return self.dd

if __name__=='__main__':
    html=pq(url='http://www.cau.edu.cn')
    c=collector()
    c.init(html.html())
    f=open('1.xml','w')
    document=c.xml('http://www.cau.edu.cn').toxml()
    f.write(document)
