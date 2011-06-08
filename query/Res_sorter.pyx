cdef struct Whit:
    int docID
    int pos         #可以直接比较位置
    float rank      #得分


cdef class RankSorter:
    '''
    '''
    cdef Whit *dali
    cdef int length

    def __cinit__(self,datalist):
        pass

    cdef init(self,Whit *li,int length):
        self.dali = li
        self.length = length

    cdef float gvalue(self,Whit data):
        '''
        '''
        return data.rank

    cdef quicksort(self,int p,int q):
        cdef int j
        cdef object st

        st=[]
        while True:
            while p<q:
                j=self.partition(p,q)
                if (j-p)>(q-j):
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

    cdef int  partition(self,int low,int high):
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

    def run(self):
        self.quicksort(0,self.length - 1)


