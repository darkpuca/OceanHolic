//
//  QuickRootBuilder.m
//  OceanHolic
//
//  Created by darkpuca on 10/12/12.
//  Copyright (c) 2012 darkpuca. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "QuickRootBuilder.h"


@implementation QuickRootBuilder

+ (QRootElement *)createLoginRoot
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *userId = [userDefault stringForKey:@"userId"];
    BOOL autoLogin = [userDefault boolForKey:@"autoLogin"];
    NSString *password = autoLogin ? [userDefault stringForKey:@"password"] : nil;
    
    QRootElement *root = [[QRootElement alloc] init];
    root.grouped = YES;
    root.title = @"Login";
    
    UIView *loginHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 160)];
    [loginHeader setBackgroundColor:[UIColor clearColor]];
    UIImageView *logoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    [logoImage setCenter:loginHeader.center];
    [logoImage setClipsToBounds:YES];
    [logoImage setBackgroundColor:[UIColor clearColor]];
    [logoImage.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [logoImage.layer setBorderWidth:4.0f];
    [logoImage.layer setCornerRadius:16.0f];
    [loginHeader addSubview:logoImage];
    
    QSection *inputSection = [[QSection alloc] init];
    [inputSection setHeaderView:loginHeader];
    [inputSection setFooter:@"로그인 정보를 입력해 주세요."];
    
    QEntryElement *idElmt = [[QEntryElement alloc] initWithTitle:@"아이디" Value:userId Placeholder:@"User ID"];
    idElmt.key = @"userId";
    [inputSection addElement:idElmt];
    QEntryElement *pwdElmt = [[QEntryElement alloc] initWithTitle:@"비밀번호" Value:password Placeholder:@"Password"];
    pwdElmt.key = @"password";
    pwdElmt.secureTextEntry = YES;
    [inputSection addElement:pwdElmt];
    QBooleanElement *autoElmt = [[QBooleanElement alloc] initWithTitle:@"자동로그인" BoolValue:autoLogin];
    autoElmt.key = @"autoLogin";
    [inputSection addElement:autoElmt];
    
    QSection *buttonSection = [[QSection alloc] init];
    QButtonElement *loginElmt = [[QButtonElement alloc] initWithTitle:@"Login"];
    loginElmt.key = @"login";
    loginElmt.controllerAction = @"loginPressed:";
    [buttonSection addElement:loginElmt];

    [root addSection:inputSection];
    [root addSection:buttonSection];

    return root;
}


+ (QRootElement *)createNewReservationRoot
{
    QRootElement *root = [[QRootElement alloc] init];
    root.grouped = YES;
    root.title = @"글쓰기";
    
    QSection *titleSection = [[QSection alloc] initWithTitle:@"Title"];
    QEntryElement *titleElmt = [[QEntryElement alloc] initWithTitle:nil Value:nil Placeholder:@"제목 입력"];
    titleElmt.key = @"title";
    [titleSection addElement:titleElmt];
    
    QSection *contentSection = [[QSection alloc] initWithTitle:@"Content"];
    QTextElement *contentElmt = [[QTextElement alloc] init];
    contentElmt.key = @"content";
    contentElmt.font = [UIFont systemFontOfSize:12.0f];
    QButtonElement *writeElmt = [[QButtonElement alloc] initWithTitle:@"글쓰기"];
    writeElmt.controllerAction = @"writePressed:";
    [contentSection addElement:contentElmt];
    [contentSection addElement:writeElmt];
    
    QSection *buttonSection = [[QSection alloc] init];
    QButtonElement *registElmt = [[QButtonElement alloc] initWithTitle:@"Registraton"];
    registElmt.key = @"regist";
    registElmt.controllerAction = @"registPressed:";
    [buttonSection addElement:registElmt];
    
    [root addSection:titleSection];
    [root addSection:contentSection];
    [root addSection:buttonSection];

    return root;
}


@end
