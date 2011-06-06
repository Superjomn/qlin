
######################################
#
#       数据结构
#
######################################
#定义 Hit 结构
cdef struct Hit:
    int wordID
    int docID
    short score
    int pos

#查询时 存储队列
#此处score未加以存储    不可以直接继承
#直接计算其权质
cdef struct Whit:
    int docID
    int pos         #可以直接比较位置
    float rank      #得分

#为了方便父亲和子类间信息交流
#定义whit_list 结构定义
cdef struct WhitList:
    int length
    int top
    int empty #无效记录的数目
    Whit *whit


#最终整理过的结果整理结构
cdef struct Pack_res:
    int length
    Whit *whit




######################################
#
#       词库相关
#
######################################

#词库第一级加速hash  hash_index
DEF Hash_dir = "store/index_hash.b"

#wordBar 数量
DEF Word_wide_dir = "store/word_wide.txt"

#wordBar 地址
DEF wordBar_dir = "store/wordBar"


######################################
#
#       index 相关
#
######################################

DEF List_num = 20         #hit_lists中划分 块 数目


######################################
#
#       计算权质
#
######################################
DEF SCORE_TITLE = 0
DEF SCORE_B = 1
DEF SCORE_H1 = 2
DEF SCORE_A = 5
DEF SCORE_CONTENT = 6



######################################
#
#       运行时hash
#
######################################


DEF Whit_init_num = 100  
DEF Whit_add  =    30






