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
#import "SVProgressHUD.h"

#define OHServerURL     @"http://www.oceanholic.com"


@interface OHServerManager()

- (void)parseReservationItems:(NSString *)htmlString withContainer:(NSMutableArray *)items;
- (void)parseReservationDetail:(NSString *)htmlString withContainer:(NSMutableDictionary *)itemDict;

@end








static OHServerManager *_sharedManager;
static BOOL _isLogin;

@implementation OHServerManager

@synthesize delegate = _delegate;


+ (OHServerManager *)sharedManager
{
    if (nil == _sharedManager)
    {
        _sharedManager = [[OHServerManager alloc] init];
        _isLogin = NO;
    }

    return _sharedManager;
}

+ (BOOL)isLogin
{
    return _isLogin;
}


- (NSString *)currentUserID
{
    if (_isLogin)
        return _loggedInUser;
    
    return nil;
}


- (void)parseReservationItems:(NSString *)htmlString withContainer:(NSMutableArray *)items
{
    if (nil == htmlString || nil == items) return;
    
    NSRange range1 = [htmlString rangeOfString:@"<tbody>"];
    NSRange range2 = [htmlString rangeOfString:@"</tbody>"];
    NSRange tbodyRange = NSMakeRange(range1.location, range2.location + range2.length - range1.location);
    NSString *tbodyString = [htmlString substringWithRange:tbodyRange];

    NSData *tbodyData = [tbodyString dataUsingEncoding:NSUTF8StringEncoding];
    TBXML *tbodyXml = [TBXML newTBXMLWithXMLData:tbodyData error:nil];
    
    if (tbodyXml.rootXMLElement)
    {
        TBXMLElement *trElmt = [TBXML childElementNamed:@"tr" parentElement:tbodyXml.rootXMLElement];
        if (trElmt)
        {
            // add notice group
            NSMutableDictionary *noticeDict = [[NSMutableDictionary alloc] init];
            [noticeDict setValue:@"notice" forKey:@"type"];
            NSMutableArray *noticeItems = [[NSMutableArray alloc] init];
            [noticeDict setValue:noticeItems forKey:@"items"];
            [items addObject:noticeDict];
            
            // add content group
            NSMutableDictionary *reservDict = [[NSMutableDictionary alloc] init];
            [reservDict setValue:@"reserv" forKey:@"type"];
            NSMutableArray *reservItems = [[NSMutableArray alloc] init];
            [reservDict setValue:reservItems forKey:@"items"];
            [items addObject:reservDict];
            
            NSMutableArray *targetArray = nil;
            
            do
            {
                NSString *trClass = [TBXML valueOfAttributeNamed:@"class" forElement:trElmt];
                BOOL isNotice = (1 < [[trClass componentsSeparatedByString:@" "] count]);
                if (isNotice)
                    targetArray = [[items objectAtIndex:0] valueForKey:@"items"];
                else
                    targetArray = [[items lastObject] valueForKey:@"items"];
                
                NSMutableDictionary *itemDict = [[NSMutableDictionary alloc] init];

                TBXMLElement *tdElmt = [TBXML childElementNamed:@"td" parentElement:trElmt];
                if (tdElmt)
                {
                    do
                    {
                        
                        NSString *classVal = [TBXML valueOfAttributeNamed:@"class" forElement:tdElmt];
                        if ([classVal isEqualToString:@"nick_name"])
                        {
                            TBXMLElement *divElmt = [TBXML childElementNamed:@"div" parentElement:tdElmt];
                            if (divElmt) [itemDict setValue:[TBXML textForElement:divElmt] forKey:@"nickName"];
                        }
                        else if ([classVal isEqualToString:@"regdate"])
                        {
                            [itemDict setValue:[TBXML textForElement:tdElmt] forKey:@"regDate"];
                        }
                        else if ([classVal isEqualToString:@"title"])
                        {
                            TBXMLElement *aElmt = [TBXML childElementNamed:@"a" parentElement:tdElmt];
                            if (aElmt)
                            {
                                NSString *uriString = [[TBXML valueOfAttributeNamed:@"href" forElement:aElmt] stringByReplacingOccurrencesOfString:@"amp;" withString:@""];
                                [itemDict setValue:uriString forKey:@"uri"];
                                
                                TBXMLElement *spanElmt = [TBXML childElementNamed:@"span" parentElement:aElmt];
                                if (spanElmt)
                                    [itemDict setValue:[TBXML textForElement:spanElmt] forKey:@"title"];
                                else
                                    [itemDict setValue:[TBXML textForElement:aElmt] forKey:@"title"];
                                
                            }
                        }
                    } while ((tdElmt = [TBXML nextSiblingNamed:@"td" searchFromElement:tdElmt]));
                }
            
                NSLog(@"item title: %@", [itemDict valueForKey:@"title"]);
                [targetArray addObject:itemDict];
            } while ((trElmt = [TBXML nextSiblingNamed:@"tr" searchFromElement:trElmt]));

        }
    }
}

