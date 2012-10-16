//
//  MainViewController.m
//  OceanHolic
//
//  Created by darkpuca on 10/12/12.
//  Copyright (c) 2012 darkpuca. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "MainViewController.h"
#import "QuickRootBuilder.h"
#import "ReservationViewController.h"

@interface MainViewController ()

- (void)showReservationView;
- (void)showLoginView;

@end


@implementation MainViewController

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
    
    [self setTitle:@"오션홀릭"];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern"]]];

    [_mainImageView setClipsToBounds:YES];
    [_mainImageView.layer setCornerRadius:16.0f];
    [_mainImageView.layer setBorderColor:[[UIColor darkGrayColor] CGColor]];
    [_mainImageView.layer setBorderWidth:4.0f];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    _mainImageView = nil;
    _reserveButton = nil;
    _logbookButton = nil;
    _fishbookButton = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark - OHServerManagerDelegate methods

- (void)serverRequestDidFinished:(NSDictionary *)resultDict requestType:(NSInteger)requestType
{
    NSLog(@"server request result: %@", resultDict);
    
    NSInteger errorCode = [[resultDict valueForKey:@"error"] intValue];
    
    if (0 == errorCode)
    {
    }

}


#pragma mark - LoginViewDelegate methods

- (void)loginDidFinished
{
    [self performSelector:@selector(showReservationView) withObject:nil afterDelay:0.4f];
}


#pragma mark - Private methods

- (void)showReservationView
{
    ReservationViewController *viewController = [[ReservationViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)showLoginView
{
    QRootElement *root = [QuickRootBuilder createLoginRoot];
    LoginViewController *viewController = [[LoginViewController alloc] initWithRoot:root];
    [viewController setLoginDelegate:self];
    [self.navigationController pushViewController:viewController animated:YES];
}



#pragma mark - Public methods

- (IBAction)reservePressed:(id)sender
{
    if ([OHServerManager isLogin])
        [self showReservationView];
    else
        [self showLoginView];
    
    
}

- (IBAction)logbookPressed:(id)sender
{
    
}

- (IBAction)fishbookPressed:(id)sender
{
    
}



@end
