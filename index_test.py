from index.indexer import Indexer,Sort_hits
from query.path import path

p = path(0)
'''
index=Indexer(0)

index.run()
'''


hit_sort = Sort_hits(p.g_hit_size())

for i in range(20):
    hit_sort.sort_wid(p.g_hits()+'/',i)

    hit_sort.save(p.g_hits()+'/',i)
