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

#import "SearchResultView.h"

#define MARGIN_Y 6
#define MARGIN_X 6
#define HEADLINE_Y 23

#define TITLE_FONT_SIZE 14
#define TITLE_MIN_FONT_SIZE 14
#define HEADLINE_FONT_SIZE 12
#define HEADLINE_MIN_FONT_SIZE 12
#define SYNOPSIS_FONT_SIZE 10
#define SYNOPSIS_MIN_FONT_SIZE 10

#define PREFERRED_HEIGHT 122

#define ACCESSORY_WIDTH 14


@implementation SearchResultView

@synthesize selected;

- (SearchResult *)searchResult
{
	return searchResult;
}

- (void)setSearchResult:(SearchResult *)theSearchResult
{
	if (searchResult != theSearchResult) {
		[searchResult release];
		searchResult = [theSearchResult retain];
	}
}

+ (NSInteger)preferredHeight
{
	return PREFERRED_HEIGHT;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithSearchResult:nil withFrame:frame];
}


- (id)initWithSearchResult:(SearchResult *)theSearchResult withFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.searchResult = theSearchResult;
		self.backgroundColor = [UIColor whiteColor];
		self.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
	if (searchResult == nil) {
		return;
	}
	
	UIColor *titleTextColor = [UIColor blackColor];
	UIFont *titleFont = [UIFont boldSystemFontOfSize:TITLE_FONT_SIZE];
	
	UIColor *rumorHeadlineTextColor = [UIColor colorWithRed:0 green:0 blue:0.5 alpha:1];
	UIFont *rumorHeadlineFont = [UIFont systemFontOfSize:HEADLINE_FONT_SIZE];
	
	UIColor *synopsisTextColor = [UIColor darkGrayColor];
	UIFont *synopsisFont = [UIFont italicSystemFontOfSize:SYNOPSIS_FONT_SIZE];
	
	if ([self isSelected]) {
		titleTextColor = [UIColor whiteColor];
		rumorHeadlineTextColor = [UIColor whiteColor];
		synopsisTextColor = [UIColor whiteColor];
	}
	
	CGRect contentRect = rect;
	contentRect.size.width -= ACCESSORY_WIDTH;
	contentRect.size.height = PREFERRED_HEIGHT;
	CGRect synopsisRect = contentRect;
	CGRect headlineRect = contentRect;
	CGPoint point;
	
	NSString *title = [NSString string];
	if (searchResult.title != nil && ![searchResult.title isEqual:@""]) {
		title = searchResult.title;
	} else if (searchResult.synopsis != nil && ![searchResult.synopsis isEqual:@""]) {
		title = searchResult.rumorHeadline;
		title = [title capitalizedString];
	}
	[titleTextColor set];
	point = CGPointMake(MARGIN_X, MARGIN_Y);
	[title drawAtPoint:point forWidth:synopsisRect.size.width withFont:titleFont minFontSize:TITLE_MIN_FONT_SIZE actualFontSize:NULL lineBreakMode:NSLineBreakByTruncatingTail baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
	
	int synopsisY = HEADLINE_Y;
	if (searchResult.rumorHeadline != nil && ![searchResult.rumorHeadline isEqual:@""]) {
		headlineRect.origin.x = MARGIN_X;
		headlineRect.origin.y = HEADLINE_Y;
		headlineRect.size.height = 44;
		synopsisY = HEADLINE_Y + 44;
		
		[rumorHeadlineTextColor set];
		[searchResult.rumorHeadline drawInRect:headlineRect withFont:rumorHeadlineFont];
	}
	
	if (searchResult.synopsis != nil && ![searchResult.synopsis isEqual:@""]) {
		synopsisRect.origin.x = MARGIN_X;
		synopsisRect.origin.y = synopsisY;
		synopsisRect.size.height = synopsisRect.size.height - synopsisY;
		
		[synopsisTextColor set];
		[searchResult.synopsis drawInRect:synopsisRect withFont:synopsisFont];
	}
}

- (void)dealloc
{
	[searchResult release];
	
    [super dealloc];
}


@end