- (void)parseReservationDetail:(NSString *)htmlString withContainer:(NSMutableDictionary *)itemDict
{
    if (nil == htmlString || nil == itemDict) return;
    
    NSRange range1 = [htmlString rangeOfString:@"<tbody>"];
    NSRange range2 = [htmlString rangeOfString:@"</tbody>"];

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
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
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

    _loggedInUser = [NSString stringWithString:[params valueForKey:@"userId"]];
    
    [self request:@"home/index.php" method:@"POST" withBody:xmlString];
}

- (void)reservationItems
{
    _requestType = kRequestReservationItems;
    
    NSString *uriString = [NSString stringWithFormat:@"home/?mid=sub41&search_target=user_id&search_keyword=%@", _loggedInUser];
    [self request:uriString method:@"GET"];
}

- (void)reservationDetail:(NSString *)uriString
{
    _requestType = kRequestReservationDetail;
    [self request:uriString method:@"GET"];    
}



#pragma mark - ASIHTTPRequestDelegate methods

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [SVProgressHUD dismiss];
    
    NSString *responseString = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
    NSLog(@"responseString: %@\n", responseString);
//    NSLog(@"request headers: %@\n", request.requestHeaders);
//    NSLog(@"response headers: %@\n", request.responseHeaders);
    
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];

    if (kRequestReservationItems == _requestType)
    {
        NSMutableArray *items = [[NSMutableArray alloc] init];
        [self parseReservationItems:responseString withContainer:items];
        [resultDict setValue:items forKey:@"items"];
    }
    else if (kRequestReservationDetail == _requestType)
    {
        NSMutableDictionary *itemDict = [[NSMutableDictionary alloc] init];
        [self parseReservationDetail:responseString withContainer:itemDict];
        [resultDict setValue:itemDict forKey:@"detail"];
    }
    else
    {
        NSError *xmlError;
        NSData *xmlData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        TBXML *responseXML = [TBXML newTBXMLWithXMLData:xmlData error:&xmlError];
        if (nil == responseXML.rootXMLElement)
        {
            if ([_delegate respondsToSelector:@selector(serverRequestDidFailed:)])
                [_delegate serverRequestDidFailed:xmlError requestType:_requestType];
            return;
        }
        
        TBXMLElement *errorElmt = [TBXML childElementNamed:@"error" parentElement:responseXML.rootXMLElement];
        if (errorElmt) [resultDict setValue:[NSNumber numberWithInt:[[TBXML textForElement:errorElmt] intValue]] forKey:@"error"];
        TBXMLElement *messageElmt = [TBXML childElementNamed:@"message" parentElement:responseXML.rootXMLElement];
        if (messageElmt) [resultDict setValue:[TBXML textForElement:messageElmt] forKey:@"message"];
    }
    
    if (kRequestLogin == _requestType)
    {
        if (0 == [[resultDict valueForKey:@"error"] intValue])
            _isLogin = YES;
        else
            _loggedInUser = nil;
    }
    
    if ([_delegate respondsToSelector:@selector(serverRequestDidFinished:requestType:)])
        [_delegate serverRequestDidFinished:resultDict requestType:_requestType];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [SVProgressHUD dismiss];
    
    NSLog(@"request failed: %@", request.error);
    
    if ([_delegate respondsToSelector:@selector(serverRequestDidFailed:requestType:)])
        [_delegate serverRequestDidFailed:request.error requestType:_requestType];
}



@end
