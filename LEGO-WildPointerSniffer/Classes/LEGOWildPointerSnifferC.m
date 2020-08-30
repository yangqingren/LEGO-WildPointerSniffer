//
//  LEGOCrashSnifferC.m
//  CrashTest
//
//  Created by 杨庆人 on 2020/8/27.
//  Copyright © 2020 杨庆人. All rights reserved.
//

#import "LEGOWildPointerSnifferC.h"
#include <objc/runtime.h>
#include <malloc/malloc.h>
#include <pthread.h>
#import <dlfcn.h>
#import "queue.h"
#import "fishhook.h"
#import "LEGOForwardProxy.h"

static CFMutableSetRef registeredClasses = nil;   // 注册的类
static Class CatchIsa;   // isa 指针
static size_t CatchIsaSize;   // isa size
static void(* original_free)(void *p);  // 原有的释放函数
struct DSQueue *unfreeQueue = NULL;  // 保存内存的队列
int currfreeSize = 0;  // 当前内存

#define MAX_STEAL_MEM_SIZE 1024*1024*100  // 最多存这么多内存，大于这个值就释放一部分
#define MAX_STEAL_MEM_NUM 1024*1024*10*0.9  // 最多保留这么多个指针，再多就释放一部分
#define BATCH_FREE_NUM 100  // 每次释放的时候释放指针数量

@implementation LEGOWildPointerSnifferC

+ (void)load
{

}

void registerSniffer(void) {
    
#ifdef DEBUG

    registeredClasses = CFSetCreateMutable(NULL, 0, NULL);

    unsigned int count = 0;
    Class *classes = objc_copyClassList(&count);
    for (int i = 0; i < count; i++ ) {
        CFSetAddValue(registeredClasses, (__bridge const void *)(classes[i]));
    }
    free(classes);
    classes = NULL;
    
    // 获取代理替身
    CatchIsa = objc_getClass("LEGOForwardProxy");
    CatchIsaSize = class_getInstanceSize(CatchIsa);
    // 队列
    unfreeQueue = ds_queue_create(MAX_STEAL_MEM_NUM);
    // 原释放函数
    original_free = (void(*)(void*))dlsym(RTLD_DEFAULT, "free");
    // 重新绑定新函数（方法替换）
    rebind_symbols((struct rebinding[]){{"free", (void*)safe_free}}, 1);
    
#endif
    
}

#pragma mark -替换的释放函数
void safe_free(void* p){
    int unFreeCount = ds_queue_length(unfreeQueue);
    // 内存大于一定值、指针个数大于一定值时，主动释放
    if (unFreeCount > MAX_STEAL_MEM_NUM || currfreeSize > MAX_STEAL_MEM_SIZE) {
        free_some_memory(BATCH_FREE_NUM);
    }
    else{
        size_t memSize = malloc_size(p);
        if (memSize > CatchIsaSize) {
            // 要释放的指针 proxy 的 isa 指针覆盖
            id obj= (id)p;
            Class originClass= object_getClass(obj);
            // 判断是不是objc对象
            char *type = @encode(typeof(obj));
            if (strcmp("@", type) == 0 &&
                 CFSetContainsValue(registeredClasses, originClass)) {
                // 如果是 objc 对象，则往对象的地址上填充 0x55
                memset(obj, 0x55, memSize);
                memcpy(obj, &CatchIsa, sizeof(void*));
                object_setClass(obj, [LEGOForwardProxy class]);
                ((LEGOForwardProxy *)obj).originClass = originClass;
                __sync_fetch_and_add(&currfreeSize,(int)memSize);
                // 多线程下int的原子加操作,多线程对全局变量进行自加，不用理线程锁了
                ds_queue_put(unfreeQueue, p);
            }else{
               original_free(p);
            }
        }else{
           original_free(p);
        }
    }
}

#pragma mark -主动释放函数
void free_some_memory(size_t freeNum){
    size_t count = ds_queue_length(unfreeQueue);
    freeNum = freeNum > count ? count:freeNum;
    for (int i = 0; i < freeNum; i ++ ) {
        void *unfreePoint = ds_queue_get(unfreeQueue);
        size_t memSize = malloc_size(unfreePoint);
        __sync_fetch_and_sub(&currfreeSize, (int)memSize);
        original_free(unfreePoint);
    }
}



@end
