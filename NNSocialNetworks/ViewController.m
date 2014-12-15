//
//  ViewController.m
//  NNSocialNetworks
//
//  Created by Olga Nikolaeva on 12/12/14.
//  Copyright (c) 2014 Olga Nikolaeva. All rights reserved.
//

#import "ViewController.h"
#import "NNFacebookService.h"

@interface ViewController ()

@property (nonatomic, strong) NNFacebookService *fbService;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __block ViewController *weakSelf = self;

    self.fbService = [[NNFacebookService alloc] init];
    
    if ([self.fbService isSessionStateCreatedTokenLoaded])
    {
        [self.fbService openSession:^(BOOL result, NSDictionary *userInfo, NSError *error)
         {
             if (result)
             {
                 [weakSelf setupLoginButton];
                 [weakSelf setupUserLabel:userInfo];
             }
         } ];
    }
}

- (void)setupLoginButton
{
    [self.loginButton setTitle: (self.fbService.isSessionOpen) ? @"LOG OUT" : @"LOG IN" forState:UIControlStateNormal];
}

- (IBAction)loginButtonClick:(id)sender
{
    __block ViewController *weakSelf = self;
    
    if (self.fbService.isSessionOpen)
    {
        [self.fbService closeSession];
        [self setupLoginButton];
        [self setupUserLabel:nil];
    }
    else
    {
        [self.fbService openSession:^(BOOL result, NSDictionary *userInfo, NSError *error)
         {
             if (result)
             {
                 [weakSelf setupLoginButton];
                 [weakSelf setupUserLabel:userInfo];
             }
        } ];
    }
}

- (void)setupUserLabel:(NSDictionary *)userInfo
{
    [self.nameLabel setText:(userInfo) ? [userInfo valueForKey:@"name"] : @""];
}

@end
