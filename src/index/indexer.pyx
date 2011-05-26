import os

from libc.stdlib cimport malloc,free,realloc

from libc.stdio cimport fopen, fwrite, fread,fclose,FILE

#from parser.Init_Thesaurus import Init_thesaurus

#cimport parser.Init_Thesaurus 


############ Init Thesaurus #########################################

DEF STEP=20


cdef struct HI: 
    int left    #左侧范围
    int right   #右侧范围


   ############## init_hashIndex  from  Thesaurus.pyx  ##############

cdef class init_hashIndex:
    '''
    init he hash index
    '''
    #define the hash index 

    cdef HI hi[STEP]

    def __cinit__(self,char *ph):
        '''
        init
        '''
        cdef FILE *fp=<FILE *>fopen(ph,"rb")
        fread(self.hi,sizeof(HI),STEP,fp)
        fclose(fp)

    def pos(self,double hashvalue):
        '''
        pos the word by hashvalue 
        if the word is beyond hash return -1
        else return the pos
        
        '''
        cdef int cur=-1
        
        if hashvalue>self.hi[0].left:
            cur+=1
        else:
            return cur

        while hashvalue > self.hi[cur].left:

            cur+=1

        return cur

      ###########################################################


#定义 hashIndex 结构
cdef struct HI: #hashIndex 结构
    int left    #左侧范围
    int right   #右侧范围
    

cdef class Init_thesaurus:
    '''
    初始化词库
    '''
    #使用动态分配内存方式  
    #分配词库内存空间
    cdef char **word_list
    #一级hash 参考表 初始化
    cdef init_hashIndex hashIndex
    #词库长度 由 delloc 调用
    cdef int length

    def __cinit__(self,char *ph):
        '''
        传入词库地址
        初始化词库
        '''
        #一级hash 参考表 初始化
        self.hashIndex = init_hashIndex("sore/hashIndex.b")

        cdef:
            int i
            int l

        f=open(ph)
        words=f.read()
        f.close()

        #词的数量 
        self.length=len(words)
        cdef char  **li=<char **>malloc( sizeof(char *) * self.length )
        if li!=NULL:
            print 'the li is successful'
            self.word_list=li
        else:
            print 'the li is failed'

        #开始对每个词分配内存 
        #并且分配内存
        for i,w in enumerate(words):
            self.word_list[i]=<char *>malloc( sizeof(char) * len(w) )
            self.word_list[i]=w

    def __dealloc__(self):
        '''
        释放c内存空间
        '''
        print 'begin to delete all the C spaces'

        cdef char* point
        cdef int i=0

        #释放每一个词的空间
        for i in range(self.length):
            free(self.word_list[i])

        #释放整个词库 pointer 的空间
        free(self.word_list)


    cdef double v(self,data):
        '''
        将元素比较的属性取出
        '''
        return hash(data)

    def show(self):
        for d in self.wlist:
            print hash(d),d

    def find(self,data):
        '''
        具体查取值 
        若存在 返回位置 
        若不存在 返回   0
        '''
        #需要测试 
        #print 'want to find ',hash(data),data
        cdef:
            int l
            int fir
            int mid
            int end
            int pos
            HI cur  #范围

        dv=self.v(data)     #传入词的hash

        pos=self.hashIndex( dv )

        if pos!=-1 and pos<STEP:
            cur=self.hashIndex.hi[pos]

        else:
            print "the word is not in wordbar or pos wrong"
            return False

        #取得 hash 的一级推荐范围
        fir=cur.left
        end=cur.right
        mid=fir

        while fir<end:
            mid=(fir+ end)/2
            if ( dv > self.v(self.wlist[mid]) ):
                fir = mid + 1
            elif  dv < self.v(self.wlist[mid]) :
                end = mid - 1
            else:
                break

        if fir == end:
            if self.v(self.wlist[fir]) > dv:
                return 0 
            elif self.v(self.wlist[fir]) < dv:
                return 0
            else:
                #print 'return fir,mid,end',fir,mid,end
                return end#需要测试
                
        elif fir>end:
            return 0

        else:
            #print '1return fir,mid,end',fir,mid,end
            return mid#需要测试



 

########################## end Thesaurus #########################################



DEF List_init_size = 100  #定义List初始化长度
DEF List_max_size = 1000  #定义List最长长度
DEF List_add = 100
DEF List_num = 20         #划分 块 数目


#定义 Hit 结构
cdef struct Hit:
    int wordID
    int docID
    short score
    int pos

#单个list结构
cdef struct List:
    Hit *start
    int length
    int top


