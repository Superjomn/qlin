#include <stdio.h>
#include <stdlib.h>

struct Hit{
    int wordID;
    int docID;
    short score;
    int pos;
};

struct Whit{
    int docID;
    int pos;
    float rank;
};
typedef struct Hit Hit;
typedef struct Whit Whit;

void read_hash(Hit *hitlist,int size,char *ph)
{
    FILE *fp = fopen(ph,"rb");
    fread(hitlist,sizeof(Hit),size,fp);
    fclose(fp);
}

void mall_hit(Hit *hitlist,int size)
{
    //Hit *base;
    //printf("start to relloc\n");
    //base = realloc( hitlist,sizeof(Hit)*size);
    //hitlist = base;
    //free(hitlist); 
    hitlist = malloc( sizeof(Hit) * size);
}

void mall_whit(Whit *hitlist,int size)
{
    if (hitlist)
        hitlist = realloc( hitlist,sizeof(Whit)*size);
    else
        hitlist = malloc(sizeof(Whit) * size );
}

void rell_whit(Whit *hitlist,int new_size)
{
    hitlist = realloc( hitlist,sizeof(Whit)*new_size);
}



void main()
{
    Hit *list;
    mall_hit(list,20);
}
