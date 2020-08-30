#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "fishhook.h"
#import "LEGOForwardProxy.h"
#import "LEGOWildPointerSnifferC.h"
#import "LEGOWildPointerSnifferOC.h"
#import "queue.h"

FOUNDATION_EXPORT double LEGO_WildPointerSnifferVersionNumber;
FOUNDATION_EXPORT const unsigned char LEGO_WildPointerSnifferVersionString[];

