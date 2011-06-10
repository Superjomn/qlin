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
        object ict
        object words

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

        #print 'search for',strr
        self.res = {}
        
        cdef object query_res=self.find(strr,page_id)
        #print 'get res',query_res

        if not query_res:
            return False

        cdef int length = query_res['length']

        self.res.setdefault('length',length)
        
        res_li = []
        for docid in query_res['docIDs']:
            #print 'now get ',docid
            #取得 des
            deses = []

            self.cu.execute("select title,des,intro,url from lib where docID =%d"%docid)
            #开始取得wordid





            res=[]
            hits = self.cu.fetchone()

             

            res.append(self.add_hi(hits[0]) )
            res.append(self.add_hi(hits[1]) )
            res.append(hits[2])
            res.append(hits[3])

            res_li.append(res)

        self.res.setdefault('res_list',res_li)

        return self.res

    cdef add_hi(self,text):
        for w in self.query.get_words():
            #print 'now replace',text
            text=text.replace(w,'<span class="hi">'+w+'</span>')
        return text


