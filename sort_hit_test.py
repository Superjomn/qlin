from index.indexer import Sort_hits

hit_sort=Sort_hits('store/hits/hit_size.txt')

#hit_sort.init('store/hits/',13)
#hit_sort.show()

print '-'*50
print 'begin to sort by hits'

hit_sort.sort_wid('store/hits/',19)

print 'the end list'
print '-'*50



