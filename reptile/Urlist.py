'''
Created on 2011-5-7

@author: chunwei
'''
class Urlist(list):
    'the runtime list for all the url list'
    def find(self, url):  
        
        l = len(self)  
        first = 0  
        end = l - 1  
        mid = 0  
        
        if l == 0:  
            self.insert(0,url)  
            return False  
        
        while first < end:  
            mid = (first + end)/2  
            if url > self[mid]:  
                first = mid + 1  
            elif url < self[mid]:  
                end = mid - 1  
            else:  
                break  
            
        if first == end:  
            if self[first] > url:  
                self.insert(first, url) 
                return False  
            
            elif self[first] < url:  
                self.insert(first + 1, url)  
                return False  
            
            else:  
                return True  
                
        elif first > end:  
            self.insert(first, url) 
            return False  
        else:  
            return True  