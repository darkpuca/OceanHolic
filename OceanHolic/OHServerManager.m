//
//  OHServerManager.m
//  OceanHolic
//
//  Created by darkpuca on 9/28/12.
//  Copyright (c) 2012 darkpuca. All rights reserved.
//

#import "OHServerManager.h"
#import "ASIHTTPRequest.h"
#import "SVProgressHUD.h"
#import "DDXML.h"
#import "TBXML.h"

#define OHServerURL     @"http://www.oceanholic.com"


@interface OHServerManager()

- (void)parseReservationItems:(NSString *)htmlString withContainer:(NSMutableArray *)items;
- (void)parseReservationDetail:(NSString *)htmlString withContainer:(NSMutableDictionary *)itemDict;

- (NSString *)stringPickFromHTML:(NSString *)sourceString startString:(NSString *)sString endString:(NSString *)eString addonLength:(NSInteger)addon;
- (NSString *)stringPickFromHTML:(NSString *)sourceString startString:(NSString *)sString endString:(NSString *)eString;

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
    
    DDXMLDocument *tbodyDoc = [[DDXMLDocument alloc] initWithData:tbodyData options:0 error:nil];
    if (tbodyDoc)
    {
        NSArray *trElements = [tbodyDoc nodesForXPath:@"/tbody/tr" error:nil];
        if ([trElements count])
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

            for (int i = 0; i < [trElements count]; i++)
            {
                DDXMLElement *trElement = [trElements objectAtIndex:i];

                NSMutableArray *targetArray = nil;
                NSString *className = [[trElement attributeForName:@"class"] stringValue];
                BOOL isNotice = [[className substringToIndex:6] isEqualToString:@"notice"];
                if (isNotice)
                    targetArray = [[items objectAtIndex:0] valueForKey:@"items"];
                else
                    targetArray = [[items lastObject] valueForKey:@"items"];
                
                NSMutableDictionary *itemDict = [[NSMutableDictionary alloc] init];
                
                NSArray *link = [trElement nodesForXPath:@"./td[@class='title']/a" error:nil];
                if ([link count])
                {
                    DDXMLElement *uriElmt = [link objectAtIndex:0];
                    [itemDict setValue:[[uriElmt attributeForName:@"href"] stringValue] forKey:@"uri"];
                }
                
                NSArray *title = [trElement nodesForXPath:@"./td[@class='title']/a" error:nil];
                if ([title count])
                    [itemDict setValue:[[title objectAtIndex:0] stringValue] forKey:@"title"];
                
                NSArray *nickname = [trElement nodesForXPath:@"./td[@class='nick_name']" error:nil];
                if ([nickname count])
                    [itemDict setValue:[[nickname objectAtIndex:0] stringValue] forKey:@"nickName"];
                
                NSArray *readcount = [trElement nodesForXPath:@"./td[@class='readed_count']" error:nil];
                if ([readcount count])
                    [itemDict setValue:[NSNumber numberWithInt:[[[readcount objectAtIndex:0] stringValue] intValue]] forKey:@"count"];
                
                NSArray *regdate = [trElement nodesForXPath:@"./td[@class='regdate']" error:nil];
                if ([regdate count])
                    [itemDict setValue:[[regdate objectAtIndex:0] stringValue] forKey:@"regDate"];
                
                [targetArray addObject:itemDict];
            }
        }
    }
}

- (NSString *)stringPickFromHTML:(NSString *)sourceString startString:(NSString *)sString endString:(NSString *)eString
{
    return [self stringPickFromHTML:sourceString startString:sString endString:eString addonLength:0];
}

- (NSString *)stringPickFromHTML:(NSString *)sourceString startString:(NSString *)sString endString:(NSString *)eString addonLength:(NSInteger)addon
{
    if (nil == sourceString || nil == sString || nil == eString) return nil;
    
    NSRange range1 = [sourceString rangeOfString:sString];
    NSRange range2 = [sourceString rangeOfString:eString];
    NSRange contentRange = NSMakeRange(range1.location, range2.location - range1.location + addon);
    NSString *contentString = [sourceString substringWithRange:contentRange];
    return contentString;
}

