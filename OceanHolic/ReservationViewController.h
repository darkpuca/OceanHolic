//
//  ReservationViewController.h
//  OceanHolic
//
//  Created by darkpuca on 9/28/12.
//  Copyright (c) 2012 darkpuca. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OHServerManager.h"

@interface ReservationViewController : UIViewController <OHServerManagerDelegate>

@property (nonatomic, strong) IBOutlet UIButton *listButton;

- (IBAction)loginButtonPressed:(id)sender;
- (IBAction)listButtonPressed:(id)sender;

@end
