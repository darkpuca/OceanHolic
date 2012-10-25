//
//  NewReservationViewController.m
//  OceanHolic
//
//  Created by darkpuca on 10/25/12.
//  Copyright (c) 2012 darkpuca. All rights reserved.
//

#import "NewReservationViewController.h"

@interface NewReservationViewController ()

- (void)writePressed:(id)sender;
- (void)registPressed:(id)sender;

@end

@implementation NewReservationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Private methods

- (void)writePressed:(id)sender
{
    
}


- (void)registPressed:(id)sender
{
    QEntryElement *titleElmt = (QEntryElement *)[self.root elementWithKey:@"title"];
    QMultilineElement *contentElmt = (QMultilineElement *)[self.root elementWithKey:@"content"];
    
    if (nil == titleElmt.textValue || nil == contentElmt.textValue)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"확인"
                                                            message:@"입력 정보를 확인 해 주십시요."
                                                           delegate:nil
                                                  cancelButtonTitle:@"닫기"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:2];
    [params setValue:titleElmt.textValue forKey:@"title"];
    [params setValue:contentElmt.textValue forKey:@"content"];
    
    [[OHServerManager sharedManager] setDelegate:self];
    [[OHServerManager sharedManager] reservationRegist:params];

}


#pragma mark - Public methods






#pragma mark - OHServerManagerDelegate methods

- (void)serverRequestDidFinished:(NSDictionary *)resultDict requestType:(NSInteger)requestType
{
    
    
}






@end
