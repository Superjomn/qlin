from django.conf.urls.defaults import patterns, include, url
from qlin.view import *

# Uncomment the next two lines to enable the admin:
# from django.contrib import admin
# admin.autodiscover()

urlpatterns = patterns('',
    ('^hello/$',hello),
    ('^index/$',index),
    ('^search/$',search),
    ('^intro/$',page_intro),
    ('^site_ctrl/$',Site_ctrl),
    ('^site_infor/$',Site_infor),
    ('^word_ctrl/$',Word_ctrl),
    #('^cg_site/$',cg_site),
    ('^templates/(?P<path>.*)$','django.views.static.serve',{'document_root':'/home/chunwei/qlin/templates/'}),
    # Examples:
    # url(r'^$', 'qlin.views.home', name='home'),
    # url(r'^qlin/', include('qlin.foo.urls')),

    # Uncomment the admin/doc line below to enable admin documentation:
    # url(r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    # url(r'^admin/', include(admin.site.urls)),
)
