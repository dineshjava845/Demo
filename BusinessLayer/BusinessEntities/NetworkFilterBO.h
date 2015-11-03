//
//  NetworkFilterBO.h
//  Buzztang
//

//

#import <Foundation/Foundation.h>

@interface NetworkFilterBO : NSObject
@property (nonatomic,strong) NSString *identifier;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *filterNames;
@property (nonatomic,strong) NSArray *words;
@end
