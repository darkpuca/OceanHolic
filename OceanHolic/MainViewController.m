//
//  MainViewController.m
//  OceanHolic
//
//  Created by darkpuca on 10/12/12.
//  Copyright (c) 2012 darkpuca. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    _reserveButton = nil;
    _logbookButton = nil;
    _fishbookButton = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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



#pragma mark - Public methods

- (IBAction)reservePressed:(id)sender
{
    
    
}

- (IBAction)logbookPressed:(id)sender
{
    
}

- (IBAction)fishbookPressed:(id)sender
{
    
}



@end
