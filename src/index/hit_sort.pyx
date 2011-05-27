from libc.stdlib cimport malloc,free
from libc.stdio cimport fopen,fclose,fwrite,FILE,fread
from parser import Init_Thesurus

import os





cdef struct Hit:
    int wordID
    int docID
    short score
    int pos


cdef class Sorter:
    '''
    排序主算法	
    '''
    cdef Hit *dali
    cdef int length
	
    #def __cinit__(self, Hit *data,int length):

    cdef void init(self,Hit *data,int length):

        '''
        init 
        '''
        self.dali=data
        self.length=length


    cdef double gvalue(self,data):
        '''
		返回需要进行比较的值
        '''
        return hash(data[1])

    def quicksort(self,int p,int q):
        cdef int j
        a=self.dali
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

            while low<high and self.gvalue( self.dali[high] ) >= self.gvalue( v ):
                high-=1
            self.dali[low]=self.dali[high]

            while low<high and self.gvalue( self.dali[low] )<=self.gvalue( v ):
                low+=1
            self.dali[high]=self.dali[low]

        self.dali[low]=v
        return low







cdef class wid_sort(Sorter):
    '''
    根据 wid 进行排序
    不包括最后 根据 docid 进行排序
    '''
    #词库
    cdef object wordbar
	
    def __cinit__(self):
        '''
        init 
        '''
        self.wordbar=Init_Thesurus.Init_thesurus()

    cdef void init1(self,Hit *data,int length):
        '''
        初始化 父亲 Sorter
        '''
        Sorter.init(self,data,length)

    cdef double gvalue(self,data):
        '''
        重载 Sorter 方法
		返回需要进行比较的值
        '''
        cdef int wid=data.wid
        #返回 hit 对应 word 的 hashvalue
        return hash( self.wordbar.wlist[wid] )



cdef class did_sort(Sorter):
    '''
    根据 did 进行排序
    不包括 在 耽搁 did 文件中 根据 wid 进行排序
    '''
    def __cinit__(self):
        '''
        init
        '''
        pass

    cdef init1(self,Hit *data,int length):
        '''
        初始化 父亲 Sorter
        '''
        Sorter.init(self,data,length)

    cdef double gvalue(self,data):
        '''
        返回排序字段
        '''
        return data.docID
    



cdef class hit_sort:
    '''
    使用 indexer 添加 hit 后
    使用 hit_sort 进行排序
    '''
    cdef Hit *hi
    #定义 wid 排序器
    cdef wid_sort widSorter
    #定义 did 排序起
    cdef did_sort didSorter

    def __cinit__(self):
        '''
        init
        '''
        self.widSorter = wid_sort()
        self.didSorer=did_sort()

    cdef sort_in_wid(self):
        '''
        根据wid进行排序
        然后 对此范围内 根据 docID 进行排序
        '''
        for docph in os.listdir():
            #读取文件 
            cdef int num = self.get_hit_num(docph)
            #将 文件中信息 读取到 hself.hi 中
            cdef FILE *fp=<FILE *>fopen(ph,"rb")
            fread(self.hi,sizeof(HI),num,fp)
            fclose(fp)
            ##############
            #  开始排序 ##
            ##############
            self.widSorter.quicksort(0,num-1)
            #将结果进行保存
            self.save_b(ph,num)


    cdef save_b(self,char *ph,int num):
        '''
        二进制保存文件
        '''
        print 'begin to save b file'
        cdef FILE *fp=<FILE *>fopen(ph,"wb")
        fwrite(self.hi,sizeof(HI),num,fp)
        fclose(fp)



    cdef int get_hit_num(docph):
        '''
        返回 每个 wid文件的hit 的数量
        '''
        pass


    cdef sort_in_did(self):
        '''
        根据docid进行排序
        然后 对此范围内 根据 wid 进行排序
        '''
        for docph in os.listdir():
            #读取文件 
            cdef int num = self.get_hit_num(docph)
            #将 文件中信息 读取到 hself.hi 中
            cdef FILE *fp=<FILE *>fopen(ph,"rb")
            fread(self.hi,sizeof(HI),num,fp)
            fclose(fp)
            ##############
            #  开始排序 ##
            ##############
            self.didSorter.quicksort(0,num-1)
            #将结果进行保存
            self.save_b(ph,num)



