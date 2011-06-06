import sqlite3 as sq

cx = sq.connect('store/chun.sqlite')

t=cx.execute

strr="insert into lib values(2,'','','','','')"

print t(strr)

li=t("select * from lib")

for i in li:
    print i

