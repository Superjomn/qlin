# -*- coding: utf-8 -*-

def Site_infor(request):
    '''
    站点信息展示前台
    将所有信息展示开来
    '''
    t = get_template('site_infor.html')
    #从数据库中将信息进行展示
    cx = sq.connect('store/site.sqlite')
    cu = self.cx.cursor()
    #开始查找信息
    strr = "select * from site"
    cu.execute(strr)
    print cu.fetchone()
    html = t.render(Context({}))
    return HttpResponse(html)
    

