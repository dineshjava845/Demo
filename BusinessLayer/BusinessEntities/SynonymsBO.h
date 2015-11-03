//
//  SynonymsBO.h
//  Buzztang
//

#import <Foundation/Foundation.h>

@interface SynonymsBO : NSObject

@property (nonatomic, strong) NSString *textValue;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *wordIdentifier;//taken for service#36 only

@end
