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

#import "AsynchronousDataSource.h"
#import "CachedDataLoader.h"
#import "DataConsumer.h"


@implementation AsynchronousDataSource

@synthesize item;

- (void)dealloc
{
    [activeRequests release];
    [item release];

    [super dealloc];
}

- (id)init
{
	if(self = [super init]) {
		lastRequestId = 0;
		activeRequests = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)cancelRequest:(NSInteger)theRequestId
{
    @synchronized(self) {
        [activeRequests removeObjectForKey:[NSNumber numberWithInteger:theRequestId]];
    }
}

- (void)receiveRequest:(NSInteger)theRequestId withItem:(id)theItem withResult:(NSInteger)theResult
{
	@synchronized(self) {
        self.item = theItem;
        NSNumber *requestId = [NSNumber numberWithInteger:theRequestId];
        NSObject<AsynchronousDelegate> *delegate = [activeRequests objectForKey:requestId];
        if (delegate != nil) {
            [activeRequests removeObjectForKey:requestId];
            [delegate performSelectorOnMainThread:@selector(receive:) withObject:theItem waitUntilDone:YES];
        }
    }
}

- (NSInteger)request:(NSString *)theUrl
       consumerClass:(Class)theConsumerClass
      notifyDelegate:(NSObject<AsynchronousDelegate> *)theDelegate
{
    return [self request:theUrl
           consumerClass:theConsumerClass
          notifyDelegate:theDelegate
          withExpiration:(60 * 20)]; // 20 minutes
}

- (NSInteger)request:(NSString *)theUrl
       consumerClass:(Class)theConsumerClass
      notifyDelegate:(NSObject<AsynchronousDelegate> *)theDelegate
      withExpiration:(NSInteger)theExpiration
{
    NSNumber *requestId = nil;
    @synchronized(self) {
        lastRequestId++;
        requestId = [NSNumber numberWithInteger:lastRequestId];

        DataConsumer *consumer = [[theConsumerClass alloc] initWithRequestId:lastRequestId
                                                              withDataSource:self
                                                                     withUrl:theUrl];

        [activeRequests setObject:theDelegate forKey:requestId];

        CachedDataLoader *dataLoader = [CachedDataLoader sharedDataLoader];
        [dataLoader addClientToDownloadQueue:consumer withExpiration:theExpiration];
        [consumer release];
    }
    return [requestId intValue];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self doesNotRecognizeSelector:_cmd];
    @throw @"doesNotRecognizeSelector";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self doesNotRecognizeSelector:_cmd];
    @throw @"doesNotRecognizeSelector";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 0;
}

@end
