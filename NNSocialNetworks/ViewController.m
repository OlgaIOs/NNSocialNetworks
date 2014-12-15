//
//  ViewController.m
//  NNSocialNetworks
//
//  Created by Olga Nikolaeva on 12/12/14.
//  Copyright (c) 2014 Olga Nikolaeva. All rights reserved.
//

#import "ViewController.h"
#import "NNFacebookService.h"

@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) NNFacebookService *fbService;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *postTextField;
@property (weak, nonatomic) IBOutlet UIButton *postButton;
@property (weak, nonatomic) IBOutlet UIButton *chooseButton;

@property (strong, nonatomic) UIImage *postImage;

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


- (IBAction)selectPhoto:(UIButton *)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)postToFacebook:(UIButton *)sender
{
    NSString *text = [self.postTextField text];
    
    [self.fbService postImage:self.postImage withMessage:text];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.chooseButton setBackgroundColor:[UIColor colorWithRed:100 green:0 blue:0 alpha:0.4]];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    __weak ViewController *weakSelf = self;
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary)
        {
            weakSelf.postImage = info[UIImagePickerControllerEditedImage]?:info[UIImagePickerControllerOriginalImage];
            if (weakSelf.postImage)
            {
                [weakSelf.chooseButton setBackgroundColor:[UIColor colorWithRed:0.0 green:150 blue:0 alpha:0.3]];
            }
            NSLog(@"image:  %@", weakSelf.postImage);
        }
    }];
}

@end
