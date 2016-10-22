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

#import "SearchResult.h"
#import "SearchResultTableViewCell.h"


@implementation SearchResultTableViewCell

@synthesize searchResult;
@synthesize searchResultView;

- (void)setSearchResult:(SearchResult *)theSearchResult
{
	if (theSearchResult != searchResult) {
		[searchResult release];
		[theSearchResult retain];
		searchResult = theSearchResult;
	}
	searchResultView.searchResult = searchResult;
	[searchResultView performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
}

- (void)setSelected:(BOOL)selected
{
	[super setSelected:selected];
	[searchResultView setSelected:selected];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:NO];
	[searchResultView setSelected:selected];
}

- (void)setHighlighted:(BOOL)highlighted
{
	[super setHighlighted:highlighted];
	[searchResultView setSelected:highlighted];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
	[super setHighlighted:highlighted animated:NO];
	[searchResultView setSelected:highlighted];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        searchResult = nil;
		self.selectionStyle = UITableViewCellSelectionStyleBlue;
		self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		
		CGRect frame = CGRectMake(0.0, 0.0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
		searchResultView = [[SearchResultView alloc] initWithFrame:frame];
		[self.contentView addSubview:searchResultView];
	}
    return self;
}


- (void)redisplay
{
	[searchResultView performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
}


- (void)dealloc {
	[searchResult release];
	[searchResultView release];
	
    [super dealloc];
}


@end
