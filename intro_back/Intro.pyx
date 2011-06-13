# -*- coding: utf-8 -*-
import sys
reload(sys)
sys.setdefaultencoding('utf-8')

from query.intro import Query

import sqlite3 as sq

cdef class Intro:
    '''
    搜索提示实现
    '''
    cdef object q
    cdef object cu
    cdef object cx

    def __cinit__(self):
        '''
        init
        '''
        self.q= Query()

        self.cx = sq.connect('store/chun.sqlite')

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
        print 'get res',res

        for docid in res['docIDs']:
            strr = ''
            wordsli = self.get_des_title(docid)
            print 'get words'
            '''
            for w in res['words']:
                print w
            #在词组中进行命中
            print 'whole:',whole
            hits = []

            whole = range(len(wordsli))

            for w in res['words']:
                print 'w',w
                print wordsli.index(w) 
                hits.append(wordsli.index(w))
                print 'hits',hits
                
            print '-'*50

            for t in hits:
                print 'i',t
                print 'whole',whole
                whole.remove(t)

            if len(whole)>1:
                hits.append(whole[0])
                hits.append(whole[-1])

            else:
                hits.append(whole[-1])

            #将hits进行排序
            hits.sort()
            
            
            for i in hits:
                strr += wordsli[i]+' ' 
            '''

            intros.append(wordsli) 

        return intros
        


    def get_des_title(self,docID):
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



