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

#import "CategoryNodeView.h"
#import "CachedImageLoader.h"


#define TOP_ROW_Y 2
#define TOP_ROW_NO_SYNOPSIS_Y 16

#define LABEL_X 6

#define BOTTOM_ROW_Y 23

#define IMAGE_X 6
#define IMAGE_Y 10
#define IMAGE_WIDTH 32
#define IMAGE_HEIGHT 32

#define SYNOPSIS_X 47 // 6 + 32 + 12 // IMAGE_X + IMAGE_WIDTH + 9

#define LABEL_FONT_SIZE 18
#define LABEL_MIN_FONT_SIZE 18
#define SYNOPSIS_FONT_SIZE 12
#define SYNOPSIS_MIN_FONT_SIZE 12

#define PREFERRED_HEIGHT 57


@implementation CategoryNodeView

@synthesize nodeImage;
@synthesize selected;

- (CategoryNode *)categoryNode
{
	return categoryNode;
}

- (void)setCategoryNode:(CategoryNode *)theCategoryNode
{
	if (categoryNode != theCategoryNode) {
		[categoryNode release];
		categoryNode = [theCategoryNode retain];
		
		self.nodeImage = nil;
		
		if (categoryNode != nil && categoryNode.imageUrl != nil) {
			CachedImageLoader *imageLoader = [CachedImageLoader sharedImageLoader];
			[imageLoader addClientToDownloadQueue:self];
		}
	}
}

+ (NSInteger)preferredHeight
{
	return PREFERRED_HEIGHT;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithCategoryNode:nil withFrame:frame];
}


- (id)initWithCategoryNode:(CategoryNode *)theCategoryNode withFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.categoryNode = theCategoryNode;
		self.backgroundColor = [UIColor whiteColor];
		self.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
	if (categoryNode == nil) {
		return;
	}
	
	UIColor *labelTextColor = [UIColor blackColor];
	UIFont *labelFont = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
	
	UIColor *synopsisTextColor = [UIColor darkGrayColor];
	UIFont *synopsisFont = [UIFont systemFontOfSize:SYNOPSIS_FONT_SIZE];
	
	if ([self isSelected]) {
		labelTextColor = [UIColor whiteColor];
		synopsisTextColor = [UIColor whiteColor];
	}
	
	CGRect contentRect = rect;
	contentRect.size.width -= SYNOPSIS_X;
	CGRect synopsisRect = contentRect;
	CGPoint point;
	
	NSInteger leftMargin = SYNOPSIS_X;
	if (categoryNode.imageUrl == nil) {
		leftMargin = LABEL_X;
	}
	
	NSString *title = [NSString string];
	if (categoryNode.label != nil && ![categoryNode.label isEqual:@""]) {
		title = categoryNode.label;
	} else if (categoryNode.synopsis != nil && ![categoryNode.synopsis isEqual:@""]) {
		title = [categoryNode.synopsis capitalizedString];
	}
	[labelTextColor set];
	if (categoryNode.synopsis != nil && ![categoryNode.synopsis isEqual:@""]) {
		point = CGPointMake(leftMargin, TOP_ROW_Y);
	} else {
		point = CGPointMake(leftMargin, TOP_ROW_NO_SYNOPSIS_Y);
	}

    CGRect titleRect = CGRectMake(point.x, point.y, contentRect.size.width, contentRect.size.height - point.y);
    [title drawInRect:titleRect withAttributes:@{NSFontAttributeName: labelFont}];
	
	if (categoryNode.synopsis != nil && ![categoryNode.synopsis isEqual:@""]) {
		synopsisRect.origin.x = leftMargin;
		synopsisRect.origin.y = BOTTOM_ROW_Y;
		[synopsisTextColor set];
        [categoryNode.synopsis drawInRect:synopsisRect withAttributes:@{NSFontAttributeName:synopsisFont}];
	}
	
	point = CGPointMake(IMAGE_X, IMAGE_Y);
	if (self.nodeImage != nil) {
		[self.nodeImage drawAtPoint:point];
	} else if(categoryNode.imageUrl != nil) {
		// Draw a placeholder image
		UIImage* placeholderImage = [UIImage imageNamed:@"placeholder.png"];
		[placeholderImage drawAtPoint:point];
	}

}

- (NSWebViewURLRequest *)request
{
	if (categoryNode != nil && categoryNode.imageUrl != nil) {
		NSString *urlString = categoryNode.imageUrl;
		NSURL *url = [NSURL URLWithString:urlString];
		NSWebViewURLRequest *urlRequest = [NSWebViewURLRequest requestWithURL:url];
		return urlRequest;
	} else {
		return nil;
	}
}

- (void)renderImage:(UIImage *)image;
{
	self.nodeImage = image;
	[self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
}

- (void)dealloc {
	[categoryNode release];
	[nodeImage release];
	
    [super dealloc];
}


@end
