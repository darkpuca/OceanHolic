//
//  NewReservationViewController.m
//  OceanHolic
//
//  Created by darkpuca on 10/25/12.
//  Copyright (c) 2012 darkpuca. All rights reserved.
//

#import "NewReservationViewController.h"

@interface NewReservationViewController ()

- (void)writePressed:(id)sender;
- (void)registPressed:(id)sender;

@end

@implementation NewReservationViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}



#pragma mark - Private methods

- (void)writePressed:(id)sender
{
    
}


- (void)registPressed:(id)sender
{

}


#pragma mark - Public methods






#pragma mark - OHServerManagerDelegate methods

- (void)serverRequestDidFinished:(NSDictionary *)resultDict requestType:(NSInteger)requestType
{
    
    
}






@end
