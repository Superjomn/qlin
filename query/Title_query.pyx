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
    Whit *whit


#最终整理过的结果整理结构
cdef struct Pack_res:
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
    cdef int wid

    def __cinit__(self):

        '''
        init
        '''
        self.scan_id = 0
    
        
    cdef init(self,WhitList *whit_list):

        '''
        c语言层面的init
        '''
        #引用方式传递 直接修改直
        self.hit_list = whit_list

        #若whit_list　内存未分配
        #则进行分配 
        if self.hit_list.whit == NULL:
            #print 'the whit_list is empty'
            #print 'begin to malloc'

            self.hit_list.whit = <Whit *>malloc( Whit_init_num * sizeof(Whit) )
            self.hit_list.top = -1
            self.hit_list.length = Whit_init_num
            self.hit_list.empty = 0 #初始时无效记录数目为0 


    cdef flush(self,int wid):

        '''
        刷新 wid
        '''
        self.wid = wid


    cdef show(self):

        '''
        展示结果
        '''
        print'+ whit_list -show begin to show the hitlist'
        cdef:
            int i

        for i in range(self.hit_list.top+1):

            print self.hit_list.whit[i].docID,self.hit_list.whit[i].rank


    cdef void  append(self, Hit hit):
        
        '''
        append 
        在初始化wlist时候使用
        将 hit_list 自动加入到 whit_list中
        '''
        cdef Whit *base
        cdef:
            int i
        
        #print '+ whit_list -append'
        
        self.hit_list.top += 1
        self.hit_list.whit[self.hit_list.top].docID = hit.docID
        self.hit_list.whit[self.hit_list.top].pos = hit.pos

        #计算权质
        #初始化时  直接赋值
        #print '+whit_list - append',self.hit_list.top,self.hit_list.whit[self.hit_list.top].docID

        self.hit_list.whit[self.hit_list.top].rank = sc(hit.score)# * SCORE_EACH    
        
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
    
        #print '+whit_list -add'

        cdef:
            int j
            int cur_did

        #print '+ whit_list - add'

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
            

            

           

        

################################
#
#   单个hit查找容器（包括doc)
#   返回查找到的docid
#   可以考虑多线程
#   得到结果回合到总数据容器中
#
################################

