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
                                                self.userInfo = fbUser;
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

- (void)performPublishAction:(void(^)(void))action {
    // we defer request for permission to post to the moment of post, then we check for the permission
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        // if we don't already have the permission, then we request it now
        [FBSession.activeSession requestNewPublishPermissions:@[@"publish_actions"]
                                              defaultAudience:FBSessionDefaultAudienceFriends
                                            completionHandler:^(FBSession *session, NSError *error) {
                                                if (!error) {
                                                    action();
                                                } else if (error.fberrorCategory != FBErrorCategoryUserCancelled) {
                                                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Permission denied"
                                                                                                        message:@"Unable to get permission to post"
                                                                                                       delegate:nil
                                                                                              cancelButtonTitle:@"OK"
                                                                                              otherButtonTitles:nil];
                                                    [alertView show];
                                                }
                                            }];
    } else {
        action();
    }
    
}

- (void)postStatusFrom:(UIViewController *)sender withText:(NSString *)text andImage:(UIImage *)image
{
    //using Request and requestForPostStatusUpdate
    [self performPublishAction:^{
       NSString *message =  text;
            
       FBRequestConnection *connection = [[FBRequestConnection alloc] init];
            
       connection.errorBehavior = FBRequestConnectionErrorBehaviorReconnectSession
            | FBRequestConnectionErrorBehaviorAlertUser
            | FBRequestConnectionErrorBehaviorRetry;
            
       [connection addRequest:[FBRequest requestForPostStatusUpdate:message]
            completionHandler:^(FBRequestConnection *innerConnection, id result, NSError *error)
            {
                if (error)
                {
                    NSLog(@"Error: %@", error);
                }
                else
                {
                    NSLog(@"Everything is Ok");
                }
            }];
            
       [connection addRequest:[FBRequest requestForUploadPhoto:image]
            completionHandler:^(FBRequestConnection *connection, id result, NSError *error)
            {
                if (error)
                {
                    NSLog(@"Error: %@", error);
                }
                else
                {
                    NSLog(@"Everything is Ok");
                }
            }];
            
       [connection start];
    }];
}

- (void)postImage:(UIImage *)image withMessage:(NSString *)message
{
    // using GraphPath
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    [params setObject:message forKey:@"message"];
    [params setObject:UIImagePNGRepresentation(image) forKey:@"picture"];
    
    [FBRequestConnection startWithGraphPath:@"me/photos"
                                 parameters:params
                                 HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error)
     {
         if (error)
         {
             NSLog(@"Error: %@", error);
         }
         else
         {
             NSLog(@"Everything is Ok");
         }
     }];
}

- (void)testGraph
{
    [FBRequestConnection startWithGraphPath:@"me/events?fields=cover,name,start_time"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error) {
                                  // Sucess! Include your code to handle the results here
                                  NSLog(@"user events: %@", result);
                              } else {
                                  // An error occurred, we need to handle the error
                                  // See: https://developers.facebook.com/docs/ios/errors
                              }
    }];
}


@end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