- (void)parseReservationDetail:(NSString *)htmlString withContainer:(NSMutableDictionary *)itemDict
{
    if (nil == htmlString || nil == itemDict) return;
    
    NSString *originalContentHTML = [self stringPickFromHTML:htmlString
                                                 startString:@"<div class=\"originalContent\">"
                                                   endString:@"<div class=\"contentButton\">"];
    originalContentHTML = [originalContentHTML stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    
    NSData *originalContentData = [originalContentHTML dataUsingEncoding:NSUTF8StringEncoding];
    DDXMLDocument *originalContentDoc = [[DDXMLDocument alloc] initWithData:originalContentData options:0 error:nil];
    if (originalContentDoc)
    {
        NSArray *titles = [originalContentDoc nodesForXPath:@"/div/div[@class='readHeader']/div[@class='titleAndUser']/div[@class='title']" error:nil];
        if ([titles count])
            [itemDict setValue:[[titles objectAtIndex:0] stringValue] forKey:@"title"];
        
        NSArray *userinfos = [originalContentDoc nodesForXPath:@"/div/div[@class='readHeader']/div[@class='titleAndUser']/div[@class='userInfo']" error:nil];
        if ([userinfos count])
            [itemDict setValue:[[userinfos objectAtIndex:0] stringValue] forKey:@"author"];
        
        NSArray *readcounts = [originalContentDoc nodesForXPath:@"/div/div[@class='readHeader']/div[@class='dateAndCount']/div[@class='readedCount']" error:nil];
        if ([readcounts count])
        {
            NSString *countVal = [[[readcounts objectAtIndex:0] stringValue] stringByReplacingOccurrencesOfString:@"조회 수 : " withString:@""];
            [itemDict setValue:[NSNumber numberWithInt:[countVal intValue]] forKey:@"count"];
        }
        
        NSArray *dates = [originalContentDoc nodesForXPath:@"/div/div[@class='readHeader']/div[@class='dateAndCount']/div[@class='date']" error:nil];
        if ([dates count])
            [itemDict setValue:[[dates objectAtIndex:0] stringValue] forKey:@"regDate"];

        NSArray *pElements = [originalContentDoc nodesForXPath:@"/div/div/div[@class='contentBody']/div/p" error:nil];
        if (0 == [pElements count])
        {
            pElements = [originalContentDoc nodesForXPath:@"/div/div/div[@class='contentBody']/div/div" error:nil];
        }
        
        if ([pElements count])
        {
            NSMutableString *content = [[NSMutableString alloc] init];
            for (int i = 0; i < [pElements count]; i++)
            {
                DDXMLElement *pElement = [pElements objectAtIndex:i];
                if ([[[pElement attributeForName:@"class"] stringValue] isEqualToString:@"document_popup_menu"])
                    break;
                [content appendFormat:@"%@\n", pElement.stringValue];
            }
            [itemDict setValue:content forKey:@"content"];
//            NSLog(@"contentBody: %@", [content stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
        }
    }
    
    NSString *repliesHTML = [self stringPickFromHTML:htmlString
                                                 startString:@"<div class=\"replyBox\">"
                                                   endString:@"<a name=\"comment_form\"></a>"];
    repliesHTML = [repliesHTML stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    NSData *repliesData = [repliesHTML dataUsingEncoding:NSUTF8StringEncoding];
    DDXMLDocument *repliesDoc = [[DDXMLDocument alloc] initWithData:repliesData options:0 error:nil];
    if (repliesDoc)
    {
        NSArray *replyElmts = [repliesDoc nodesForXPath:@"/div/div[@class!='clear']" error:nil];
        if ([replyElmts count])
        {
            NSMutableArray *replies = [[NSMutableArray alloc] init];
            for (int i = 0; i < [replyElmts count]; i++)
            {
                NSMutableDictionary *replyDict = [[NSMutableDictionary alloc] init];
                DDXMLElement *replyElmt = [replyElmts objectAtIndex:i];
                
                NSArray *dateArray = [replyElmt nodesForXPath:@"./div[@class='date']" error:nil];
                if ([dateArray count]) [replyDict setValue:[[dateArray objectAtIndex:0] stringValue] forKey:@"date"];
                
                NSArray *authorArray = [replyElmt nodesForXPath:@"./div[@class='author']" error:nil];
                if ([authorArray count]) [replyDict setValue:[[authorArray objectAtIndex:0] stringValue] forKey:@"author"];
                
                NSArray *imageArray = [replyElmt nodesForXPath:@"./div/div/div/div/div/img" error:nil];
                if ([imageArray count])
                {
                    NSString *imageUrl = [[[imageArray objectAtIndex:0] attributeForName:@"src"] stringValue];
                    [replyDict setValue:imageUrl forKey:@"profileUrl"];
                }
                
                NSArray *pArray = [replyElmt nodesForXPath:@"./div/div/div/p" error:nil];
                if (0 == [pArray count])
                    pArray = [replyElmt nodesForXPath:@"./div/div/div/div" error:nil];
                
                if ([pArray count])
                {
                    NSMutableString *content = [[NSMutableString alloc] init];
                    for (int i = 0; i < [pArray count]; i++)
                    {
                        DDXMLElement *pElmt = [pArray objectAtIndex:i];
                        
                        if ([[[pElmt attributeForName:@"class"] stringValue] isEqualToString:@"comment_popup_menu"]) break;
                        [content appendFormat:@"%@\n", [pElmt stringValue]];
                    }
                    [replyDict setValue:content forKey:@"content"];
                }
                [replies addObject:replyDict];
            }
            [itemDict setValue:replies forKey:@"replies"];
        }
    }
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
//    NSLog(@"responseString: %@\n", responseString);
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
