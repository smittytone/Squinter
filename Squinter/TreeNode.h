

//  Created by Tony Smith on 15/05/2015.
//  Copyright (c) 2020 Tony Smith. All rights reserved.


#import <Foundation/Foundation.h>
#import "Devicegroup.h"


@interface TreeNode : NSObject


// This class is just a list of properties, which we use to structure
// items in the Inspector Project and Device views' lists
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSMutableArray *children;
@property (nonatomic, strong) Devicegroup *dg;
@property (nonatomic, assign) BOOL flag;
@property (nonatomic, assign) BOOL expanded;


@end
