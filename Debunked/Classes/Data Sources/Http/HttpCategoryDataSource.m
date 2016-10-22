//  Copyright (c) 2009-2016 Robert Ruana <rob@robruana.com>
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

#import "TFHpple.h"
#import "CategoryNode.h"
#import "RumorNode.h"
#import "CategoryNodeTableViewCell.h"
#import "HttpCategoryDataSource.h"
#import "HttpRumorDataSource.h"
#import "JSON.h"


@implementation HttpCategoryDataSource

@synthesize categoryNodes;

- (id) init
{
	return [self initWithCategoryNodes:[[[NSMutableArray alloc] init] autorelease]];
}

- (id) initWithCategoryNodes:(NSMutableArray *)theCategoryNodes
{
	if(self = [super init]) {
		[self loadCategoryNodes:theCategoryNodes];
		lastRequestId = 0;
	}
	return self;
}

- (CategoryNode *)categoryNodeForIndexPath:(NSIndexPath *)theIndexPath
{
	if([categoryNodes count] > 0) {
		return [categoryNodes objectAtIndex:theIndexPath.row];
	} else {
		return nil;
	}
}

- (void)doRequestItemForIndexPath:(NSIndexPath *)theIndexPath notifyDelegate:(NSObject<AsynchronousDelegate> *)theDelegate
{
	CategoryNode *aCategoryNode = [self categoryNodeForIndexPath:theIndexPath];
	
	
	CategoryConsumer *consumer = [[CategoryConsumer alloc] initWithDelegate:(NSObject<CategoryDelegate> *)theDelegate
															 withDataSource:self
																	withUrl:aCategoryNode.url];	
	CachedDataLoader *dataLoader = [CachedDataLoader sharedDataLoader];
	[dataLoader addClientToDownloadQueue:consumer withExpiration:(60 * 60 * 24 * 7)]; // 1 week
	[consumer release];
}

- (void)loadCategoryNodes:(NSMutableArray *)theCategoryNodes
{
	self.categoryNodes = theCategoryNodes;
}

- (NSInteger)requestTopLevelCategoryNodesNotifyDelegate:(NSObject<CategoryDelegate> *)theDelegate
{
	NSNumber *requestId = nil;
	@synchronized(self) {
		lastRequestId++;
		requestId = [NSNumber numberWithInteger:lastRequestId];
		
		TopLevelCategoryConsumer *consumer = [[TopLevelCategoryConsumer alloc] initWithDelegate:theDelegate 
																				 withDataSource:self];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)theIndexPath
{
	CategoryNodeTableViewCell *cell = (CategoryNodeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CategoryNodeTableViewCell"];
	if (cell == nil) {
		cell = [[[CategoryNodeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CategoryNodeTableViewCell"] autorelease];
	}
	cell.categoryNode = [self categoryNodeForIndexPath:theIndexPath];
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section {
	return [categoryNodes count];
}

- (void)dealloc {
	[categoryNodes release];
	
	[super dealloc];
}


@end
