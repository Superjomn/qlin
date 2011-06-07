# -*- coding: ISO-8859-15 -*-

##################################################
#
#       Query: 查询库
#       qlin 内网全文搜索引擎
#       Created by Chunwei
#           in memory of a friend 
#               Best Wishes to Lavender!
#
##################################################

from parser.Init_Thes import Init_thesaurus , init_hashIndex

from libc.stdlib cimport realloc,malloc,free

from libc.stdio cimport fopen, fwrite, fread,fclose,FILE 

from ICTCLAS50.Ictclas import Ictclas

import chardet as cdt

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
    int scan_id
    #左右范围
    int left
    int right
    #现在 wid
    int wid
    Whit *whit


#hitlist 
cdef struct HitList:
    int length
    #每个文件的hit数量
    int width[List_num]
    #内存中hit的id
    int cur_id
    Hit *hit


#最终整理过的结果整理结构
cdef struct PackList:
    int length
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



####################################
#       前台相关 
#       搜索中 或者 与 django交互 
####################################

#每页显示结果数目
DEF Page_each = 8

# init_hashIndex
DEF Hash_index = 'store/index_hash.b'
DEF Hash_word_wide = 'store/word_wide.txt'
# init_Thes
DEF Wordbar = 'store/wordBar'

DEF Width_ph = 'store/hits/hit_size.txt'



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


###############################
#
#   RankSorter
#     最终权值排序 
#
##############################
cdef class RankSorter:

    '''
	进行排序  使用cython进行优化
    '''
    cdef Whit *dali
    cdef int length
    
    cdef init(self,Whit *li,int length):

        '''
        init
        '''
        print 'sort init'
        print 'length',length
        self.dali = li
        self.length=length


    cdef float gvalue(self,Whit data):

        '''
		返回需要进行比较的值
        '''
        print 'sorting',data.rank
        return data.rank
        


    def quicksort(self,int p,int q):

        cdef int j
        st=[]

        while True:

            while p<q:

                j=self.partition(p,q)

                if (j-p)<(q-j):
                    st.append(j+1)
                    st.append(q)
                    q=j-1

                else:
                    st.append(p)
                    st.append(j-1)
                    p=j+1

            if(len(st)==0):
                return

            q=st.pop()
            p=st.pop()

            print 'quicksort q p',q,p


    cdef int partition(self,int low,int high):

        v=self.dali[low]

        print 'partition low,high',low,high

        while low<high:

            while low<high and self.gvalue( self.dali[high] ) >= self.gvalue( v ):

                high-=1

            self.dali[low]=self.dali[high]

            while low<high and self.gvalue( self.dali[low] )<=self.gvalue( v ):
                low+=1

            self.dali[high]=self.dali[low]

        self.dali[low]=v

    

    cdef void run(self):

        '''
        运行主程序
        '''
        print 'quicksort 0',self.length-1
        self.quicksort(0,self.length-1)



####################################
#   
#   单线程
#   query 主程序       
#
####################################
 

