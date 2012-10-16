//
//  LoginViewController.m
//  OceanHolic
//
//  Created by darkpuca on 10/12/12.
//  Copyright (c) 2012 darkpuca. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()


- (void)loginPressed:(id)sender;

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - OHServerManagerDelegate methods

- (void)serverRequestDidFinished:(NSDictionary *)resultDict requestType:(NSInteger)requestType
{
    if (kRequestLogin == requestType)
    {
        if (0 == [[resultDict valueForKey:@"error"] intValue])
        {
            [self.navigationController popViewControllerAnimated:YES];

            if ([_loginDelegate respondsToSelector:@selector(loginDidFinished)])
                [_loginDelegate loginDidFinished];
            
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            
            QEntryElement *idElmt = (QEntryElement *)[self.root elementWithKey:@"userId"];
            QEntryElement *pwdElmt = (QEntryElement *)[self.root elementWithKey:@"password"];
            QBooleanElement *autoElmt = (QBooleanElement *)[self.root elementWithKey:@"autoLogin"];
            
            [userDefault setObject:idElmt.textValue forKey:@"userId"];
            [userDefault setObject:[NSNumber numberWithBool:autoElmt.boolValue] forKey:@"autoLogin"];
            if (autoElmt.boolValue)
                [userDefault setObject:pwdElmt.textValue forKey:@"password"];
            
            [userDefault synchronize];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:[resultDict valueForKey:@"message"]
                                                               delegate:nil
                                                      cancelButtonTitle:@"닫기"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    }
}

- (void)serverRequestDidFailed:(NSError *)error requestType:(NSInteger)requestType
{
    if (kRequestLogin == requestType)
    {
        
    }
}


#pragma mark - Private methods

- (void)loginPressed:(id)sender
{
    QEntryElement *idElmt = (QEntryElement *)[self.root elementWithKey:@"userId"];
    QEntryElement *pwdElmt = (QEntryElement *)[self.root elementWithKey:@"password"];
    
    if (nil == idElmt.textValue || nil == pwdElmt.textValue)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"확인"
                                                            message:@"아이디와 비밀번호를 확인 해 주십시요."
                                                           delegate:nil
                                                  cancelButtonTitle:@"닫기"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:2];
    [params setValue:idElmt.textValue forKey:@"userId"];
    [params setValue:pwdElmt.textValue forKey:@"password"];
    
    [[OHServerManager sharedManager] setDelegate:self];
    [[OHServerManager sharedManager] login:params];
}

@end
