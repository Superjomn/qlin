class Sorter:
    '''
    '''
    def __init__(self,datalist):
        self.dali=datalist

    def gvalue(self,data):
        '''
        '''
        return data

    def quicksort(self,p,q):
        a=self.dali
        st=[]
        while True:
            while p<q:
                j=self.partition(a,p,q)
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

    def partition(self,a,low,high):
        gv=self.gvalue
        v=a[low]
        while low<high:
            while low<high and gv( a[high] ) <= gv( v ):
                high-=1
            a[low]=a[high]

            while low<high and gv( a[low] )>=gv( v ):
                low+=1
            a[high]=a[low]

        a[low]=v
        return low

    def showlist(self):
        for i in self.dali:
            print i

if __name__=='__main__':
    dli=[1,1,1,1,1,1,2,2,2,22,2,2,2,2,2,2]
    sort=Sorter(dli)
    sort.showlist()
    sort.quicksort(0,len(dli)-1)
    print 'sorted list :'
    sort.showlist()

