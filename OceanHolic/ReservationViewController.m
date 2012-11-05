//
//  ReservationViewController.m
//  OceanHolic
//
//  Created by darkpuca on 9/28/12.
//  Copyright (c) 2012 darkpuca. All rights reserved.
//

#import "ReservationViewController.h"
#import "SVPullToRefresh.h"
#import "ReservationDetailViewController.h"
#import "QuickRootBuilder.h"
#import "NewReservationViewController.h"


//#import <SDWebImage/UIImageView+WebCache.h>


@interface ReservationViewController ()
{
    NSMutableArray *_reservItems;
}

- (void)refreshReservations;
- (void)composeButtonPressed:(id)sender;

@end

@implementation ReservationViewController



- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"예약문의"];

    _reservItems = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *composeBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeButtonPressed:)];
    [self.navigationItem setRightBarButtonItem:composeBarButton];
    
    
    __block ReservationViewController *me = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        [me refreshReservations];
    }];
    
    [self refreshReservations];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_reservItems count]; // 공지사항 & 예약글
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *sectionDict = [_reservItems objectAtIndex:section];
    NSArray *items = [sectionDict valueForKey:@"items"];
    return [items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell.textLabel setNumberOfLines:3];
        [cell.textLabel setFont:[UIFont systemFontOfSize:12.0f]];
    }
    NSDictionary *sectionDict = [_reservItems objectAtIndex:[indexPath section]];
    NSArray *items = [sectionDict valueForKey:@"items"];
    NSDictionary *itemDict = [items objectAtIndex:[indexPath row]];
    
    [cell.textLabel setText:[itemDict valueForKey:@"title"]];
    
    return cell;

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (0 == section)return @"공지사항";
    else if (1 == section) return @"예약";
    return nil;
}


#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *sectionDict = [_reservItems objectAtIndex:[indexPath section]];
    NSArray *items = [sectionDict valueForKey:@"items"];
    NSDictionary *itemDict = [items objectAtIndex:[indexPath row]];
    
    ReservationDetailViewController *viewController = [[ReservationDetailViewController alloc] initWithNibName:@"ReservationDetailViewController" bundle:nil];
    [viewController setUriString:[itemDict valueForKey:@"uri"]];
    [self.navigationController pushViewController:viewController animated:YES];
}



#pragma mark - Private functions

- (void)refreshReservations
{
    [[OHServerManager sharedManager] setDelegate:self];
    [[OHServerManager sharedManager] reservationItems];
}

- (void)composeButtonPressed:(id)sender
{
    NewReservationViewController *viewController = [[NewReservationViewController alloc] initWithNibName:@"NewReservationViewController" bundle:nil];
    UINavigationController *naviController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self.navigationController presentModalViewController:naviController animated:YES];
}


#pragma mark - Public functions



#pragma mark - OHServerManagerDelegate methods

- (void)serverRequestDidFinished:(NSDictionary *)resultDict requestType:(NSInteger)requestType
{
//    NSLog(@"server request result: %@", resultDict);
    NSInteger errorCode = [[resultDict valueForKey:@"error"] intValue];
    
    if (0 == errorCode)
    {
        [_reservItems removeAllObjects];
        [_reservItems addObjectsFromArray:[resultDict valueForKey:@"items"]];
        
        [self.tableView reloadData];
        [self.tableView.pullToRefreshView stopAnimating];
    }
}




@end
