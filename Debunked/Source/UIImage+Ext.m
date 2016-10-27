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

#import "UIImage+Ext.h"


@implementation UIImage (Extension)

- (BOOL)isLandscape
{
    return (self.imageOrientation == UIImageOrientationLeft ||
            self.imageOrientation == UIImageOrientationRight ||
            self.imageOrientation == UIImageOrientationLeftMirrored ||
            self.imageOrientation == UIImageOrientationRightMirrored);
}

- (BOOL)isPortrait
{
    return ![self isLandscape];
}

- (UIImage *)crop:(CGRect)rect
{
    if (self.scale != 1.0f) {
        rect = CGRectMake(rect.origin.x * self.scale,
                          rect.origin.y * self.scale,
                          rect.size.width * self.scale,
                          rect.size.height * self.scale);
    }

    if (self.isLandscape) {
        CGFloat t = rect.origin.x;
        rect.origin.x = rect.origin.y;
        rect.origin.y = t;
        t = rect.size.width;
        rect.size.width = rect.size.height;
        rect.size.height = t;
    }

    CGImageRef cgImage = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *image = [UIImage imageWithCGImage:cgImage scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(cgImage);

    return image;
}

@end
