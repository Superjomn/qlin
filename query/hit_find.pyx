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


    cdef void init(self,WhitList *whit, int wid):

        '''
        c语言层面的 init
        '''

        self.wid = wid

        #初始化 whit 运行时内存池
        #直接与父whit相同
        #结构体能否协调一直　需要测试!!!!!!!!!!!?????????????????????

        self.whit_list = Whit_list(wid)
        self.whit_list.init(whit)
        #为了对 公共池 取得足够的控制 
        #本地取得一个索引副本
        self.wlist = whit



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
            print 'begin read the file'

            fname = self.fdir +ind +'.hit'
            
            fn = fname

            print 'the fname is',fn

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

        i=self.pos_mid_wid()

        while i>=0:
            if self.hit_list[i].wordID == self.wid:
                i -= 1
            else:
                break

        self.wleft_id = i+1
        
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

        i=self.wleft_id
        #初始化第一个did
        while i<=self.wright_id:
            #扫描整个　wid　字段
            if self.hit_list[i].docID == cur_did:
                pass

            else:
                self.whit_list.append(self.hit_list[i])
                cur_did = self.hit_list[i].docID

            i+=1

    
     
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

