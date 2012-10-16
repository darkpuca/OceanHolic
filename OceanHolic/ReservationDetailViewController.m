//
//  ReservationDetailViewController.m
//  OceanHolic
//
//  Created by darkpuca on 10/16/12.
//  Copyright (c) 2012 darkpuca. All rights reserved.
//

#import "ReservationDetailViewController.h"

@interface ReservationDetailViewController ()

@end

@implementation ReservationDetailViewController

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

    if (_uriString)
    {
        [[OHServerManager sharedManager] setDelegate:self];
        [[OHServerManager sharedManager] reservationDetail:_uriString];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    _uriString = nil;
    _resultView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark - OHServerManagerDelegate methods

- (void)serverRequestDidFinished:(NSDictionary *)resultDict requestType:(NSInteger)requestType
{
    if (kRequestReservationDetail == requestType)
    {
        NSInteger errorCode = [[resultDict valueForKey:@"error"] intValue];

        if (0 == errorCode)
        {
            [_resultView setText:[NSString stringWithFormat:@"%@", [resultDict valueForKey:@"detail"]]];
        }
    }
}


@end
