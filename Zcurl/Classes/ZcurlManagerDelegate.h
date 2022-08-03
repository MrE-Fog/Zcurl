//
//  ZcurlManagerDelegate.h
//  Pods
//
//  Created by lZackx on 2022/8/1.
//

#ifndef ZcurlManagerDelegate_h
#define ZcurlManagerDelegate_h

#import <Foundation/Foundation.h>
#import <Zcurl/curl.h>


@protocol ZcurlManagerDelegate <NSObject>

- (void)curl:(CURL *)curl willPerformWithURL:(NSURL *)url;

- (void)curl:(CURL *)curl didPerformWithURL:(NSURL *)url info:(NSDictionary *)info;

@end


#endif /* ZcurlManagerDelegate_h */
