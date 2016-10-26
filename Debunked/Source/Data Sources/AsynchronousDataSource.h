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

#import <Foundation/Foundation.h>


@protocol AsynchronousDelegate

@required

- (void)receive:(id)theItem;

@end


@interface AsynchronousDataSource: NSObject<UITableViewDataSource>
{
	NSInteger lastRequestId;
	NSMutableDictionary *activeRequests;
}

@property (nonatomic,retain) id item;

- (void)cancelRequest:(NSInteger)theRequestId;
- (void)receiveRequest:(NSInteger)theRequestId withItem:(id)theItem withResult:(NSInteger)theResult;
- (NSInteger)request:(NSString *)theUrl
       consumerClass:(Class)theConsumerClass
      notifyDelegate:(NSObject<AsynchronousDelegate> *)theDelegate;
- (NSInteger)request:(NSString *)theUrl
       consumerClass:(Class)theConsumerClass
      notifyDelegate:(NSObject<AsynchronousDelegate> *)theDelegate
      withExpiration:(NSInteger)theExpiration;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
