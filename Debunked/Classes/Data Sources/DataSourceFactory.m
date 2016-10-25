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

#import "DataSourceFactory.h"
#import "CategoryDataSource.h"
#import "RumorDataSource.h"
#import "SearchDataSource.h"


@implementation DataSourceFactory

static Class categoryDataSourceClassInstance;
static Class rumorDataSourceClassInstance;
static Class searchDataSourceClassInstance;

+ (Class)categoryDataSourceClass
{
	if (categoryDataSourceClassInstance == NULL) {
		categoryDataSourceClassInstance = [CategoryDataSource class];
	}
	return categoryDataSourceClassInstance;
}

+ (void)setCategoryDataSourceClass:(Class)theClass
{
	categoryDataSourceClassInstance = theClass;
}

+ (Class)rumorDataSourceClass
{
	if (rumorDataSourceClassInstance == NULL) {
		rumorDataSourceClassInstance = [RumorDataSource class];
	}
	return rumorDataSourceClassInstance;
}

+ (void)setRumorDataSourceClass:(Class)theClass
{
	rumorDataSourceClassInstance = theClass;
}

+ (Class)searchDataSourceClass
{
	if (searchDataSourceClassInstance == NULL) {
		searchDataSourceClassInstance = [SearchDataSource class];
	}
	return searchDataSourceClassInstance;
}

+ (void)setSearchDataSourceClass:(Class)theClass
{
	searchDataSourceClassInstance = theClass;
}

@end
