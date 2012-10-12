//
//  OHServerManager.h
//  OceanHolic
//
//  Created by darkpuca on 9/28/12.
//  Copyright (c) 2012 darkpuca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequestDelegate.h"

enum OHServerRequestType
{
    kRequestLogin,
    kRequestReservationItems,
};




@protocol OHServerManagerDelegate <NSObject>

- (void)serverRequestDidFinished:(NSDictionary *)resultDict;

@optional
- (void)serverRequestDidFailed:(NSError *)error;

@end



@class ASIHTTPRequest;

@interface OHServerManager : NSObject <ASIHTTPRequestDelegate>
{
    NSUInteger _requestType;
    ASIHTTPRequest *_currentRequest;
    NSString *_loggedInUser;
    
}

@property (nonatomic, unsafe_unretained) id<OHServerManagerDelegate> delegate;


+ (OHServerManager *)sharedManager;
+ (BOOL)isLogin;


- (NSString *)currentUserID;


- (void)request:(NSString *)URI method:(NSString *)method;
- (void)request:(NSString *)URI method:(NSString *)method withBody:(NSString *)xmlString;


- (void)login:(NSDictionary *)params;
- (void)reservationItems;



@end
