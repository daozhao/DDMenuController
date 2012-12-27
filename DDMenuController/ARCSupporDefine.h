//
//  ARCSupporDefine.h
//  Vurig Calendar
//
//  Created by chen daozhao on 12-12-27.
//  Copyright (c) 2012年 Vurig. All rights reserved.
//

#ifndef ARCSupporDefine_h
#define ARCSupporDefine_h

#ifndef don_retain
#if __has_feature(objc_arc)
    #define don_retain self
    #define don_dealloc self
    #define release self
    #define autorelease self
#else
    #define don_retain retain
    #define don_dealloc dealloc
    #define __bridge
#endif
#endif

//  Weak delegate support

#ifndef don_weak
#import <Availability.h>
#if (__has_feature(objc_arc)) && \
((defined __IPHONE_OS_VERSION_MIN_REQUIRED && \
__IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0) || \
(defined __MAC_OS_X_VERSION_MIN_REQUIRED && \
__MAC_OS_X_VERSION_MIN_REQUIRED > __MAC_10_7))
    #define don_weak weak
    #define __don_weak __weak
#else
    #define don_weak unsafe_unretained
    #define __don_weak __unsafe_unretained
#endif
#endif


#endif
