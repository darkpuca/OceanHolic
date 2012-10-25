//
//  QuickRootBuilder.h
//  OceanHolic
//
//  Created by darkpuca on 10/12/12.
//  Copyright (c) 2012 darkpuca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuickDialog/QuickDialog.h>

@interface QuickRootBuilder : NSObject

+ (QRootElement *)createLoginRoot;
+ (QRootElement *)createNewReservationRoot;

@end
