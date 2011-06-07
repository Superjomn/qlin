from query.query import Query

import sqlite3 as sq


cdef class Res_Query:
    
    '''
    前台连接主程序
    '''
    cdef:
        object query
        object cx
        object cu
        object res

    def __cinit__(self):
        
        '''
        init
        '''
        self.query = Query('store/hits','store/hits/hit_size.txt')

        self.cx = sq.connect('store/chun.sqlite')

        self.cu = self.cx.cursor()
        

    cdef object find(self,char *strr,int page_id):
        
        '''
        查找主程序
        '''

        return self.query.get_res(strr,page_id)


    def gres(self,char *strr,int page_id):

        self.res = {}
        
        cdef object query_res=self.find(strr,page_id)
        print 'get res',query_res

        if not query_res:
            return False

        
        cdef int length = query_res['length']

        self.res.setdefault('length',length)
        
        res_li = [] 
        for docid in query_res['docIDs']:
            print 'now get ',docid
            self.cu.execute("select title,des,intro from lib where docID =%d"%docid)
            res_li.append(self.cu.fetchone())

        self.res.setdefault('res_list',res_li)

        return self.res


        






        
