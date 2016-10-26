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

#import "SearchDataSource.h"
#import "SearchConsumer.h"
#import "SearchResultTableViewCell.h"


@implementation SearchDataSource

- (NSArray *)searchResults
{
    return (NSArray *)self.item;
}

- (SearchResult *)searchResultForIndex:(NSUInteger)theIndex
{
	return [self.searchResults objectAtIndex:theIndex];
}

- (NSInteger)requestSearchResults:(NSString *)query notifyDelegate:(NSObject<AsynchronousDelegate> *)theDelegate
{
	NSString *baseQuery = @"http://search.atomz.com/search/?sp-a=00062d45-sp00000000&sp-c=100&sp-q=";
	NSString *queryString = [[query componentsSeparatedByString:@" "] componentsJoinedByString:@"+"];
	NSString *fullQuery = [baseQuery stringByAppendingString:queryString];
    return [self request:fullQuery consumerClass:SearchConsumer.class notifyDelegate:theDelegate];
}

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [SearchResultView preferredHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	SearchResultTableViewCell *cell = (SearchResultTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SearchResultTableViewCell"];
	if (cell == nil) {
		cell = [[[SearchResultTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SearchResultTableViewCell"] autorelease];
	}
	cell.searchResult = [self searchResultForIndex:indexPath.row];
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.searchResults.count;
}

@end
