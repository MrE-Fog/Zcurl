//
//  ZViewController.m
//  Zcurl
//
//  Created by lZackx on 07/29/2022.
//  Copyright (c) 2022 lZackx. All rights reserved.
//

#import "ZViewController.h"
#import <Zcurl/Zcurl.h>

@interface ZViewController () <ZcurlManagerDelegate>

@end

@implementation ZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"%@", [NSBundle bundleForClass:[Zcurl class]]);
    
    [ZcurlManager shared].delegate = self;
    
    [self curl:@"https://github.com/lzackx/Zcurl"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)curl:(NSString *)url {
    
    [[ZcurlManager shared] performWithURLString:url];
}

// MARK: - CURLToolDelegate
- (void)curl:(CURL *)curl willPerformWithURL:(NSURL *)url {
    
    NSLog(@"url: %@", url);
}

- (void)curl:(CURL *)curl
didPerformWithURL:(NSURL *)url
        info:(NSDictionary *)info {
    
    NSLog(@"url: %@", url);
    NSLog(@"@%@", info);

}

@end
