//
//  LEGOForwardProxy.h
//  CrashTest
//
//  Created by 杨庆人 on 2020/8/27.
//  Copyright © 2020 杨庆人. All rights reserved.
//  代理类，原用于设计转发 target

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LEGOForwardProxy : NSProxy
@property (nonatomic, assign) Class originClass;

@end

NS_ASSUME_NONNULL_END
