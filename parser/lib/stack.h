/*
 * urlSort.c
 *
 *  Created on: May 11, 2011
 *      Author: cwei-qlin
 */
#include<stdio.h>
#include<stdlib.h>
/*--------------------------------------------------
 * -------------------------------------------------
 * ---------栈--数据结构------------------------------
 */
struct st{
	int top;		//栈顶
    int *node;      //记录首地址  采用动态分配内存方法
    int length;		//当前分配的内存大小
}st;


#define STSIZE 1000
#define st_dtype int
#define STPERADD 20

/*
 * st_init:
 * 	栈初始化  采用动态分配内存的方法
 * 	以对大型数据作准备
 */
short st_init()
{
    st.top=-1;
    st.node=(int *)malloc( STSIZE*sizeof(int) ) ;
    if (st.node)
        return 1;
    else
        return 0;
}
/*
 * 销毁栈内存
 */
void st_destroy()
{
    free(st.node);
}
/*
 * st_append:
 * 	向栈中添加一个数据
 * 	如果内存不够 则重新分配内存
 */
short st_append(int x)
{
    if (st.top>=st.length-1)
    {
    	//重新分配内存
    	int *base = (int *)realloc( st.node, sizeof(int)*(st.length+STPERADD) );
    	//分配成功
    	if (base)
    	{
    		st.node=base;
    		st.length+=STPERADD;
    		return 1;
    	}
    	return 0;
    } 
	st.node[++st.top]=x;
}
/*
 * st_top:
 * 	从栈中取出一个数据
 */
int st_pop()
{
	if (st.top>=0)
	{
		return st.node[st.top--];
	}else{
        printf("the stack is empty!\n");
        return 0;
    }
}
