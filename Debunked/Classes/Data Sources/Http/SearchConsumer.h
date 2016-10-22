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
#import "Blacklist.h"
#import "SearchDataSource.h"
#import "RumorDataSource.h"
#import "Rumor.h"
#import "SearchResult.h"
#import "CachedDataLoader.h"
#import "DataConsumer.h"
#import "TFHpple.h"


@interface SearchConsumer : DataConsumer {
	NSObject<SearchDelegate> *delegate;
	NSObject<SearchDataSource> *dataSource;
}

@property (nonatomic,retain) NSObject<SearchDelegate> *delegate;
@property (nonatomic,retain) NSObject<SearchDataSource> *dataSource;

- (id)initWithDelegate:(NSObject<SearchDelegate> *)theDelegate 
		withDataSource:(NSObject<SearchDataSource> *)theDataSource
			   withUrl:(NSString *)theUrl;
- (void)receiveData:(NSData *)data withResponse:(NSURLResponse *)response;

@end