cdef class Hit_lists:
    '''
    hit存储队列
    每个list对应于一个存储文件
    '''
    cdef:
        int length
        int top
        List hit_list[List_num]

    def __cinit__(self):
        '''
        初始化数据空间
        '''
        cdef:
            int i
        #初始化每个list节点
        for i in range(List_num):
            self.hit_list[i].start=<Hit *>malloc( sizeof(Hit) * List_init_size )
            self.hit_list[i].length=List_init_size
            self.hit_list[i].top=-1

            if self.hit_list[i].start!= NULL:
                print '>>init list ok!'

    cdef void eq(self,int hit_id,int idx,int wordID,int docID,short score,int pos):
        '''
        赋值处理
        '''
        self.hits[hit_id].start[idx].wordID=wordID
        self.hits[hit_id].start[idx].docID=docID
        self.hits[hit_id].start[idx].score=score
        self.hits[hit_id].start[idx].pos=pos

    cdef bint append(self,int hit_id,int wordID,int docID,short score,int pos):
        '''
        向list中添加数据
        如果list溢出 则返回False
        添加成功 返回True
        '''
        self.hit_list[hit_id].top+=1
        self.eq( hit_id, self.hit_list[hit_id].top ,wordID,docID,score,pos)

        if (self.hit_list[hit_id].top == self.hit_list[hit_id].length-2):
            #如果 分配长度快到最大长度 则返回false
            #如果 lenth还有空间 继续分配空间
            if (self.hit_list[hit_id].length<List_max_size):
                #添加新的空间
                #再添加 hit_add 个空间
                self.hit_list[hit_id].start=<Hit *>realloc( self.hit_list[hit_id].start , sizeof(Hit)*
                        (self.hit_list[hit_id].length+List_add))
                self.hit_list[hit_id].length += List_add
                return True

            else:
                #已经达到最大限度
                #应该将其添加入文件中
                return False

        else:
            #空间和其他都不缺少
            #正常情况
            return True

    cdef void empty(self,int hit_id):
        '''
        将List清空
        释放空间
        再重新分配基本空间
        '''
        free(self.hit_list[hit_id].start)
        #重新分配内存
        self.hit_list[hit_id].start = <Hit *>malloc( sizeof(Hit) * List_init_size )
        self.hit_list[hit_id].length=List_init_size
        self.hit_list[hit_id].top=-1





cdef class sorter:
    '''
    最优法排序
    '''
    #hitlist 的私有对象
    cdef Hit_lists dali 

    def __cinit__(self):
        '''
        初始化 
        将hit队列传递为self
        '''
        #初始化 Hit_list
        self.dali=Hit_lists()

    cdef double gvalue(self,data):
        '''
        取得值
        '''
        return 1

    def quicksort(self,int p,int q):

        cdef int j
        a=self.dali
        st=[]
        while True:
            while p<q:
                j=self.partition(a,p,q)
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

    cdef int  partition(self,a,int low,int high):
        #gvalue=self.gvalue
        v=a[low]
        while low<high:
            while low<high and self.gvalue( a[high] ) >= self.gvalue( v ):
                high-=1
            a[low]=a[high]

            while low<high and self.gvalue( a[low] )<=self.gvalue( v ):
                low+=1
            a[high]=a[low]

        a[low]=v
        return low

    def showlist(self):
        for i in self.dali:
            print i



cdef class Indexer:
    '''
    索引器
    最终将要产生两类hit
    一类为 docID 排序
    一类为 wID 排序

    在 docID 排序的时候 
    在扫描 wID 同时 存储 docID

    docID 需要 根据 文件个数 确定 每快存储长度
    最终需要根据 wID进行排序
    wordID 需要根据 wordID 进行排序
    ???????????两者均需要排序????????????
    '''
    #文件目录地址
    cdef char *ph
    cdef char *toph
    cdef Hit_lists hit_list
    #词库
    cdef Init_thesaurus thes

    def __cinit__(self,char *wph,char *toph):
        '''
        init
        ph: wordsplit文件目录地址
        '''
        self.ph=wph
        self.toph=toph
        #初始化 Hit_list
        self.hit_list = Hit_lists()
        #词库
        self.thes = Init_thesaurus(wph)


    cdef int loc_list(self,hashvalue):
        '''
        传入一个word
        定位 其 应该存在的 list 
        可以继承 词库 
        '''
        return self.thes.hashIndex.pos(hash(hashvalue))
        #???????????????????????????????

    def run(self):
        '''
        运行主程序
        '''
        cdef:
            int list_idx    #定位 list 的号码
            object li
            object c
            #词库长度
            int length
            #相对pos
            int abspos

        cdef:
            int pos
            #wordid 
            long wid
            #对应于 list 中 的 list_id

        li=os.listdir(self.ph)
        length=len(li)

        for doc in li:
            f=open(self.ph+'/'+doc)
            c=f.read()
            f.close()

            tags=c.split('@chunwei@')
            abspos=0

            for scoid,tag in enumerate(tags):
                #对每个标签进行处理
                words=tag.split()

                
                for pos,word in enumerate(words):
                    #开始扫面每一个tag ?????????????????????
                    wid=self.thes.find(word)
                    #定位 list号码
                    list_idx=self.loc_list(word)

                    #若 wid 为 0 表示 词汇不存在
                    if wid != 0:
                        print 'the word does not exist'
                        print 'that is strange'
                        #此处 为了将不同tag内的hit的pos完全分给开
                        #采用 自动添加 20 作为间隔
                        if self.hit_list[list_idx].append(list_idx,wid,doc,scoid,pos+abspos + 20 ):
                            continue

                        else:
                            #将 list_idx 对应的list写入到文件
                            self.add_save(list_idx)
                            #将相应list清空
                            self.hit_list.empty(list_idx)

    cdef sort(self):
        '''
        将结果逐个进行排序
        '''
        pass

    cdef void add_save(self,int list_idx):
        '''
        将相关内容添加到文件中 
        默认 便是 在 wordID 范围内乱序排列
        '''
        name=self.toph+str(list_idx)
        cdef char *fh=name
        cdef FILE *fp=<FILE *>fopen(fh,"ab")
        #此处 size 需要???????????????????????????????????????
        fwrite( self.hit_list.hit_list[list_idx].start, sizeof(Hit) ,
        self.hit_list.hit_list[list_idx].top+1 , fp)
        fclose(fp)
