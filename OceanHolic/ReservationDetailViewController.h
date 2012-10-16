//
//  ReservationDetailViewController.h
//  OceanHolic
//
//  Created by darkpuca on 10/16/12.
//  Copyright (c) 2012 darkpuca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OHServerManager.h"

@interface ReservationDetailViewController : UIViewController <OHServerManagerDelegate>

@property (nonatomic, strong) NSString *uriString;
@property (nonatomic, strong) IBOutlet UITextView *resultView;

@end
