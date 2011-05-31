def showhash(ph):
    '''
    对已经形成对wordbar
    测试
    '''
    f=open(ph)
    c=f.read()
    f.close()
    
    words=c.split()
    for w in words:
        print hash(w),w



showhash('../store/wordBar')


