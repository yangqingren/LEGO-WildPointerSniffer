//
//  LEGOCrashSnifferOC.h
//  CrashTest
//
//  Created by 杨庆人 on 2020/8/27.
//  Copyright © 2020 杨庆人. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LEGOWildPointerSnifferOC : NSObject

// 注册 crash 探测器
+ (void)registerSniffer;

// 停止 crash 探测器
+ (void)unRegisterSnifier;


@end

NS_ASSUME_NONNULL_END
