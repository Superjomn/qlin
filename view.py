# -*- coding: utf-8 -*-

from django.template.loader import get_template
from django.template import Context
from django.http import HttpResponse
#from django.utils import simplejson 

import time

import Query

from Intro import Intro

from site_infor import site_infor

########################### 搜索库对象 ###########################
#
#
##################################################################
#全局查询库
query1 = Query.Res_Query(1)
#全局搜索提示库
intro1 = Intro(1)
#初始化　默认site为0
query2 = Query.Res_Query(2)
intro2 = Intro(2)
########################## end ###################################

#辅助 库对象
infor = site_infor()

site = 1


def hello(request):
    t = get_template('hello.html')
    html = t.render( Context({'title':'hello Lavender','content':'I will marry you!'} ) )
    return HttpResponse(html)



def cg_site(new_site):
    '''
    垂直搜索
    '''
    global query 
    global intro
    global site

    #是否需要改变
    if new_site != site:
        #开始对全局quer进行赋值
        query = Query.Res_Query(new_site)
        intro = Intro(new_site)

        site = new_site



def index(request):
    '''
    首页
    '''
    global site

    t = get_template('index.html')
    #加入站点信息
    if 'site' in request.GET:
        site = int( request.GET['site'])
    else:
        #默认值应该为总搜索
        site = 1
    #取得title
    title = infor.get_title(site)
    
    html = t.render(Context({'site':site,'title':title}))
    '''
    if 'cg_site' in request.GET:
        print 'begin to change to',int( request.GET['cg_site'] )
        cg_site( int( request.GET['cg_site'] ) )
    '''
    return HttpResponse(html)

##################################################################
#       站点管理
##################################################################
def Site_ctrl(request):
    '''
    站点管理前台
    '''
    t = get_template('site_ctrl.html')
    res = infor.get_sites()
    html = t.render(Context({'res':res}))
    return HttpResponse(html)

def add_site(request):
    '''
    添加站点
    '''
    #site = (request.GET['title'],request.GET['start_url'],request.GET['home_urls'],request.GET['head'],request.GET['max_page_num'])
    infor.add_site(site)
    t = get_template('jump.html')
    html = t.render(Context({'url':'/site_ctrl/'}))
    return HttpResponse(html)

def update_site(request):
    '''
    更新一个站点信息
    '''
    site = (request.GET['title'],request.GET['start_url'],request.GET['home_urls'],request.GET['head'],int(request.GET['max_page_num']), int(request.GET['id'] ))
    infor.update_site(site)

    t = get_template('jump.html')
    html = t.render(Context({'url':'/site_ctrl/'}))
    return HttpResponse(html)


def delete_site(request):
    '''
    删除一个站点
    '''
    print 'delete site'
    infor.delete_site( int(request.GET['id']) )

    t = get_template('jump.html')
    html = t.render(Context({'url':'/site_ctrl/'}))
    return HttpResponse(html)
    
    

##################################################################

def Site_infor(request):
    '''
    站点信息展示前台
    '''
    t = get_template('site_infor.html')
    res = infor.get_sites()
    html = t.render(Context({'res':res}))
    return HttpResponse(html)


def Word_ctrl(request):
    '''
    词库管理前台
    '''
    words = infor.get_word()
    for i,w in enumerate(words):
        words[i]=w[0]
    print words
    t = get_template('word_ctrl.html')
    html = t.render(Context({'words':words}))
    return HttpResponse(html)


def update_word(request):
    '''
    对词库进行修改
    '''
    print 'wordbar'
    words=((request.POST['xueyuan'],1),(request.POST['name'],2),\
            (request.POST['pos'],3),(request.POST['other'],4))
    print '-'*50
    print words
    infor.update_word(words)

    t = get_template('jump.html')
    html = t.render(Context({'url':'/word_ctrl/'}))
    return HttpResponse(html)


def search(request):
    
    '''
    搜索主程序
    为了配合不同用户同时进行搜索
    不能采用global site
    '''
    #总的站点设置

    t = get_template('search.html')

    if 'query_text' in request.GET:
        #对搜索站点进行定义
        if 'site' in request.GET:
            site = int( request.GET['site'] )
        else:
            site = 1

        if 'page' in request.GET:
            page = int(request.GET['page'])
            ###print 'get page',page

            if page < 0:
                page = 1

        else:
            page = 1

        ###print 'final page',page
        time1 =time.time()

        text = request.GET['query_text'] 
        
        #计算查询时间
        #result = query1.gres( text, page)

        strr = 'result = query%d.gres( text, page)'%site
        exec(strr)
        print strr
        
        time2 = time.time()

        Per_page = 8 
        if result:
            page_num = result['length']/Per_page
            if result['length'] > Per_page * page_num:
                page_num += 1

        if result:
            result.setdefault('query_text',text)

            words = text.split()
            strr = ''

            if len(words)>1:
                for w in words[:-1]:
                    strr+=w+'+'

                strr+=words[-1]
                ###print 'the query word is',strr
            else:
                strr=text

            result.setdefault('url_text',strr)
            result.setdefault('page_num',page_num)
            result.setdefault('page',page)
            #加入搜索站点信息
            result.setdefault('site',site)
            #赋值时间
            #result.setdefault('time',time)
        else:
            result = {}
            result.setdefault('query_text',text)
            result.setdefault('length',0)
            result.setdefault('res_list',[])

        result.setdefault('time',round(time2-time1,4))
        html = t.render( Context( result ) )
        return HttpResponse(html)

    else:
        message = 'You submitted an empty form'

    return HttpResponse(message)



def page_intro(request):
    '''
    搜索提示
    '''
    t = get_template('intro.html')
    res = {}
    #print request.GET
    if 'site' in request.GET:
        site = int( request.GET['site'])
    else:
        site = 1

    if 'term' in request.GET:
        para=request.GET['term']
        #print para
        strr =  "ret= intro%d.query(para)"%site
        exec(strr)
        #ret= intro.query(para)

    res.setdefault('res',ret)
    html = t.render( Context( res) )
    return HttpResponse(html)

def site_ctrl(request):
    '''
    站点管理
    '''
    pass


def site_info(request):
    '''
    站点信息展示
    '''
    pass


def word_ctrl(request):
    '''
    关键词管理
    '''




