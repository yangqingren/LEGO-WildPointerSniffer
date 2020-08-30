//
//  LEGOCrashSnifferC.h
//  CrashTest
//
//  Created by 杨庆人 on 2020/8/27.
//  Copyright © 2020 杨庆人. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LEGOWildPointerSnifferC : NSObject

// 注册 crash 探测器
void registerSniffer(void);

// 主动释放一定内存，freeNum 指针数量
void free_some_memory(size_t freeNum);

@end

NS_ASSUME_NONNULL_END

