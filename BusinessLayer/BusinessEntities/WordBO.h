//
//  WordBO.h
//  Buzztang
//
//

#import <Foundation/Foundation.h>

@interface WordBO : NSObject

@property (nonatomic, strong) NSString *textValue;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSArray *synonyms;

@end
