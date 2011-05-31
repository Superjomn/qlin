import os

from libc.stdlib cimport malloc,free,realloc

from libc.stdio cimport fopen, fwrite, fread,fclose,FILE

from parser.Init_Thes import Init_thesaurus , init_hashIndex



DEF STEP=20



#定义 hashIndex 结构
cdef struct HI: #hashIndex 结构
    int left    #左侧范围
    int right   #右侧范围
    



DEF List_init_size = 100  #定义List初始化长度

#DEF List_max_size = 1000  #定义List最长长度

#DEF List_add = 100

DEF List_num = 20         #hit_lists中划分 块 数目


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

        print '>begin init List space'

        cdef:
            int i

        #初始化每个list节点
        for i in range(List_num):

            self.hit_list[i].start=<Hit *>malloc( sizeof(Hit) * List_init_size )
            self.hit_list[i].length=List_init_size

            self.hit_list[i].top=-1

            if self.hit_list[i].start!= NULL:

                print '>>init list ok!'

    cdef __delloc__(self):
        '''
        消去内存
        '''
        cdef int i

        print 'begin to delete the space'

        for i in range(List_num):
            free(self.hit_list[i].start)


    cdef void eq(self,int hit_id,int idx,int wordID,int docID,short score,int pos):

        '''
        赋值处理
        '''
        print '- eq'
        
        print '>eq: ',hit_id,idx,wordID,docID,score,pos
        print '>eq: the status of this list is:'
        print 'top',self.hit_list[hit_id].top
        print 'length',self.hit_list[hit_id].length

        self.hit_list[hit_id].start[idx].wordID=wordID

        self.hit_list[hit_id].start[idx].docID=docID

        self.hit_list[hit_id].start[idx].score=score

        self.hit_list[hit_id].start[idx].pos=pos




    def ap(self,int hit_id , int wordID , int docID , short score , int pos):

        '''
        向list中添加数据
        如果list溢出 则返回False
        添加成功 返回True
        '''
        print 'begin append the word hit >>>>>'
        print 'hello world'

        self.hit_list[hit_id].top+=1
        print '+ hit.top+1'
        print '+ begin eq'
        self.eq( hit_id, self.hit_list[hit_id].top ,wordID,docID,score,pos)
        print '> succed eq'

        if (self.hit_list[hit_id].top > self.hit_list[hit_id].length-2):
            #如果 分配长度快到最大长度 则返回false
            #如果 lenth还有空间 继续分配空间

            '''if (self.hit_list[hit_id].length < List_max_size):

                #添加新的空间
                #再添加 hit_add 个空间

                print '+ begin to relloc'

                self.hit_list[hit_id].start=<Hit *>realloc( self.hit_list[hit_id].start , sizeof(Hit) * (self.hit_list[hit_id].length+List_add))

                print '- succed relloc'

                self.hit_list[hit_id].length += List_add

                return True

            else:
                #已经达到最大限度
                #应该将其添加入文件中
                return False
                '''
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
        print 'begin to free the list'

        #free(self.hit_list[hit_id].start)
        #重新分配内存

        print 'begin to relloc it'
        #self.hit_list[hit_id].start = <Hit *>malloc( sizeof(Hit) * List_init_size )
        #self.hit_list[hit_id].length=List_init_size
        self.hit_list[hit_id].top=-1

    cdef Hit *get_head(self,int idx):
        return <Hit *>self.hit_list[idx].start




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
    cdef char *fph

    cdef char *toph

    cdef Hit_lists hit_list

    cdef object thes

    cdef object hash_index

    #词库
    def __cinit__(self,char *wph,char *fph,char *toph):

        '''
        init
        ph: wordsplit文件目录地址
        '''

        self.fph=fph
        self.toph=toph

        #初始化 Hit_list
        self.hit_list = Hit_lists()
        #词库
        self.thes = Init_thesaurus(wph)

        self.hash_index = init_hashIndex('store/index_hash.b','store/word_wide.txt')

    cdef int loc_list(self,hashvalue):

        '''
        传入一个word
        定位 其 应该存在的 list 
        可以继承 词库 
        '''

        return self.hash_index.pos(hash(hashvalue))


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
            int scoid
            #对应于 list 中 的 list_id
            int docid

        li=os.listdir(self.fph)

        length=len(li)
        
        dig = 0

        for doc in li:

            print 'doc is',doc

            f=open(self.fph+'/'+doc)
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
                    print 'from wordBar find',wid
                    #定位 list号码
                    list_idx=self.loc_list(word)

                    #若 wid 为 0 表示 词汇不存在

                    if wid != 0:


                        #此处 为了将不同tag内的hit的pos完全分给开
                        #采用 自动添加 20 作为间隔
                        
                        print list_idx,wid,doc,scoid, pos+abspos+20

                        #print 'begin append'

                        if self.hit_list.ap(list_idx,wid,int(doc),scoid, pos+abspos+20 ) == 1:

                            pass

                        else:

                            #将 list_idx 对应的list写入到文件

                            print '-'*50
                            print 'the stack is full'

                            self.add_save(list_idx)

                            print 'begin to empty the stack'

                            #将相应list清空
                            self.hit_list.empty(list_idx)

        #将剩余的hits进行存储
        #一些list hit 数目不超过 max_size
        for i in range(List_num):
            self.add_save(i)
            
        



    cdef sort(self):

        '''
        将结果逐个进行排序
        在客户端已经进行排序???
        '''
        pass



    cdef void add_save(self,int list_idx):

        '''
        将相关内容添加到文件中 
        默认 便是 在 wordID 范围内乱序排列
        '''
        print '>> add save'
        print '-'*50

        name=self.toph+'/'+str(list_idx)+'.hit'
        
        print 'the docname is',name

        cdef char *fh=name

        cdef FILE *fp=<FILE *>fopen(fh,"ab")

        #此处 size 需要???????????????????????????????????????
        print 'begin to write'
        print 'the status of the information'
        print sizeof(Hit)
        print self.hit_list.hit_list[list_idx].top+1

        fwrite( self.hit_list.hit_list[list_idx].start , sizeof(Hit) ,  self.hit_list.hit_list[list_idx].top+1 , fp)
        fclose(fp)






