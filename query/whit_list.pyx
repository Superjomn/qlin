from parser.Init_Thes import Init_thesaurus , init_hashIndex

from libc.stdlib cimport realloc,malloc,free

from libc.stdio cimport fopen, fwrite, fread,fclose,FILE 

from ICTCLAS50.Ictclas import Ictclas


DEF List_num = 20         #hit_lists中划分 块 数目


'''
算法：
    定位到 wordid
    返回每个docid的第一个记录
    
    再查找第二个词及以上时
    直接在wordid中扫描原有docid
    如果存在 加上score 否则 将原有记录刷新为0（表示放弃此docid)
    
    一直到最后 整理结果
    进行排序
    返回结果
'''


#定义 Hit 结构
cdef struct Hit:
    int wordID
    int docID
    short score
    int pos

#查询时 存储队列
#此处score未加以存储    不可以直接继承
#直接计算其权质
cdef struct Whit:
    int docID
    int pos         #可以直接比较位置
    float rank      #得分

#为了方便父亲和子类间信息交流
#定义whit_list 结构定义
cdef struct WhitList:
    int length
    int top
    int empty #无效记录的数目
    Whit *whit


DEF Whit_init_num = 100  
DEF Whit_add  =    30

####################################
#       在扫描过程中同时计算rank
#       计算 权值
####################################
DEF SCORE_EACH = 1

DEF SCORE_TITLE = 0
DEF SCORE_B = 1
DEF SCORE_H1 = 2
DEF SCORE_A = 5
DEF SCORE_CONTENT = 6

cdef inline float sc(int score):

    '''
    计算权值
    '''
    if score == SCORE_TITLE:
        return 5
    elif score ==SCORE_B:
        return 2.5
    elif score >= SCORE_H1 and score <= SCORE_H1 + 2:
        return 2.5
    elif score == SCORE_A:
        return 1
    elif score == SCORE_CONTENT:
        return 2
    return 0
    


cdef class Whit_list:

    '''
    whit list
    管理程序
    '''

    cdef WhitList *hit_list

    #扫描时 索引
    cdef int scan_id 

    #公用 wid

    def __cinit__(self,int wid):

        '''
        init
        '''
        self.scan_id = 0
    
        self.wid = wid


        
    cdef init(self,WhitList *whit_list):

        '''
        c语言层面的init
        '''
        #引用方式传递 直接修改直
        self.hit_list = whit_list

        #若whit_list　内存未分配
        #则进行分配 
        if self.hit_list.whit == NULL:
            print 'the whit_list is empty'
            print 'begin to malloc'

            self.hit_list.whit = <Whit *>malloc( Whit_init_num * sizeof(Whit) )
            self.hit_list.top = -1
            self.hit_list.length = Whit_init_num
            self.hit_list.empty = 0 #初始时无效记录数目为0 



    cdef void  append(self, Hit hit):
        
        '''
        append 
        在初始化wlist时候使用
        将 hit_list 自动加入到 whit_list中
        '''
        cdef Whit *base
        
        self.hit_list.top += 1
        self.hit_list.whit[self.top].docID = hit.docID
        self.hit_list.whit[self.top].pos = hit.pos

        #计算权质
        self.hit_list.whit[self.top].rank += sc(hit.score)# * SCORE_EACH    
        
        if self.hit_list.top > self.hit_list.length - 2:
            #重新分配
            base = <Whit *> realloc( self.hit_list.whit , sizeof(Whit) * (self.hit_list.length + Whit_add) )

            if base != NULL:
                self.hit_list.whit = base
                self.hit_list.length += Whit_add


    cdef short add(self,Hit hit):

        '''
        将剩余词汇添加到总hit_list记录中
        包括判断
        主程序 将所有单独docID载入其中
        add 将会自动过滤和判断
        如果外部docID不统一 将rank指为-1
            表明此记录作废
        ''' 

        #采用渐次扫描算法
        #外界逐次扫描
        #同时内部也逐步扫描
        cdef:
            int j
            int cur_did

        #去除无用记录 
        while self.hit_list.whit[self.scan_id].rank ==-1 and self.scan_id <= self.hit_list.top:
            #过滤无用记录　rank==-1
            self.scan_id += 1

        #一直到最后都是 -1
        if self.scan_id > self.hit_list.top:
            return 2

        cur_did = self.hit_list.whit[self.scan_id].docID
        
        #首次某种
        if hit.docID > self.hit_list.whit[self.hit_list.top].docID:
            #docID超过内部最大限度
            #不需要继续扫描下去
            return 2  

        if hit.docID == cur_did:
            self.hit_list.whit[self.scan_id].rank += sc(hit.score)# * SCORE_ADD
            self.scan_id += 1

            return 0

        elif hit.docID > cur_did:
            #外围已经超过　说明当前记录未命中
            self.hit_list.whit[self.scan_id].rank = -1
            #无效记录数目 + 1
            self.hit_list.empty += 1
            self.scan_id += 1
            #内部 scan_id 过小
            return 1

        else:
            #外界 scan_id 过小
            return -1


    cdef void init_scanID(self):

        '''
        一轮扫描完毕
        self.scan_id清０
        '''
        self.scan_id = 0
            


