//
//  NNFacebookService.h
//  NNSocialNetworks
//
//  Created by Olga Nikolaeva on 12/12/14.
//  Copyright (c) 2014 Olga Nikolaeva. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK.h>

@interface NNFacebookService : NSObject

@property (nonatomic, strong) NSDictionary *userInfo;

- (BOOL)isSessionOpen;
- (BOOL)isSessionStateCreatedTokenLoaded;
- (void)closeSession;
- (void)openSession:(void(^)(BOOL result, NSDictionary *user, NSError *error))processingBlock;
- (void)postStatusFrom:(UIViewController *)sender withText:(NSString *)text andImage:(UIImage *)image;
- (void)postImage:(UIImage *)image withMessage:(NSString *)message;

@end