cdef class Hit_find:

    '''
    从hit中查取相应内容
    '''

    #whit 存储目录
    cdef char *fdir
    
    #当前 hit文件(避免重复载入)
    cdef int cur_hit_file

    #内存中参考 hit 存储队列
    cdef Hit *hit_list

    #hit 长度
    cdef int length

    #主程序公共查找结果操作池
    #whit_list 管理类
    cdef Whit_list whit_list

    cdef object hashIndex

    #为了对公共池足够的控制
    #本地取一个索引
    cdef WhitList *wlist

    #每个hit文件的长度
    cdef int width[List_num]

    #公用 wid
    cdef int wid

    #运行时相关变量
    cdef:
        #wid的边界
        int wleft_id
        int wright_id



    def __cinit__(self,char *fdir,char *width_ph):

        '''
        init
        hit_list: 父亲hit存储池
        '''
        #初始化hit地址
        self.fdir=fdir

        #初始化 hashIndex 便于判断 word该属于文件
        self.hashIndex = init_hashIndex("store/index_hash.b","store/word_wide.txt")

        #初始化width
        f = open(width_ph)
        c=f.read()
        f.close()

        cdef int i=0
        #初始化 每个文件的 hit 数量记录
        for w in c.split():
            self.width[i]=int(w) 
            i+=1


    cdef void init(self,WhitList *whit):

        '''
        c语言层面的 init
        '''
        #初始化 whit 运行时内存池
        #直接与父whit相同
        #结构体能否协调一直　需要测试!!!!!!!!!!!?????????????????????

        self.whit_list = Whit_list()
        self.whit_list.init(whit)
        #为了对 公共池 取得足够的控制 
        #本地取得一个索引副本
        self.wlist = whit


    cdef void flush(self,int wid):

        '''
        刷新wid
        '''
        self.wid = wid
        self.whit_list.flush(wid)



    cdef init_hit_file(self,hashvalue):
        '''
        通过 hashvalue 确定并且载入相应的hit文件内容
        '''
        cdef int index = self.hashIndex.pos(hashvalue)
        cdef char *fn
        cdef FILE *fp

        #如果为同一个范围内word
        #不进行处理
        if index == self.cur_hit_file:
            pass
        
        else:
            #载入新的文件内容
            ind=str(index) 
            if(self.hit_list != NULL):

                free(self.hit_list)

            #内存中单个hit文件
            #分配内存
            self.hit_list=<Hit *>malloc(sizeof(Hit) * self.width[index])

            #读入数据
            #print 'begin read the file'

            #fname = self.fdir +ind +'.hit'
            fname = 'store/hits/' + ind + '.hit'
            
            fn = fname

            #print 'the fname is',fn

            fp=<FILE *>fopen(fn,"rb")
            fread(self.hit_list , sizeof(Hit), self.width[index] ,fp)
            fclose(fp)

            #负值hit_list长度
            self.length = self.width[index]


    cdef inline short pos_mid_wid(self):

        '''
        利用二分发确定wid的大概位置
        '''
        self.wleft_id=0 #??????????????
        self.wright_id=0

        cdef:
            int fir
            int mid
            int end

        fir = 0
        mid = 0
        end = self.length-1

        while fir<end:
            mid = (fir+end)/2
            if self.wid > self.hit_list[mid].wordID:
                fir = mid+1

            elif self.wid < self.hit_list[mid].wordID:
                end = mid-1

            else:
                break

        if fir == end:
            if self.hit_list[fir].wordID != self.wid:
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

        i=self.pos_mid_wid()

        #print 'get mid wid',i
        
        j=i

        while j>=0:
            if self.hit_list[j].wordID == self.wid:
                j -= 1
            else:
                break

        self.wleft_id = j+1
        
        
        while i<=self.length-1:
            if self.hit_list[i].wordID == self.wid:
                i += 1
            else:
                break

        self.wright_id = i-1



    cdef void init_whit_list(self):

        '''
        从第一个词开始
        首次初始化whit空间
        以后的词均在此空间内进行过滤便可
        '''
        #print '+hit_list - init_whit_list'

        cdef:
            #当前搜索的did
            #只第一个did有效
            int cur_did
            int i       #hit_list的index
            int j       #whit_list的index

        #确定wid边界
        #self.pos_wid_scope()
        #初始时 cur_did 故意不同

        cur_did = self.hit_list[self.wleft_id].docID - 1
        
        #print 'leftid rigthid',self.wleft_id,self.wright_id

        i=self.wleft_id
        #初始化第一个did
        while i<=self.wright_id:
            #扫描整个　wid　字段
            if self.hit_list[i].docID == cur_did:
                pass

            else:
                #print '- whit_list append',cur_did
                self.whit_list.append(self.hit_list[i])
                cur_did = self.hit_list[i].docID

            i+=1

        #self.whit_list.show()

    
     
    cdef void find(self,char *word):

        '''
        查找词主程序
        在 init_whit_list 完成后
        默认　已经存在一个word记录
        '''
        cdef:
            double hashvalue
            int hash_file_id
            #特定wid的起始坐标
            #需要 wid hash表的支持
            int widstart
            int widend

        hashvalue = hash(word)
        #初始化 hit 文件队列

        #hash_file_id = self.pos_word_file(hashvalue)
        #刷新内存
        self.init_hit_file(hashvalue)

        #确定wid对应字段范围
        #此处需要确定　wid
        self.pos_wid_scope()


        #自动初始化
        #wlist 为本地取得的 whit_list 的一个副本
        #标志为 self.whit_list.top==-1
        if self.wlist.top == -1:
            #此处需要确定　wid !!!!?????????????????????
            self.init_whit_list()
            return


        #开始遍历 对did进行处理
        cdef:
            int i
            int cur_did
            int res

        #?????????????????????????????????????
        i=self.wleft_id

        #为了对第一个hit_list进行处理
        #估计改变cur_did
        cur_did=self.hit_list[i].docID - 1
         
        while i <= self.wright_id:
            #在wid内进行遍历
            if self.hit_list[i].docID == cur_did:
                pass
            else:
                res = self.whit_list.add(self.hit_list[i])
                cur_did = self.hit_list[i].docID
                
                if res == 2:
                    #查找外围范围溢出
                    break

            i+=1
    
        #whit_list 的 scanID 清 0
        self.whit_list.init_scanID()


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
    
    cdef init(self,Pack_res datalist):

        '''
        init
        '''
        self.dali=datalist.whit
        self.length=datalist.length


    cdef float gvalue(self,Whit data):

        '''
		返回需要进行比较的值
        '''
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


    cdef int partition(self,int low,int high):

        v=self.dali[low]

        while low<high:

            while low<high and self.gvalue( self.dali[high] ) <= self.gvalue( v ):

                high-=1

            self.dali[low]=self.dali[high]

            while low<high and self.gvalue( self.dali[low] )>=self.gvalue( v ):
                low+=1
            self.dali[high]=self.dali[low]

        self.dali[low]=v

        return low


    cdef void run(self):

        '''
        运行主程序
        '''
        self.quicksort(0,self.length-1)






###############################
#
#  需要 初始化一块 wordid hash表
#
###############################


