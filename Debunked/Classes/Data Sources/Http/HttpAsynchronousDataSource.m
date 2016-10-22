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

#import "HttpAsynchronousDataSource.h"


@implementation HttpAsynchronousDataSource

- (id)init
{
	if(self = [super init]) {
		lastRequestId = 0;
		activeRequests = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (NSInteger)requestItemForIndexPath:(NSIndexPath *)theIndexPath notifyDelegate:(NSObject<AsynchronousDelegate> *)theDelegate
{
	NSNumber *requestId = nil;
	@synchronized(self) {
		lastRequestId++;
		requestId = [NSNumber numberWithInteger:lastRequestId];
		NSArray *theRequest = [NSArray arrayWithObjects:
							   NSStringFromSelector(@selector(doRequestItemForIndexPath:notifyDelegate:)), 
							   theIndexPath, 
							   theDelegate, 
							   nil];
		[activeRequests setObject:theRequest forKey:requestId];
		[self performSelector:@selector(validateRequest:) withObject:requestId];
	}
	return [requestId intValue];
}

- (void)doRequestItemForIndexPath:(NSIndexPath *)theIndexPath notifyDelegate:(NSObject<AsynchronousDelegate> *)theDelegate
{
	
}

- (void)cancelRequest:(NSInteger)theRequestId
{
	@synchronized(self) {
		[activeRequests removeObjectForKey:[NSNumber numberWithInteger:theRequestId]];
	}
}

- (void)validateRequest:(NSNumber *)theRequestId
{
	@synchronized(self) {
		NSArray *theRequest = (NSArray *)[activeRequests objectForKey:theRequestId];
		if (theRequest != nil) {
			[theRequest retain];
			@try {
				[activeRequests removeObjectForKey:theRequestId];
				SEL method = NSSelectorFromString([theRequest objectAtIndex:0]);
				if ([theRequest count] == 1) {
					[self performSelector:method];
				} else if ([theRequest count] == 2) {
					id anObject = [theRequest objectAtIndex:1];
					[self performSelector:method withObject:anObject];
				} else {
					id anObject1 = [theRequest objectAtIndex:1];
					id anObject2 = [theRequest objectAtIndex:2];
					[self performSelector:method withObject:anObject1 withObject:anObject2];
				}
			}
			@catch (NSException * e) {
				// Do nothing
			}
			@finally {
				[theRequest release];
			}
		}
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)theIndexPath
{
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 0;
}

- (void)dealloc {
	[activeRequests release];
	
	[super dealloc];
}

@end
