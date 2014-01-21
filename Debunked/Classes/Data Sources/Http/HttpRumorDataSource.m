//  Copyright (c) 2009-2014 Robert Ruana <rob@relentlessidiot.com>
//
//  This file is part of Debunked.
//
//  Debunked is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Debunked is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Debunked.  If not, see <http://www.gnu.org/licenses/>.

#import <stdlib.h>

#import "JSON.h"
#import "RumorNode.h"
#import "RumorNodeTableViewCell.h"
#import "HttpRumorDataSource.h"


@implementation HttpRumorDataSource

@synthesize rumorNodes;

- (id) init
{
	return [self initWithRumorNodes:[[[NSMutableArray alloc] init] autorelease]];
}

- (id) initWithRumorNodes:(NSMutableArray *)theRumorNodes
{
	if(self = [super init]) {
		[self loadRumorNodes: theRumorNodes];
		lastRequestId = 0;
	}
	return self;
	
}

- (void)loadRumorNodes:(NSMutableArray *)theRumorNodes
{
	self.rumorNodes = theRumorNodes;
}

- (RumorNode *)rumorNodeForIndex:(NSUInteger)theIndex
{
	if([rumorNodes count] > 0) {
		return [rumorNodes objectAtIndex:theIndex];
	} else {
		return nil;
	}
}

- (NSInteger)requestTop25RumorNodesNotifyDelegate:(NSObject<RumorDelegate> *)theDelegate
{
	NSNumber *requestId = nil;
	@synchronized(self) {
		lastRequestId++;
		requestId = [NSNumber numberWithInt:lastRequestId];
		
		Top25RumorConsumer *consumer = [[Top25RumorConsumer alloc] initWithDelegate:theDelegate 
														   withDataSource:self
																  withUrl:@"http://www.snopes.com/info/top25uls.asp"];
		NSArray *theRequest = [NSArray arrayWithObjects:
							   consumer, 
							   theDelegate, 
							   nil];
		[activeRequests setObject:theRequest forKey:requestId];
		
		CachedDataLoader *dataLoader = [CachedDataLoader sharedDataLoader];
		[dataLoader addClientToDownloadQueue:consumer withExpiration:(60 * 60 * 4)]; // 4 hours
		[consumer release];
	}
	return [requestId intValue];
}


- (NSInteger)requestWhatsNewRumorNodesNotifyDelegate:(NSObject<RumorDelegate> *)theDelegate
{
	NSNumber *requestId = nil;
	@synchronized(self) {
		lastRequestId++;
		requestId = [NSNumber numberWithInt:lastRequestId];
		
		WhatsNewRumorConsumer *consumer = [[WhatsNewRumorConsumer alloc] initWithDelegate:theDelegate 
														   withDataSource:self
																  withUrl:@"http://www.snopes.com/info/whatsnew.asp"];
		NSArray *theRequest = [NSArray arrayWithObjects:
							   consumer, 
							   theDelegate, 
							   nil];
		[activeRequests setObject:theRequest forKey:requestId];
		
		CachedDataLoader *dataLoader = [CachedDataLoader sharedDataLoader];
		[dataLoader addClientToDownloadQueue:consumer withExpiration:(60 * 60 * 4)]; // 4 hours
		[consumer release];
	}
	return [requestId intValue];
}

- (NSInteger)requestRandomRumorNotifyDelegate:(NSObject<RumorDelegate> *)theDelegate
{
	NSNumber *requestId = nil;
	@synchronized(self) {
		lastRequestId++;
		requestId = [NSNumber numberWithInt:lastRequestId];
		
		RumorConsumer *consumer = [[RumorConsumer alloc] initWithDelegate:theDelegate 
														   withDataSource:self
																  withUrl:@"http://www.snopes.com/info/random/random.asp"];
		NSArray *theRequest = [NSArray arrayWithObjects:
							   consumer, 
							   theDelegate, 
							   nil];
		[activeRequests setObject:theRequest forKey:requestId];
		
		CachedDataLoader *dataLoader = [CachedDataLoader sharedDataLoader];
		[dataLoader addClientToDownloadQueue:consumer withExpiration:0];
		[consumer release];
	}
	return [requestId intValue];
}

- (NSInteger)requestRumor:(NSString *)url notifyDelegate:(NSObject<RumorDelegate> *)theDelegate
{
	NSNumber *requestId = nil;
	@synchronized(self) {
		lastRequestId++;
		requestId = [NSNumber numberWithInt:lastRequestId];
		
		RumorConsumer *consumer = [[RumorConsumer alloc] initWithDelegate:theDelegate 
														   withDataSource:self
																  withUrl:url];
		NSArray *theRequest = [NSArray arrayWithObjects:
							   consumer, 
							   theDelegate, 
							   nil];
		[activeRequests setObject:theRequest forKey:requestId];
		
		CachedDataLoader *dataLoader = [CachedDataLoader sharedDataLoader];
		[dataLoader addClientToDownloadQueue:consumer withExpiration:(60 * 60 * 24 * 7)]; // 1 week
		[consumer release];
	}
	return [requestId intValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	RumorNodeTableViewCell *cell = (RumorNodeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"RumorNodeTableViewCell"];
	if (cell == nil) {
		cell = [[[RumorNodeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RumorNodeTableViewCell"] autorelease];
	}
	cell.rumorNode = [self rumorNodeForIndex:indexPath.row];
	
	return cell;
}

- (void)doRequestItemForIndexPath:(NSIndexPath *)theIndexPath notifyDelegate:(NSObject<AsynchronousDelegate> *)theDelegate
{
	RumorNode *aRumorNode = [self rumorNodeForIndex:theIndexPath.row];	
	
	RumorConsumer *consumer = [[RumorConsumer alloc] initWithDelegate:(NSObject<RumorDelegate> *)theDelegate
													   withDataSource:self
															  withUrl:aRumorNode.url];	
	CachedDataLoader *dataLoader = [CachedDataLoader sharedDataLoader];
	[dataLoader addClientToDownloadQueue:consumer withExpiration:(60 * 60 * 24 * 7)]; // 1 week
	[consumer release];
}

- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section {
	return [rumorNodes count];
}

- (void)dealloc {
	[rumorNodes release];
	
	[super dealloc];
}


@end
