cdef class UrlSorter:

    '''
	进行排序  使用cython进行优化
    '''
    cdef object dali
	
    def __cinit__(self,datalist):

        self.dali=datalist


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


    cdef int partition(self,a,int low,int high):

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


