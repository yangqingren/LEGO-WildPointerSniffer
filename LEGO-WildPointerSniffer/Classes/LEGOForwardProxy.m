//
//  LEGOForwardProxy.m
//  CrashTest
//
//  Created by 杨庆人 on 2020/8/27.
//  Copyright © 2020 杨庆人. All rights reserved.
//

#import "LEGOForwardProxy.h"
#include <objc/runtime.h>

@implementation LEGOForwardProxy

- (BOOL)respondsToSelector: (SEL)aSelector
{
    return [self.originClass instancesRespondToSelector:aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector: (SEL)sel
{
    return [self.originClass instanceMethodSignatureForSelector:sel];
}

- (void)forwardInvocation: (NSInvocation *)invocation
{
    [self _throwMessageSentExceptionWithSelector: invocation.selector];
}

 
- (Class)class
{
    [self _throwMessageSentExceptionWithSelector: _cmd];
    return nil;
}

- (BOOL)isEqual:(id)object
{
    [self _throwMessageSentExceptionWithSelector: _cmd];
    return NO;
}

- (NSUInteger)hash
{
    [self _throwMessageSentExceptionWithSelector: _cmd];
    return 0;
}

- (id)self
{
    [self _throwMessageSentExceptionWithSelector: _cmd];
    return nil;
}

- (BOOL)isKindOfClass:(Class)aClass
{
    [self _throwMessageSentExceptionWithSelector: _cmd];
    return NO;
}

- (BOOL)isMemberOfClass:(Class)aClass
{
    [self _throwMessageSentExceptionWithSelector: _cmd];
    return NO;
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol
{
    [self _throwMessageSentExceptionWithSelector: _cmd];
    return NO;
}

- (BOOL)isProxy
{
    [self _throwMessageSentExceptionWithSelector: _cmd];
    return NO;
}

- (id)retain
{
    [self _throwMessageSentExceptionWithSelector: _cmd];
    return nil;
}

- (oneway void)release
{
    [self _throwMessageSentExceptionWithSelector: _cmd];
}

- (id)autorelease
{
    [self _throwMessageSentExceptionWithSelector: _cmd];
    return nil;
}

- (void)dealloc
{
    [self _throwMessageSentExceptionWithSelector: _cmd];
    [super dealloc];
}

- (NSUInteger)retainCount
{
    [self _throwMessageSentExceptionWithSelector: _cmd];
    return 0;
}

- (NSZone *)zone
{
    [self _throwMessageSentExceptionWithSelector: _cmd];
    return nil;
}

- (NSString *)description
{
    [self _throwMessageSentExceptionWithSelector: _cmd];
    return nil;
}


#pragma mark - Private
- (void)_throwMessageSentExceptionWithSelector: (SEL)selector
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"(-[%@ %@]) was sent to a zombie object at address: %p", NSStringFromClass(self.originClass), NSStringFromSelector(selector), self] userInfo:nil];
}

@end
