# -*- coding: utf-8 -*-

import sys
import chardet
import SortFind as sortfind
reload(sys)
sys.setdefaultencoding('utf-8')

class SortFind:

    '''
    对于二分法的公共查取方法
    '''
    def __init__(self,wlist):

        '''
        将list赋值
        '''
        self.wlist=wlist
	
    def gvalue(self,data):

        '''
        将元素比较的属性取出
        '''
        return hash(data)

    def show(self):
        for d in self.wlist:
            print hash(d),d

    def find(self,data):

        '''
        具体查取值 若存在 返回位置 若不存在 返回false
        '''
        #需要测试 
        #print 'want to find ',hash(data),data
        v=self.gvalue
        l=len(self.wlist)
        li=self.wlist

        fir=0
        end=l-1
        mid=0

        if l == 0:
            return False #空

        while fir<end:
            mid=(fir+ end)/2
            if ( v(data) > v(li[mid]) ):
                fir = mid + 1

            elif  v(data) < v(li[mid]) :
                end = mid - 1

            else:
                break

        if fir == end:
            if v(li[fir]) > v(data):
                return False

            elif v(li[fir]) < v(data):
                return False

            else:
                #print 'return fir,mid,end',fir,mid,end
                return end#需要测试

        elif fir>end:
            return False

        else:
            #print '1return fir,mid,end',fir,mid,end
            return mid#需要测试

if __name__=='__main__':
    wlist=['world','hello','你好']
    sortfind=SortFind(wlist)
    print 'show the list:'
    sortfind.show()
    print sortfind.find('world')
    print sortfind.find('hello')
    print sortfind.find('你好')



