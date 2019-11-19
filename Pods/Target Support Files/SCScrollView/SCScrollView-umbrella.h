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

#import "easing.h"
#import "SCEasingFunction.h"
#import "SCEasingFunctionProtocol.h"
#import "SCScrollView.h"
#import "SCWeakObjectWrapper.h"

FOUNDATION_EXPORT double SCScrollViewVersionNumber;
FOUNDATION_EXPORT const unsigned char SCScrollViewVersionString[];

