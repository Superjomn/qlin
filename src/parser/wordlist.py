#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys
reload(sys)
sys.setdefaultencoding('utf-8')

class Wordlist(list):
    '''
    生成唯一的wordlist 可以同时搜寻word
    '''
    def find(self,word):
        '''
        在list中查找word
        如果查找到 返回位置信息
        如果没有找到 返回False
        '''
        l=len(self)
        first=0
        end=l-1
        mid=0
        num=hash(word)
        
        if l==0:
            self.insert(0,word)
            return False
        
        while first<end:
            mid=(first+end)/2
            if num>hash(self[mid]):
                first=mid+1
            elif num<hash(self[mid]):
                end=mid-1
            else:
               first=mid
               end=mid
               while hash(self[first])==num and first>=0:
                   
                    if self[first]==word:
                        return True
                    first-=1

               while hash(self[end])==num and end<l:
                   
                    if self[end]==word:
                        return True 
                    end=end+1

               self.insert(mid+1,word)
               return False
            
        if first==end:
            if hash(self[first])>num:
                self.insert(first,word)
                return False
            elif hash(self[first])<num:
                self.insert(first+1,word)
                return False
            else:
                
                if self[first]==word:
                    #hashֵ��� �Ҵʻ�Ҳ���
                    return True
                else:
                    self.insert(first+1,word)
                    return False

        elif first>end:
            self.insert(first,word)
            return False
        else:
            return True

if __name__=='__main__':
    print 'begin to add world'
    word=Wordlist()
    print 'hello',hash('hello')
    print 'world',hash('world')
    print 'he',hash('he')
    print 'wold',hash('wold')

    word.find('hello')
    word.find('world')
    word.find('he')
    word.find('wold')
    print word
    while True:
        inword=raw_input('input>>')
        if inword=='000':
            break
        elif inword=='111':
            for i in word:
                print hash(i),i
        else:
            word.find(inword)
            print 'the word is here'
            print word
    print 'hello'
