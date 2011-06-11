from query.query import Query

import sqlite3 as sq

#前后命中的scope
DEF Scope = 30


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
        ###print 'get page_id',page_id

        #print 'search for',strr
        self.res = {}
        
        cdef object query_res=self.find(strr,page_id)
        #print 'get res',query_res

        if not query_res:
            return False

        #开始取得wordid参考 {1:'hello',2:'word'}
        word_id_res = query_res['word_id_res']
        ###print 'get word_id_res',word_id_res

        #未命中的 ranks
        ranks = query_res['ranks']

        cdef int length = query_res['length']

        self.res.setdefault('length',length)
        
        res_li = []

        for i,docid in enumerate(query_res['docIDs']):
            #print 'now get ',docid
            #取得 des
            deses = []

            self.cu.execute("select title,des,intro,url from lib where docID =%d"%docid)

            res=[]
            hits = self.cu.fetchone()
            
            ########################################################
            #
            #       开始 对 des 进行处理
            #
            ########################################################
            hi_title = word_id_res[ ranks[i]  ]

            res.append(self.add_hi(hits[0]) )
            res.append(self.add_hi(hits[1]) )
            res.append(  self.hi_des(hits[2] ,hi_title)  )
            res.append(hits[3])
            
            if len(hits[3])>40:
                res.append(hits[3][:40]+'...')
            else:
                res.append(hits[3])




            res_li.append(res)

        self.res.setdefault('res_list',res_li)



        return self.res


    cdef add_hi(self,text):

        '''
        添加高亮显示
        '''
        for w in self.query.get_words():
            #print 'now replace',text
            text=text.replace(w,'<span class="hi">'+w+'</span>')
        return text


    cdef hi_des(self,des,hi_title):
        '''
        对 des 结果 添加高亮
        传入 des   及需要高亮的 title
        '''
        cdef:
            int index
            int length

        index = des.find(hi_title)
        length = len(des)

        
        if index != -1:
            #命中
            ###print 'index != -1'
            if index -Scope >0:
                #可以命中
                if index + Scope <length:
                    #全部命中
                    return '...' + self.add_hi( des[index-Scope : index +\
                    Scope] ) + '...'

                else:
                    #末尾超出
                    return '...'+ \
                    self.add_hi( des[index-Scope :] ) +'...'
            else:
                #头部超出
                if index + Scope <length:
                    #全部命中
                    return '...' + self.add_hi(des[ : index + Scope])+'...'
                else:
                    #头部超出 末尾超出
                    return  self.add_hi(des)
        else:
            if length > 28:
                return self.add_hi( des[:27] ) + '...'
            else:
                return self.add_hi(des)
                    



























