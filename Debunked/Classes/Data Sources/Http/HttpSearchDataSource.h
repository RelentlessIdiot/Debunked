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

#import <Foundation/Foundation.h>
#import "SearchResult.h"
#import "SearchDataSource.h"
#import "SearchConsumer.h"
#import "HttpAsynchronousDataSource.h"


@interface HttpSearchDataSource : HttpAsynchronousDataSource<SearchDataSource> {
	NSMutableArray *searchResults;
}

@property (nonatomic,retain) NSMutableArray *searchResults;

- (id)init;
- (id)initWithSearchResults:(NSMutableArray *)theSearchResults;

- (void)loadSearchResults:(NSMutableArray *)theSearchResults;

- (NSInteger)requestSearchResults:(NSString *)query notifyDelegate:(NSObject<SearchDelegate> *)theDelegate;

@end
