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

#import "SCSafariPageController.h"
#import "SCSafariPageWrapperViewController.h"
#import "SCSafariZoomedInLayouter.h"
#import "SCSafariZoomedOutLayouter.h"

FOUNDATION_EXPORT double SCSafariPageControllerVersionNumber;
FOUNDATION_EXPORT const unsigned char SCSafariPageControllerVersionString[];

