# -*- coding: utf-8 -*-
import sys
reload(sys)
sys.setdefaultencoding('utf-8')

from pyquery import PyQuery as pq

from ICTCLAS50 import Ictclas

from index.urlbar import urlbar

import sqlite3 as sq

import os

import re

#一些常量
Str_size = 100

class Title_des_sqlite:
    
    '''
    将 title des 整合到 sqlite 中
    '''
    def __init__(self):
        
        '''
        init
        '''

        #临时性设计 需要过滤无用字符

        self.str_test = re.compile("(\w|=|'|&|:)")


        self.length = 0


        self.cx = sq.connect('store/chun.sqlite')
        self.cu = self.cx.cursor()

        self.ict=Ictclas.Ictclas('ICTCLAS50/') 

        self.urlbar = urlbar('store/sorted_url.txt')


    def stest(self,text):

        '''
        过滤无用字符
        '''
        return self.str_test.sub('',text)


    def add_title(self,docID,title):
        
        '''
        添加 title
        '''
        print "insert into lib values(%d,'%s','%s','%s','%s','%s')"%(docID,title,'','','','')

        return self.cu.execute("insert into lib values(%d,'%s','%s','%s','%s','%s')"%(docID,title,'','','','') )


    

    def add_url(self,docID,url):
        
        '''
        添加 url
        '''
        self.cu.execute("update lib set url= '%s' where docID = %d"%(url,docID))


    def add_content(self,docID,content):

        '''
        添加 content 
        '''
        self.cu.execute("update lib set intro= '%s' where docID = %d"%(content,docID))


    def get_des(self,docID):
        '''
        取得des
        '''
        self.cu.execute("select des from lib where docID = %d"%docID)

        li= self.cu.fetchone()
        if li:
            print 'get des',li[0]
            return li[0]
        else:
            return ''

    def get_title(self,docID):
        '''
        取得des
        '''
        self.cu.execute("select title from lib where docID = %d"%docID)

        li= self.cu.fetchone()
        if li:
            print 'get des',li[0]
            return li[0]
        else:
            return ''





    def add_url(self,ph):
        '''
        将url 加载进 数据库中
        '''
        f=open(ph)
        lines = f.readlines()
        f.close()
        
        for i,l in enumerate(lines):
            url = l.split()[1] 
            #print url
            self.cu.execute("update lib set url= '%s' where docID = %d"%(url,i))
        self.cx.commit()


    def update_des(self,docID,des):
        print 'add des',des
        self.cu.execute("update lib set des = '%s' where docID = %d"%(des,docID))


    def add_des(self,docID,des):
        
        '''
        添加 des
        #取得des  
        然后判断哪一个常一点
        取得较长的
        '''
        fdes = self.get_des(docID)
        print 'add des',des
        if des:
            if len(des) > len(fdes):
                self.update_des(docID,des)


    def split_des(self,des):
        
        '''
        将des 分词
        '''
        return self.icts.split(des)
        

    def add_split_des(self,docID,des):

        '''
        添加 分词后的des
        '''
        self.cu.execute("update lib set split_des = '%s' where docID =\
        %d"%(des,docID)  )



    def run(self):
        
        pagenum = len( os.listdir( 'store/document' ) )

        self.length = pagenum
        
        #################################
        #
        #   添加title  
        #
        #################################

        for i in range( pagenum ):
            
            print 'file:', 'store/document/'+str(i)
            try:
                f= open('store/document/'+str(i))
                c=f.read()
                f.close()
                root = pq(c)
            except:
                continue

            title = root('title').attr('text')
            title = self.stest(title)
            
            print 'get title:',title
            #添加 title
            print self.add_title(i,title)


        #################################
        #
        #   添加 缩略图
        #
        #################################

            content = root('content').text()
            content = self.stest(content)

            #仅仅添加 不到 100 个 
            if len(content) < 100:
                self.add_content(i,content)

            else:
                self.add_content(i,content)

        #数据库变动提交
        self.cx.commit()


        #################################
        #
        #   添加 des
        #
        #################################
        
        #在title添加初始化后
        #添加des
        for i in range( pagenum ):

            try:
                f= open('store/document/'+str(i))
                c=f.read()
                f.close()
                root = pq(c)

            except:
                continue

            #取得a
            #在每一个a中 查找a 对应的 des 及 docID
            aa = root('a item')

            aindex = 0

            for a in range( len(aa) ):
                aindex = aa.eq(a).attr('href')
                des = aa.eq(a).attr('name')
                des = self.stest(des)
                docid = self.urlbar.find(aindex)

                if docid:
                    #添加 des
                    print 'get docid',docid,des
                    self.add_des( docid,des)

        self.cx.commit()


    def split_des(self):
        
        '''
        将 所有 的des进行分词
        '''
        for i in range(self.length):
            des = self.get_des(i)
            des = self.ict.split(des)
            self.add_split_des(i,des)

    
    def intro_split_des_title(self):
        '''
        将title des 分词
        且变为不重复的分词序列后 传给数据库
        作为 intro 的参考
        '''
        f=open('store/sorted_url.txt')
        lines= f.readlines()
        f.close()
        self.length = len(lines)
        print 'the length is ',self.length
        for docid in range(self.length):
            print '-'*50
            print docid
            des = str(self.get_des(docid))
            print 'des',des
            title = str(self.get_title(docid))
            print 'title',title
            print self.ict.split('你好中国')
            print 'the title>>>'
            print des,title
            a  = self.ict.split(des).split()
            b  = self.ict.split(title).split()
            c = list(set(a+b))
            print 'c',c
            strr = ''
            for i in c:
                strr += i+' '
            #存储到数据库
            self.add_split_des(docid,strr)



                

if __name__ == '__main__':
    
    doc = Title_des_sqlite()
    doc.run()
    #doc.add_url('store/sorted_url.txt')
    #doc.split_des()
    doc.intro_split_des_title()
    doc.cx.commit()


    

