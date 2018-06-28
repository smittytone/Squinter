

//  Created by Tony Smith on 15/05/2015.
//  Copyright (c) 2017-18 Tony Smith. All rights reserved.


#import <Foundation/Foundation.h>

@interface TreeNode : NSObject

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSMutableArray *children;
@property (nonatomic, assign) BOOL flag;

@end