cdef class Query:
    
    '''
    尝试用一个类统一所有内存管理
    '''
    #数据
    cdef  WhitList wlist
    cdef  HitList  hlist
    cdef  PackList plist

    #管理对象
    cdef object hashIndex
    cdef object ict
    cdef object thes
    cdef RankSorter ranksort

    cdef:
        int wid
    
    def __cinit__(self):
        '''
        init
        '''
        ##########################################
        #wlist 初始化
        print 'wlist 初始化'

        self.wlist.whit = <Whit *>malloc(Whit_init_num * sizeof(Whit) )
        self.plist.whit = <Whit *>malloc(20 * sizeof(Whit))
        
        print 'init self.wlist malloc'
        self.wlist.top = -1
        self.wlist.length = Whit_init_num
        self.wlist.empty = 0
        #wlist 扫描id初始化
        self.wlist.scan_id = 0

        #########################################
        self.hlist.length = 0
        if self.hlist.hit == NULL:
            print '初始化时候 hlist 为空'

        #hlist 初始化
        self.hashIndex = init_hashIndex(Hash_index,Hash_word_wide)
        #初始化 width
        f=open( Width_ph)
        c=f.read()
        f.close()

        cdef:
            int i = 0

        #初始化 每个文件的hit数量
        for w in c.split():
            self.hlist.width[i] = int(w)
            i+=1

        #取得最大值
        maxl = self.hlist.width[0]
        for i in range(List_num):
            if self.hlist.width[i]>maxl:
                maxl=self.hlist.width[i]

        #开始为hit分配内存
        print '开始为hit_list分配内存'
        #**print '分配了最大的内存 hitlist',maxl
        self.hlist.hit = <Hit *>malloc( sizeof(Hit) * maxl)

        #初始化 hlist
        #self.hlist.length = max(self.hlist.width)
        self.hlist.cur_id = -1 #表示初始化

        #########################################
        #相关对象初始化
        self.ict=Ictclas('ICTCLAS50/') 

        #词库
        self.thes=Init_thesaurus('store/wordBar')

        #排序
        self.ranksort = RankSorter()


    

    def init_hit_file(self,hashvalue):

        '''
        通过 hashvalue 确定并且载入相应的hit文件内容
        '''

        #**print '314: get into init_hit_file'
        cdef int index = self.hashIndex.pos(hashvalue)
        cdef char *fn
        cdef FILE *fp

        #如果为同一个范围内word
        #不进行处理
        if index == self.hlist.cur_id:
            return 
        

        self.hlist.cur_id = index
        #载入新的文件内容

        ind=str(index) 

        '''if(self.hlist.hit!= NULL):
            print '329: bein free hlist'
            free(self.hlist.hit)
            print '329 succed free hlist'
            '''

        print '335: begin malloc hlist'
        #**print '340: hit length',self.hlist.width[index]

        #self.hlist.hit = <Hit *> malloc(sizeof(Hit) * self.hlist.width[index] )
        #**print 'self.list is right'

        fname = 'store/hits/' + ind + '.hit'
        
        fn = fname

        #**print '345: the fname is',fn

        fp=<FILE *>fopen(fn,"rb")
        #**print '开始赋值'
        #**print 'hello'
        fread(self.hlist.hit, sizeof(Hit), self.hlist.width[index] ,fp)
        fclose(fp)
        #**print '370 成功分配'

        #负值hit_list长度
        self.hlist.length = self.hlist.width[index]



    cdef inline short pos_mid_wid(self):

        '''
        利用二分发确定wid的大概位置
        '''
        cdef:
            int fir
            int mid
            int end

        fir = 0
        mid = 0
        end = self.hlist.length-1

        while fir<end:
            mid = (fir+end)/2
            if self.wlist.wid > self.hlist.hit[mid].wordID:
                fir = mid+1

            elif self.wlist.wid < self.hlist.hit[mid].wordID:
                end = mid-1

            else:
                break

        if fir == end:
            if self.hlist.hit[fir].wordID != self.wlist.wid:
                #wid在文件中不存在
                return 0

            else:
                return mid

        elif fir>end:
            return 0

        else:
            return mid


    cdef void pos_wid_scope(self):

        '''
        确定wid在hit列表中范围
        需要另外的wid的hash表支持
        '''
        cdef:
            int i
            int j

        print 'get into pos'

        i=self.pos_mid_wid()


        print 'get mid wid',i
        
        j=i

        while j>=0:
            if self.hlist.hit[j].wordID == self.wlist.wid:
                j -= 1
            else:
                break

        self.wlist.left= j+1

        print 'get left',self.wlist.left
        
        
        while i<=self.hlist.length-1:
            if self.hlist.hit[i].wordID == self.wlist.wid:
                i += 1
            else:
                break

        self.wlist.right= i-1
        print 'get right',self.wlist.right


    cdef void init_whit_list(self):

        '''
        从第一个词开始
        首次初始化whit空间
        以后的词均在此空间内进行过滤便可
        '''
        #print '+hit_list - init_whit_list'
        print '初始化whit'

        cdef:
            #当前搜索的did
            #只第一个did有效
            int cur_did
            int i       #hit_list的index
            int j       #whit_list的index

        #确定wid边界
        #self.pos_wid_scope()
        #初始时 cur_did 故意不同
        '''
        if self.wlist.whit == NULL:
            self.wlist.whit = <Whit *>malloc(Whit_init_num * sizeof(Whit) )
        '''

        cur_did = self.hlist.hit[self.wlist.left].docID - 1
        

        i=self.wlist.left
        #初始化第一个did
        while i<=self.wlist.right:
            #扫描整个　wid　字段
            if self.hlist.hit[i].docID == cur_did:
                pass

            else:
                print '- whit_list append',cur_did
                self.append(self.hlist.hit[i])
                cur_did = self.hlist.hit[i].docID

            i+=1

        #self.whit_list.show()



    cdef void find(self,char *word):

        '''
        查找词主程序
        在 init_whit_list 完成后
        默认　已经存在一个word记录
        '''
        
        print '这次 find 的 scan_id',self.wlist.scan_id
        print 'find> begin find the word',word


        cdef:
            double hashvalue
            int hash_file_id
            #特定wid的起始坐标
            #需要 wid hash表的支持
            int widstart
            int widend

        #确定wid对应字段范围
        #此处需要确定　wid
        print 'get wid',self.wlist.wid
        #**print 'hello 491'
        
        self.pos_wid_scope()
        #**print 'hello'

        print 'get word scope',self.wlist.left,self.wlist.right


        #自动初始化
        #wlist 为本地取得的 whit_list 的一个副本
        #标志为 self.whit_list.top==-1
        if self.wlist.top == -1:
            #此处需要确定　wid !!!!?????????????????????
            #**print '开始初始化 wlist in wlist'
            #**print '从find进入 init)whit_list'
            self.init_whit_list()
            #**print 'succeed init_whit_list'
            return

        #开始遍历 对did进行处理
        cdef:
            int i
            int cur_did
            int res

        i=self.wlist.left

        #为了对第一个hit_list进行处理
        #估计改变cur_did
        cur_did=self.hlist.hit[i].docID - 1
        print 'cur_did is',cur_did+1
         
        while i <= self.wlist.right:
            #在wid内进行遍历
            print 'search hit',i,self.hlist.hit[i].wordID, self.hlist.hit[i].docID
            if self.hlist.hit[i].docID == cur_did:
                pass
            else:
                #传入i 便于判断修改
                res = self.add(self.hlist.hit[i],i)
                cur_did = self.hlist.hit[i].docID
                
                print 'add',cur_did
                print '结果为',res

                if res == -3 or res == -2 or res == 2:
                    # -3:切头内大   -2:晴空 外大   2:常规溢出
                    break
                

            i+=1
    
        #whit_list 的 scanID 清 0
        #比scanid 大的list 表明 无法命中
        #需要清0处理
        self.greater_scanID()

        self.init_scanID()


    cdef void greater_scanID(self):

        '''
        有word未全部命中
        在 scanid 上面的全部削去
        但是 中间会有松散的不合格
        add中也需要做修改
        '''

        while self.wlist.scan_id <= self.wlist.top:
            if self.wlist.whit[self.wlist.scan_id].rank != -1:
                self.wlist.whit[self.wlist.scan_id].rank = -1
                self.wlist.empty += 1
            self.wlist.scan_id += 1

    cdef void  append(self, Hit hit):
        
        '''
        append 
        在初始化wlist时候使用
        将 hit_list 自动加入到 whit_list中
        '''
        print 'append',hit.wordID,hit.docID
        cdef Whit *base
        cdef:
            int i
        
        self.wlist.top += 1
        self.wlist.whit[self.wlist.top].docID = hit.docID
        self.wlist.whit[self.wlist.top].pos = hit.pos

        #计算权质
        #初始化时  直接赋值

        self.wlist.whit[self.wlist.top].rank = sc(hit.score)
        
        if self.wlist.top > self.wlist.length - 2:
            #重新分配
            #**print '开始添加分配 wlist 内存 relloc'

            base = <Whit *> realloc( self.wlist.whit , sizeof(Whit) * (self.wlist.length + Whit_add) )

            if base != NULL:
                self.wlist.whit = base
                self.wlist.length += Whit_add
            else:
                print 'realloc wrong'
            
            #**print '分配realloc成功'

        #print 'firstly get length %d in append'%self.wlist.top


    cdef short add(self,Hit hit,int i):

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
        
        #**print 'add',hit.docID
    
        cdef:
            int j
            int cur_did

        print 'add 里面 的 scan_id',self.wlist.scan_id

        print '> hit and index',i,hit.docID,hit.wordID
        print '> now scan_id_docID',self.wlist.whit[self.wlist.scan_id].docID

        #去除无用记录 
        while self.wlist.whit[self.wlist.scan_id].rank ==-1 and self.wlist.scan_id <= self.wlist.top:
            #过滤无用记录　rank==-1
            self.wlist.scan_id += 1

        cur_did = self.wlist.whit[self.wlist.scan_id].docID

        print 'now wlist cur  docID is',cur_did

        #一直到最后都是 -1
        if self.wlist.scan_id > self.wlist.top:
            return 2
        
        #外界都比内部大
        if i == self.wlist.left and hit.docID > self.wlist.whit[self.wlist.top\
            ].docID:
            self.wlist.empty = self.wlist.top + 1
            return -3

        if i == self.wlist.right and hit.docID < self.wlist.whit[ 0 ].docID:
            self.wlist.empty = self.wlist.top + 1
            return -3
        #左边可以工作 但右边不能完全屏蔽 
        #有辅助的greaterscanid
        
        #首次某种
        if hit.docID > cur_did:
            #docID超过内部最大限度
            #不需要继续扫描下去
            #需要主动对齐
            while self.wlist.scan_id < self.wlist.top and self.wlist.whit[\
                self.wlist.scan_id + 1 ].docID <= hit.docID:
                #转到比 hit小的最后一个状态
                if self.wlist.whit[ self.wlist.scan_id ].rank != -1:
                    self.wlist.whit[ self.wlist.scan_id ].rank = -1
                    self.wlist.empty += 1
                self.wlist.scan_id += 1
            #现在 cur_docid >= hit

        #将 scan_id 更新一下
        while self.wlist.whit[self.wlist.scan_id].rank ==-1 and self.wlist.scan_id <= self.wlist.top:
            #过滤无用记录　rank==-1
            self.wlist.scan_id += 1

        if self.wlist.scan_id > self.wlist.top:
            return 2
        

        if hit.docID == self.wlist.whit[ self.wlist.scan_id ].docID :
            #**print 'hit cur_did equals',self.wlist.whit[ self.wlist.scan_id ].docID
            self.wlist.whit[self.wlist.scan_id].rank += sc(hit.score)# * SCORE_ADD
            self.wlist.scan_id += 1
            return 0

        else:
            #外界 scan_id 过小
            #让 其 增加 缩影
            return -1



            
    cdef init_scanID(self): 
        '''
        scan_id 清0
        '''
        self.wlist.scan_id = 0

    

    def find_words(self,char *para):
        '''
        直接对外接口
        '''
        cdef:
            object words
            int wid
            double hashvalue
        
        words = self.ict.split(para).split()
        print 'get words',words

        '''if self.wlist.whit != NULL:
            print '将wlist清空'
            free(self.wlist.whit)'''

        self.initData()

        for word in words:
            #对每个词进行处理
            wid = self.thes.find(word)
            print 'find',word,wid

            if wid == 0:
                return False
            print 'get wid',wid

            #开始根据wid进行查询
            self.wlist.wid = wid

            #更新 hit_list 内存
            hashvalue = hash(word)

            #**print '675: begin to init_hit_file'

            self.init_hit_file(hashvalue)

            #开始进行查找操作
            print 'find_words>begin to find',word
            print '此时 wlist.top:',self.wlist.top
            self.find(word)

    

            
    cdef short pack_res(self):
        '''
        将结果进行整理 
        便于排序
        '''

        if self.wlist.empty == self.wlist.top+1:
            #无有效结果
            return -1

        cdef:
            int length
            int i=0
            int index=0

        #结果有效长度
        length = self.wlist.top+1 - self.wlist.empty

        #消除之前结果
        '''
        if self.plist.whit != NULL:

            free(self.plist.whit)
        '''

        self.plist.whit = <Whit *> realloc(self.plist.whit,sizeof(Whit) * length)
        self.plist.length = length

        while index <= self.wlist.top:

            if self.wlist.whit[index].rank > -1:
                self.plist.whit[i] = self.wlist.whit[index]
                i+=1

            index += 1

        return length



    cdef void sort(self):

        '''
        将最终结果进行排序
        '''
        print 'get into sort'
        self.ranksort.init(self.plist.whit,self.plist.length)
        print 'init ok'
        self.ranksort.run()


    cdef void initData(self):

        '''
        晴空所有运行时内存
        准备下一次思索
        '''
        print '开始清理内存'

        #########################################
        #wlist 清理
        '''
        if self.wlist.whit != NULL:
            free(self.wlist.whit)
        '''

        self.wlist.length = 0
        self.wlist.top = -1
        self.wlist.empty = 0
        self.wlist.scan_id = 0
        self.wlist.left = 0
        self.wlist.right = 0
        self.wlist.wid = -1

        #########################################
        #plist 清理
        '''
        if self.plist.whit != NULL:
            free(self.plist.whit)

        if self.wlist.whit != NULL:
            free(self.wlist.whit)
        '''

        #self.plist.length = 0


    def get_res(self,char *para,int page_id):
        
        '''
        最终得到结果
        直接与前台django进行沟通
        仅仅返回docIDs
        返回数量及第n页的docIDs
        
        默认 page 从1 开始
        '''        
        print 'begin to get res'

        cdef:
            int page_start
            int page_end
            int length
            object res
            int i

        #查词操作
        self.find_words(para)
        
        if self.pack_res() == -1:
            return False

        ##plist 进行排序
        print '开始进行排序'
        #self.sort()
        print '排序完毕'

        ##########################################
        # 开始结果包装
        res = {}

        docIDs = []

        length = self.plist.length
        
        print '>> res get length',length

        if (page_id-1) * Page_each > length:
            return -1

        page_start = (page_id - 1) * Page_each
        page_end = page_id * Page_each

        if page_end > length-1:
            page_end = length -1

        
        i = page_start
        
        while i <= page_end:
            docIDs.append(self.plist.whit[i].docID)  
            i += 1

        res.setdefault('length',length)
        res.setdefault('docIDs',docIDs)

        #运行时态内存清理
        #**print '进行内存消除'
        self.initData()
        #print '此次思索结束 wlist.top',self.wlist.top
        print '-'*50
        print 'from query get res',res

        return res

    
    def __delloc__(self):
        print 'delete all C space'
        if self.wlist.whit != NULL:
            free(self.wlist.whit)

        if self.hlist.hit != NULL:
            free(self.hlist.hit)

 

