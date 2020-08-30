//
//  LEGOCrashSnifferOC.m
//  CrashTest
//
//  Created by 杨庆人 on 2020/8/27.
//  Copyright © 2020 杨庆人. All rights reserved.
//

#import "LEGOWildPointerSnifferOC.h"
#import <objc/runtime.h>
#import "LEGOForwardProxy.h"

static NSArray *rootClasses = nil;    // 注册的类
static NSDictionary<id, NSValue *> *rootClassDeallocImps = nil;   // 原有的释放函数
static BOOL enabled = NO;   // 释放是否已经生效
typedef void (*LEGODDeallocPointer) (id obj);

@implementation LEGOWildPointerSnifferOC

static inline void legoDealloc(__unsafe_unretained id obj) {
    Class currentClass = [obj class];
    Class rootClass = currentClass;
    while (rootClass != [NSObject class] && rootClass != [NSProxy class]) {
        rootClass = class_getSuperclass(rootClass);
    }
    NSString *className = NSStringFromClass(rootClass);
    LEGODDeallocPointer deallocImp = NULL;
    // 原有的释放函数
    [[rootClassDeallocImps objectForKey:className] getValue:&deallocImp];
    if (deallocImp != NULL) {
        deallocImp(obj);
    }
}

static inline IMP swizzleMethodWithBlock(Method method, void *block) {
    IMP blockImplementation = imp_implementationWithBlock(block);
    return method_setImplementation(method, blockImplementation);
}

+ (void)initialize {
    rootClasses = [@[[NSObject class], [NSProxy class]] retain];
}

+ (void)registerSniffer {
    @synchronized(self) {
        if (!enabled) {
            [self swizzleDealloc];
            enabled = YES;
        }
    }
}

+ (void)swizzleDealloc {
    static void *swizzledDeallocBlock = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzledDeallocBlock = [^void(id obj) {
            // 替换的释放函数
            Class currentClass = [obj class];
            NSValue *objVal = [NSValue valueWithBytes: &obj objCType: @encode(typeof(obj))];
            object_setClass(obj, [LEGOForwardProxy class]);
            // 保存原类
            ((LEGOForwardProxy *)obj).originClass = currentClass;
            // 十秒后再释放掉
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                __unsafe_unretained id deallocObj = nil;
                [objVal getValue: &deallocObj];
                object_setClass(deallocObj, currentClass);
                legoDealloc(deallocObj);
            });
        } copy];
    });
    
    NSMutableDictionary *deallocImps = [NSMutableDictionary dictionary];
    for (Class rootClass in rootClasses) {
        // 保存原有的释放函数
        IMP originalDeallocImp = swizzleMethodWithBlock(class_getInstanceMethod(rootClass, @selector(dealloc)), swizzledDeallocBlock);
        [deallocImps setObject: [NSValue valueWithBytes: &originalDeallocImp objCType: @encode(typeof(IMP))] forKey: NSStringFromClass(rootClass)];
    }
    rootClassDeallocImps = [deallocImps copy];
}

+ (void)unRegisterSnifier {
    @synchronized(self) {
        if (enabled) {
            [self unSwizzleDealloc];
            enabled = NO;
        }
    }
}

+ (void)unSwizzleDealloc {
    [rootClasses enumerateObjectsUsingBlock:^(Class rootClass, NSUInteger idx, BOOL *stop) {
        IMP originalDeallocImp = NULL;
        NSString *className = NSStringFromClass(rootClass);
        [[rootClassDeallocImps objectForKey:className] getValue:&originalDeallocImp];
        NSParameterAssert(originalDeallocImp);
        // 替换
        method_setImplementation(class_getInstanceMethod(rootClass, @selector(dealloc)), originalDeallocImp);
    }];
    [rootClassDeallocImps release];
    rootClassDeallocImps = nil;
}

@end
