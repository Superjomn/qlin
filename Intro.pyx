# -*- coding: utf-8 -*-
import sys
reload(sys)
sys.setdefaultencoding('utf-8')

from query.intro import Query

from query.path import path

import sqlite3 as sq

cdef class Intro:
    '''
    搜索提示实现
    '''
    cdef object q
    cdef object cu
    cdef object cx
    #路径管理
    cdef object path

    def __cinit__(self,int site):
        '''
        init
        '''
        #路径管理
        self.path = path(site)

        self.q= Query(site)

        self.cx = sq.connect(self.path.g_chun_sqlite())

        self.cu = self.cx.cursor()


    def query(self,char *para):
        '''
        查询主程序
        '''
        cdef:
            int i
            object wordsli
            #在词中命中
            object hits
            object res
            object intros
            #运行中间两
            object strr
            
        #最终返回结果
        intros = []
        res = self.q.get_res(para)
    
        if res:
            for docid in res['docIDs']:
                strr = ''
                wordsli = self.get_des_title(docid)
                intros.append(wordsli) 


        return intros
        
    def get_des_title(self,docID):
        '''
        取得des
        '''
        self.cu.execute("select des from lib where docID = %d"%docID)

        li= self.cu.fetchone()
        if li:
            #print 'get des',li[0]
            return li[0]
        else:
            return ''



