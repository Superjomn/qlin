#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
reload(sys)
sys.setdefaultencoding('utf-8')

from pyquery import PyQuery as pq
#from parser.wordlist import wordList as wordlist
import chardet
import re
from parser.collector import collector
from ICTCLAS50.Ictclas import Ictclas
import os
import parser.Thes as Thes
import sqlite3 as sq 
#路径管理
from query.path import path


class Parser:
    '''
    解析库
    将下载后的html源码同时转化为document 返回
    部分功能嵌入到spider中
    
    '''
    def __init__(self,site_id):
        '''
        初始化各项目录
        '''
        self.path = path(site_id)

        self.ict=Ictclas('ICTCLAS50/') 
        #self.wordbar=wordlist()#wordBar
        self.spword='@chunwei@' 
        
        self.xmlph=self.path.g_document()
        self.wsplitph=self.path.g_wordsplit()
        self.wbpath=self.path.g_wordbar()

        #初始化词库 
        self.wordbar = Thes.Create_Thesaurus(self.wbpath)

        #数据库相关
        self.cx = sq.connect(self.path.g_chun_sqlite())
        self.cu = self.cx.cursor()


    def splitWord(self):
        '''
        转化为 wordsplit形式
        格式为 <dom str> @chunwei@ <dim str>
        直接使用了字符串进行分割
        '''
        spword='@chunwei@'
        docli=os.listdir(self.xmlph+'/')
        num=0
        for dp in docli:
            #print dp

            f=open(self.xmlph+'/'+dp)
            c=f.read()
            if len(c)<200:
                continue 
            root=pq(c)
            f.close()
            
            bb=''
            title=root('title').eq(0)
            bb+=self.ict.split( title.attr('text').encode('utf-8'))+' '
            bb+=spword

            b=root('b item')
            length=len(b)
            for i in range(length):
                bb+=self.ict.split( b.eq(i).attr('text').encode('utf-8'))+' ' 
            bb+=spword
            #h1
            b=root('h1 item')
            length=len(b)
            for i in range(length):
                bb+=self.ict.split( b.eq(i).attr('text').encode('utf-8') )+' '    
            bb+=spword
            #h2
            b=root('h2 item')
            length=len(b)
            for i in range(length):
                bb+=self.ict.split( b.eq(i).attr('text').encode('utf-8') )+' '    
            bb+=spword
            #h3
            b=root('h3 item')
            length=len(b)
            for i in range(length):
                bb+=self.ict.split( b.eq(i).attr('text').encode('utf-8') ) +' '
            bb+=spword
            #a
            b=root('a item')
            length=len(b)
            for i in range(length):
                self.ict.split( b.eq(i).attr('name').encode('utf-8') )+' '
            bb+=spword
            #content
            content=root('content').eq(0)
            #print 'the content is '
            #print content.text()
            bb+=self.ict.split( content.text().encode('utf-8'))+' '
            #print 'the bb is'
            #print bb
            #save the result'''
            f=open(self.wsplitph+'/'+dp,'w+')
            f.write(bb)
            f.close()

    def __wordFind(self,strr):
        #print strr
        words=strr.split()
        flag=re.compile('\d')
        for i in words:
            if len(i)<=10:
                if i.find('=')>-1:
                    continue
                if i.find('.')>-1:
                    continue
                if flag.search(i):
                    continue
                self.wordbar.find(i)

    def transWbar(self):
        '词库初始化'
        li=os.listdir(self.wsplitph)
        for xml in li:
            f=open(self.wsplitph+'/'+xml)
            c=f.read()
            f.close()   
            
            for i in c.split(self.spword):
                self.__wordFind(i)

            #print 'begin to find des'
            '''for i in self.get_split_des_words(xml):
                self.__wordFind(i)
            '''
                
        strr=''
        #for i in self.wordbar.li:
            
            #strr+=i+' '

        f=open(self.wbpath,'w')
        f.write(self.wordbar.get_words())
        f.close()
        
        print 'begin to create hash'

        self.wordbar.create_hash(self.path.g_hash_index())

        self.wordbar.save_wide(self.path.g_word_wide())


    def get_split_des_words(self,docID):
        
        '''
        添加 des 的 hash
        '''
        self.cu.execute("select des from lib where docID = %d"%int(docID))

        li= self.cu.fetchone()

        if li[0]:
            return self.ict.split( str(li[0]) ).split()
        else:
            return ['']
        

    def _debug(self):
        f=open(self.wbpath)
        c=f.read()
        for i in c.split():
            print i,hash(i)

if __name__=='__main__':
    p=Parser(1)
    #p.transDoc()
    #p.splitWord()
    p.transWbar()
    #p._debug()