cdef class Query:

    '''
    查询库
    查询主程序
    负责总的资源分配协调
    输入一段 句子 返回 最终查询的 docID
    并且进行排序
    此为单线程
    '''
    #动态查找队列
    cdef WhitList hit_list

    #whit 长度
    cdef length

    #需要查找的词组
    cdef object words

    #动态查找容器
    cdef Hit_find hit_find

    #整理过的结果
    cdef Pack_res pack_res
    
    #排序库
    cdef RankSorter rank_sort

    #词库
    cdef object thes

    cdef object ict


    def __cinit__(self,char *fdir,char *width_ph):

        '''
        init 
        词库
        索引库
        '''
        self.words = []

        self.ict=Ictclas('ICTCLAS50/') 
        #初始化动态查找池
        #此处传递结构需要注意 !!!!!!!!!!!!  ????????????????????

        #词库
        self.thes=Init_thesaurus('store/wordBar')
        
        #初始化 hit_find
        self.hit_find = Hit_find( fdir, width_ph)

        #排序库
        self.rank_sort=RankSorter()



    cdef void word_split(self,char *paragh):

        '''
        将传入的句子进行分词
        '''

        self.words = self.ict.split(paragh).split()



    def find_words(self,char *para):

        '''
        将词汇分词
        并且进行插曲
        '''
        cdef:
            int wid
            object word

        #对word进行分组
        
        #print 'begin to find words',
        #print para

        #print cdt.detect(para)

        self.word_split(para)
        self.group_words()

        #对每个word进行处理
        self.hit_find.init(&self.hit_list)

        for word in self.words:
            #进行查取
            #同时自动收录value
            #hit_find会自动对父亲的hit存储池进行修改扩充

            #print '- to find',word

            wid = self.thes.find(word)
            #print 'the wid is',wid

            #对词的存在性进行分析
            if wid == -1:
                return False
            
            #初始化 hit查找库
            #print '- init hit_find'
            self.hit_find.flush(wid)

            self.hit_find.find(word) 

        #查找完毕 开始后续处理
        #结果加工
        #print 'begin to pack res'

        if self.res_pack() == -1:
            return False

        #结果排序
        print 'begin to sort res'
        self.sort()

        return True


    cdef short res_pack(self):

        '''
        将结果进行整理
        去除无用记录
        便于进行排序输出结果

        同时　将各个类清0 还原
        '''

        if self.hit_list.empty == self.hit_list.top+1:
            #无有效结果
            return -1

        cdef:
            int length
            int i=0
            int index=0
        #结果有效长度
        length = self.hit_list.top+1 - self.hit_list.empty
        
        #消除之前结果
        if self.pack_res.whit != NULL:
            free(self.pack_res.whit)

        self.pack_res.whit = <Whit *> malloc (sizeof(Whit) * length)
        self.pack_res.length = length

        while index <= self.hit_list.top:

            if self.hit_list.whit[index].rank > -1:
                self.pack_res.whit[i] = self.hit_list.whit[index]
                i+=1

            index += 1

        return length


    cdef group_words(self):

        '''
        将words进行分组
        增加查询效率
        被 uni_docids 引用
        '''
        print '- begin to group words'

        pass


    cdef value(self):

        '''
        对每个docid
        计算其文档主题相关度
        同时　也包括对　rank的最后包装
        对 pagerank 及　私有权值的支持
        '''

        pass



    cdef sort(self):

        '''
        最终结果进行排序
        差不多可以变成最终结果
        '''

        #print '> sort res'
        self.rank_sort.init(self.pack_res)
        self.rank_sort.run()
        #开始将子类进行复原
        self.initList()


    def show_res(self):

        '''
        展示最终结果
        '''
        print '+ getiin show_res'

        print 'the length of res is',self.pack_res.length
        for i in range(self.pack_res.length):
            print self.pack_res.whit[i]
        

    cdef initList(self):

        '''
        将各种状态清0
        准备下一次思索
        '''
        #print '+ getin initList'

        #self.show_res()

        free( self.hit_list.whit )
        self.hit_list.length = 0
        self.hit_list.top = -1
        self.hit_list.empty = 0


    def get_res(self,int page_id):
        
        '''
        最终得到结果
        直接与前台django进行沟通
        仅仅返回docIDs
        返回数量及第n页的docIDs
        
        默认 page 从1 开始
        '''        
        cdef:
            int page_start
            int page_end
            int length
            object res
            int i
        
        res = {}

        docIDs = []

        length = self.pack_res.length

        if (page_id-1) * Page_each > length:
            return -1

        page_start = (page_id - 1) * Page_each
        page_end = page_id * Page_each

        if page_end > length-1:
            page_end = length -1

        res.setdefault('length',length)
        
        i = page_start
        
        while i <= page_end:
            docIDs.append(self.pack_res.whit[i].docID)  
            i += 1

        res.setdefault('length',length)
        res.setdefault('docIDs',docIDs)

        return res

        

