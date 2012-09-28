//
//  ReservationViewController.m
//  OceanHolic
//
//  Created by darkpuca on 9/28/12.
//  Copyright (c) 2012 darkpuca. All rights reserved.
//

#import "ReservationViewController.h"

@interface ReservationViewController ()

@end

@implementation ReservationViewController

@synthesize listButton = _listButton;


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

    [_listButton setEnabled:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    _listButton = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Functions

- (IBAction)loginButtonPressed:(id)sender
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:@"darkpuca" forKey:@"userId"];
    [params setValue:@"d944155" forKey:@"password"];
    
    [[OHServerManager sharedManager] setDelegate:self];
    [[OHServerManager sharedManager] login:params];
}

- (IBAction)listButtonPressed:(id)sender
{
    
    
}




#pragma mark - OHServerManagerDelegate methods

- (void)serverRequestDidFinished:(NSDictionary *)resultDict
{
    NSLog(@"server request result: %@", resultDict);
    
    NSInteger errorCode = [[resultDict valueForKey:@"error"] intValue];
    
    if (0 == errorCode)
    {
        [_listButton setEnabled:YES];
    }
}




@end
