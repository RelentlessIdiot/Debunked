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

#import "CGSize+Ext.h"


CGSize CGSizeScaledToFillAtLeast(CGSize size, CGSize bounds)
{
    if (size.width >= bounds.width && size.height >= bounds.height) { return size; }
    return CGSizeScaledToFillExactly(size, bounds);
}

CGSize CGSizeScaledToFillExactly(CGSize size, CGSize bounds)
{
    if (size.width <= 0.0f) { return CGSizeMake(bounds.width, MAX(size.height, bounds.height)); }
    if (size.height <= 0.0f) { return CGSizeMake(MAX(size.width, bounds.width), bounds.height); }
    CGFloat ratio = MAX(bounds.width / size.width, bounds.height / size.height);
    return CGSizeMake(ratio * size.width, ratio * size.height);
}

CGSize CGSizeScaledToFitAtMost(CGSize size, CGSize bounds)
{
    if (size.width <= bounds.width && size.height <= bounds.height) { return size; }
    return CGSizeScaledToFitExactly(size, bounds);
}

CGSize CGSizeScaledToFitExactly(CGSize size, CGSize bounds)
{
    if (size.width <= 0.0f) { return CGSizeMake(size.width, MIN(size.height, bounds.height)); }
    if (size.height <= 0.0f) { return CGSizeMake(MIN(size.width, bounds.width), size.height); }
    CGFloat ratio = MIN(bounds.width / size.width, bounds.height / size.height);
    return CGSizeMake(ratio * size.width, ratio * size.height);
}
