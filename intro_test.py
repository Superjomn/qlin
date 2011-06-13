# -*- coding: utf-8 -*-
import sys
reload(sys)
sys.setdefaultencoding('utf-8')

from query.intro import Query

from Intro import Intro

import time


intro = Intro()

time1=time.time()
res = intro.query('中国大学')
time2=time.time()

print time2 - time1
for i in res:
    print i



