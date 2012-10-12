//
//  MainViewController.h
//  OceanHolic
//
//  Created by darkpuca on 10/12/12.
//  Copyright (c) 2012 darkpuca. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OHServerManager.h"

@interface MainViewController : UIViewController <OHServerManagerDelegate>


@property (nonatomic, strong) IBOutlet UIButton *reserveButton, *logbookButton, *fishbookButton;


- (IBAction)reservePressed:(id)sender;
- (IBAction)logbookPressed:(id)sender;
- (IBAction)fishbookPressed:(id)sender;

@end
