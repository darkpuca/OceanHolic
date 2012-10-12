//
//  ReservationViewController.m
//  OceanHolic
//
//  Created by darkpuca on 9/28/12.
//  Copyright (c) 2012 darkpuca. All rights reserved.
//

#import "ReservationViewController.h"

//#import <SDWebImage/UIImageView+WebCache.h>


@interface ReservationViewController ()

@end

@implementation ReservationViewController



- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)viewDidUnload
{
    [super viewDidUnload];

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
    [[OHServerManager sharedManager] setDelegate:self];
    [[OHServerManager sharedManager] reservationItems];
    
}




#pragma mark - OHServerManagerDelegate methods

- (void)serverRequestDidFinished:(NSDictionary *)resultDict
{
    NSLog(@"server request result: %@", resultDict);
    
    NSInteger errorCode = [[resultDict valueForKey:@"error"] intValue];
    
    if (0 == errorCode)
    {

    }
}




@end
