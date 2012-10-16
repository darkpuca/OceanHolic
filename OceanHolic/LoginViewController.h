//
//  LoginViewController.h
//  OceanHolic
//
//  Created by darkpuca on 10/12/12.
//  Copyright (c) 2012 darkpuca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickDialog/QuickDialog.h>
#import "OHServerManager.h"


@protocol LoginViewDelegate <NSObject>

- (void)loginDidFinished;

@end


@interface LoginViewController : QuickDialogController <OHServerManagerDelegate>

@property (nonatomic, unsafe_unretained) id<LoginViewDelegate> loginDelegate;

@end
