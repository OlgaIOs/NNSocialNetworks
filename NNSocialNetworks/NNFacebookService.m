//
//  NNFacebookService.m
//  NNSocialNetworks
//
//  Created by Olga Nikolaeva on 12/12/14.
//  Copyright (c) 2014 Olga Nikolaeva. All rights reserved.
//

#import "NNFacebookService.h"

@implementation NNFacebookService

- (BOOL)isSessionStateCreatedTokenLoaded
{
    return (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) ? YES : NO;
}

- (BOOL)isSessionOpen
{
    return [[FBSession activeSession] isOpen];
}

- (void)closeSession
{
    [FBSession.activeSession closeAndClearTokenInformation];
}


- (void)openSession:(void(^)(BOOL result, NSDictionary *user, NSError *error))processingBlock
{
    NSArray *permissions = @[@"email",
                             @"user_birthday"];
    
    __block NNFacebookService *weakSelf = self;
   
    BOOL allowLoginUI = (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) ? NO : YES;
   
    [FBSession openActiveSessionWithReadPermissions:permissions
                                       allowLoginUI:allowLoginUI
                                  completionHandler:^(FBSession *session, FBSessionState state, NSError *error)
                                        {
                                            if ((!error) && session.isOpen)
                                            {
                                            // get user info
                                            [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *fbUser, NSError *error) {
                                                NSDictionary *user = (error) ? nil : fbUser;
                                                processingBlock(YES, user, nil);
                                            }];
                                                
                                            }
                                            else
                                            {
                                                processingBlock(NO, nil, error);
                                            }
                                            
                                            [weakSelf sessionStateChanged:session state:state error:error];
                                      }];
}


- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    if (!error && state == FBSessionStateOpen){
        NSLog(@"Session opened");
         return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        NSLog(@"Session closed");
     }
    if (error){
        NSLog(@"Error");
           // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES)
        {
            NSLog(@"Error");
        } else {
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                // Handle session closures that happen outside of the app
            } else
                if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession)
                {
                    NSLog(@"Error while reopen session");
                }
                else {
                    NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                    NSLog(@"%@", errorInformation);
             }
        }
        [FBSession.activeSession closeAndClearTokenInformation];
    }
}

@end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
