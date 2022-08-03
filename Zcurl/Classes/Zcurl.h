//
//  Zcurl.h
//  Zcurl
//
//  Created by lZackx on 2022/8/1.
//

#import <Foundation/Foundation.h>

#import "ZcurlManager.h"
#import "ZcurlManagerDelegate.h"


NS_ASSUME_NONNULL_BEGIN

#if ZCURL_DEBUG
#define ZLog(s, ...) NSLog(@"[Zcurl]: %@", [NSString stringWithFormat:(s), ##__VA_ARGS__])
#else
#define ZLog(...)
#endif


// MARK: - definition for NSBundle
@interface Zcurl : NSObject
@end

NS_ASSUME_NONNULL_END
