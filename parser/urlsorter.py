class Sorter:
    '''
	进行排序  使用cython进行优化
    '''
    def __init__(self,datalist):
        self.dali=datalist

    def gvalue(self,data):
        '''
		返回需要进行比较的值
        '''
        return hash(data[1])

    def quicksort(self,p,q):
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

    def partition(self,a,low,high):
        gv=self.gvalue
        v=a[low]
        while low<high:
            while low<high and gv( a[high] ) >= gv( v ):
                high-=1
            a[low]=a[high]

            while low<high and gv( a[low] )<=gv( v ):
                low+=1
            a[high]=a[low]

        a[low]=v
        return low

    def showlist(self):
        for i in self.dali:
            print i

if __name__=='__main__':
    dli=[2,1,23,54,23,34,23,23,12,1,3]
    dlist=[ (2,23),(23,12),(45,1),(34,12),(342,0) ]
    sort=sorter(dlist)
    sort.showlist()
    sort.quicksort(0,4)
    print 'sorted list :'
    sort.showlist()

