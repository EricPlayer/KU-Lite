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

#import "SCPageViewController.h"
#import "SCPageViewControllerView.h"
#import "SCCardsPageLayouter.h"
#import "SCPageLayouter.h"
#import "SCPageLayouterProtocol.h"
#import "SCParallaxPageLayouter.h"
#import "SCSlidingPageLayouter.h"

FOUNDATION_EXPORT double SCPageViewControllerVersionNumber;
FOUNDATION_EXPORT const unsigned char SCPageViewControllerVersionString[];

