//
//  OHServerManager.m
//  OceanHolic
//
//  Created by darkpuca on 9/28/12.
//  Copyright (c) 2012 darkpuca. All rights reserved.
//

#import "OHServerManager.h"
#import "ASIHTTPRequest.h"
#import "TBXML.h"


#define OHServerURL     @"http://www.oceanholic.com"


static OHServerManager *_sharedManager;

@implementation OHServerManager

@synthesize delegate = _delegate;


+ (OHServerManager *)sharedManager
{
    if (nil == _sharedManager)
        _sharedManager = [[OHServerManager alloc] init];

    return _sharedManager;
}




- (void)request:(NSString *)URI method:(NSString *)method
{
    [self request:URI method:method withBody:nil];
}

- (void)request:(NSString *)URI method:(NSString *)method withBody:(NSString *)xmlString
{
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", OHServerURL, URI];
    NSLog(@"request url: %@", urlString);
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [request setDelegate:self];
    [request setTimeOutSeconds:30];
    [request setNumberOfTimesToRetryOnTimeout:3];
//    [request addRequestHeader:@"X-Requested-With" value:@"XMLHttpRequest"];
    [request setRequestMethod:method];
    
    
    if ([method isEqualToString:@"POST"] || [method isEqualToString:@"PUT"])
    {
        if (xmlString)
        {
            NSData *someData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
            [request appendPostData:someData];
        }
    }
    
    _currentRequest = request;
    [request startAsynchronous];
    
}



- (void)login:(NSDictionary *)params
{
    _requestType = kRequestLogin;
    
    NSMutableString *xmlString = [[NSMutableString alloc] init];
	[xmlString appendString:@"<?xml version='1.0' encoding='UTF-8'?>\n"];
	[xmlString appendString:@"<methodCall>\n"];
	[xmlString appendString:@"<params>\n"];
	[xmlString appendString:@"<_filter><![CDATA[login]]></_filter>\n"];
	[xmlString appendFormat:@"<user_id><![CDATA[%@]]></user_id>\n", [params valueForKey:@"userId"]];
	[xmlString appendFormat:@"<password><![CDATA[%@]]></password>\n", [params valueForKey:@"password"]];
	[xmlString appendString:@"<module><![CDATA[member]]></module>\n"];
	[xmlString appendString:@"<act><![CDATA[procMemberLogin]]></act>\n"];
	[xmlString appendString:@"</params>\n"];
	[xmlString appendString:@"</methodCall>\n"];
	NSLog(@"%@", xmlString);
    
    [self request:@"home/index.php" method:@"POST" withBody:xmlString];
}

- (void)reservationItems
{
    
}



#pragma mark - ASIHTTPRequestDelegate methods

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *responseString = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
    NSLog(@"responseString: %@\n", responseString);
//    NSLog(@"request headers: %@\n", request.requestHeaders);
//    NSLog(@"response headers: %@\n", request.responseHeaders);
    
    NSError *xmlError;
    NSData *xmlData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
    TBXML *responseXML = [TBXML newTBXMLWithXMLData:xmlData error:&xmlError];
    if (nil == responseXML.rootXMLElement)
    {
        if ([_delegate respondsToSelector:@selector(serverRequestDidFailed:)])
            [_delegate serverRequestDidFailed:xmlError];
        return;
    }

    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
    
    TBXMLElement *errorElmt = [TBXML childElementNamed:@"error" parentElement:responseXML.rootXMLElement];
    if (errorElmt) [resultDict setValue:[NSNumber numberWithInt:[[TBXML textForElement:errorElmt] intValue]] forKey:@"error"];
    TBXMLElement *messageElmt = [TBXML childElementNamed:@"message" parentElement:responseXML.rootXMLElement];
    if (messageElmt) [resultDict setValue:[TBXML textForElement:messageElmt] forKey:@"message"];
    
    if ([_delegate respondsToSelector:@selector(serverRequestDidFinished:)])
        [_delegate serverRequestDidFinished:resultDict];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"request failed: %@", request.error);
    
    if ([_delegate respondsToSelector:@selector(serverRequestDidFailed:)])
        [_delegate serverRequestDidFailed:request.error];
}



@end
