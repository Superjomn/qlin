/*
 * urlSort.c
 *
 *  Created on: May 11, 2011
 *      Author: cwei-qlin
 */
#include <stdio.h>
#include <stdlib.h>
/*
 * 本文档对url最终结果做排序
 * 本项目所有排序均使用c语言的快速开序方法
 * 使用boost或者cython编写为python的库
 * 所有版本的快速开序算法均会提供相似算法  但不会使用类或者统一接口
 * 每个库的sort代码均会单独拷贝 并进行相关修改
 */
#include "stack.h"
/*
 * 记录的数据结构
 * 通过指定 id 索引的对应关系
 * 最终将结果输出 通过索引将原结果中的记录按照次序输出
 * （减少排序中 大块数据移动的时间）
 */

/*
 * ---------------------------------------------------------
 * ---------------程序主部分---------------------------------
 */
/*
 * 记录数据结构
 * 只要修改记录数据结构便可
 */
typedef struct{
	int id;			//元数据中id
	double hash;	//hash值
}dType;
struct data{
	int top;		//顶部
	int length;		//长度
	dType *node;	//将使用动态内存分配方式
}data;
/*
 * eq：
 * 	结构数组赋值
 */
void eq(dType *a,dType b)
{
	a->id=b.id;
	a->hash=b.hash;
}
/*
 * 初始化 结构数组
 * 使用动态内存分配方式  预先传入长度
 */
void data_init(int length)
{
	data.node=(dType *)malloc( sizeof(dType)*length );
	data.length=length;
	data.top=-1;
}
/*
 * 内存销毁
 */
void data_destroy()
{
	free(data.node);
}
/*
 * 向data中插入值
 * 用于初始化
 */
void data_push(dType d)
{
	if (data.top<data.length)
	{
		eq(&data.node[++data.top],d);
	}
}
/*
 * gv:
 * 	返回 dType结构中需要排序参考的部分
 * 	类似程序，只需要修改 dType 及 gv 便可
 */

double gv(dType x)
{
	return x.hash;
}
int partition(dType a[],int low,int high)
{
	//printf("begain partition\n");
	//gv=self.gvalue
	//dType v=a[low]
	dType v;
	eq(&v,a[low]);
	//while low<high:
	while(low<high)
	{
		//printf("began partition while 1\n");
		while (low<high && gv( a[high] ) >= gv( v ))
			high--;
		//a[low]=a[high]
		eq(&a[low],a[high]);

		while (low<high && gv( a[low] )<=gv( v ) )
			low++;
			//a[high]=a[low]
		eq(&a[high],a[low]);
	}
	//printf("out of partition while 1\n");

	//a[low]=v
	eq(&a[low],v);
	return low;
}

void quicksort(dType a[],int p,int q)
{
	//printf("begain quicksort\n");
	int index=1;
	while(1)
	{
		//printf("begain while top\n");
		int j=0;

		while(p<q)
		{
			j=partition(a,p,q);

			if ( (j-p)<(q-j) )
			{
				//printf("begain while\n");
				st_append(j+1);
				st_append(q);
				q=j-1;
			}
			else
			{
				st_append(p);
				st_append(j-1);
				p=j+1;
			}

		}
        if (st.top==-1)
            return;

		q=st_pop();
		p=st_pop();

	}
}

void show(dType a[])
{
    int i=0;
    //printf("begain to show the list\n");
    while(i<9)
    {
        printf("%d %lf \n",a[i].id,a[i].hash);
        i++;
    }
    printf("end the show the list\n");
}

void main()
{
	st_init();

	dType a[]={
			{2,34},
			{123,65},
			{33,23},
			{6,2334},
			{22,3467},
			{23,3466},
            {1,34342343},
            {5,453434},
            {56,-2332}
	};
	data_init(9);
	int i=0;
	while(i<9)
	{
		data_push(a[i++]);
	}

    show(data.node);
	quicksort(data.node,0,8);
    show(data.node);
    data_destroy();
    st_destroy();
    
}


