from index.indexer import Sort_hits

hit_sort=Sort_hits('store/hits/hit_size.txt')


print '-'*50
print 'begin to sort by hits'

for i in range(20):

    hit_sort.sort_wid('store/hits/',i)
    hit_sort.save('store/hits/',i)



