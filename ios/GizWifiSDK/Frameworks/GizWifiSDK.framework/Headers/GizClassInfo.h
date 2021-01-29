//
//  GizClassInfo.h
//  GizWifiSDK
//
//  Created by william Zhang on 2020/7/7.
//  Copyright © 2020 gizwits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Type encoding's type.
 */
typedef NS_OPTIONS(NSUInteger, GizEncodingType) {
    GizEncodingTypeMask       = 0xFF, ///< mask of type value
    GizEncodingTypeUnknown    = 0, ///< unknown
    GizEncodingTypeVoid       = 1, ///< void
    GizEncodingTypeBool       = 2, ///< bool
    GizEncodingTypeInt8       = 3, ///< char / BOOL
    GizEncodingTypeUInt8      = 4, ///< unsigned char
    GizEncodingTypeInt16      = 5, ///< short
    GizEncodingTypeUInt16     = 6, ///< unsigned short
    GizEncodingTypeInt32      = 7, ///< int
    GizEncodingTypeUInt32     = 8, ///< unsigned int
    GizEncodingTypeInt64      = 9, ///< long long
    GizEncodingTypeUInt64     = 10, ///< unsigned long long
    GizEncodingTypeFloat      = 11, ///< float
    GizEncodingTypeDouble     = 12, ///< double
    GizEncodingTypeLongDouble = 13, ///< long double
    GizEncodingTypeObject     = 14, ///< id
    GizEncodingTypeClass      = 15, ///< Class
    GizEncodingTypeSEL        = 16, ///< SEL
    GizEncodingTypeBlock      = 17, ///< block
    GizEncodingTypePointer    = 18, ///< void*
    GizEncodingTypeStruct     = 19, ///< struct
    GizEncodingTypeUnion      = 20, ///< union
    GizEncodingTypeCString    = 21, ///< char*
    GizEncodingTypeCArray     = 22, ///< char[10] (for example)
    
    GizEncodingTypeQualifierMask   = 0xFF00,   ///< mask of qualifier
    GizEncodingTypeQualifierConst  = 1 << 8,  ///< const
    GizEncodingTypeQualifierIn     = 1 << 9,  ///< in
    GizEncodingTypeQualifierInout  = 1 << 10, ///< inout
    GizEncodingTypeQualifierOut    = 1 << 11, ///< out
    GizEncodingTypeQualifierBycopy = 1 << 12, ///< bycopy
    GizEncodingTypeQualifierByref  = 1 << 13, ///< byref
    GizEncodingTypeQualifierOneway = 1 << 14, ///< oneway
    
    GizEncodingTypePropertyMask         = 0xFF0000, ///< mask of property
    GizEncodingTypePropertyReadonly     = 1 << 16, ///< readonly
    GizEncodingTypePropertyCopy         = 1 << 17, ///< copy
    GizEncodingTypePropertyRetain       = 1 << 18, ///< retain
    GizEncodingTypePropertyNonatomic    = 1 << 19, ///< nonatomic
    GizEncodingTypePropertyWeak         = 1 << 20, ///< weak
    GizEncodingTypePropertyCustomGetter = 1 << 21, ///< getter=
    GizEncodingTypePropertyCustomSetter = 1 << 22, ///< setter=
    GizEncodingTypePropertyDynamic      = 1 << 23, ///< @dynamic
};

/**
 Get the type from a Type-Encoding string.
 
 @discussion See also:
 https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
 https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
 
 @param typeEncoding  A Type-Encoding string.
 @return The encoding type.
 */
GizEncodingType GizEncodingGetType(const char *typeEncoding);


/**
 Instance variable information.
 */
@interface GizClassIvarInfo : NSObject
@property (nonatomic, assign, readonly) Ivar ivar;              ///< ivar opaque struct
@property (nonatomic, strong, readonly) NSString *name;         ///< Ivar's name
@property (nonatomic, assign, readonly) ptrdiff_t offset;       ///< Ivar's offset
@property (nonatomic, strong, readonly) NSString *typeEncoding; ///< Ivar's type encoding
@property (nonatomic, assign, readonly) GizEncodingType type;    ///< Ivar's type

/**
 Creates and returns an ivar info object.
 
 @param ivar ivar opaque struct
 @return A new object, or nil if an error occurs.
 */
- (instancetype)initWithIvar:(Ivar)ivar;
@end


/**
 Method information.
 */
@interface GizClassMethodInfo : NSObject
@property (nonatomic, assign, readonly) Method method;  ///< method opaque struct
@property (nonatomic, strong, readonly) NSString *name; ///< method name
@property (nonatomic, assign, readonly) SEL sel;        ///< method's selector
@property (nonatomic, assign, readonly) IMP imp;        ///< method's implementation
@property (nonatomic, strong, readonly) NSString *typeEncoding;   ///< method's parameter and return types
@property (nonatomic, strong, readonly) NSString *returnTypeEncoding;   ///< return value's type
@property (nullable, nonatomic, strong, readonly) NSArray<NSString *> *argumentTypeEncodings;  ///< array of arguments' type

/**
 Creates and returns a method info object.
 
 @param method method opaque struct
 @return A new object, or nil if an error occurs.
 */
- (instancetype)initWithMethod:(Method)method;
@end


/**
 Property information.
 */
@interface GizClassPropertyInfo : NSObject
@property (nonatomic, assign, readonly) objc_property_t property; ///< property's opaque struct
@property (nonatomic, strong, readonly) NSString *name;           ///< property's name
@property (nonatomic, assign, readonly) GizEncodingType type;      ///< property's type
@property (nonatomic, strong, readonly) NSString *typeEncoding;   ///< property's encoding value
@property (nonatomic, strong, readonly) NSString *ivarName;       ///< property's ivar name
@property (nullable, nonatomic, assign, readonly) Class cls;      ///< may be nil
@property (nullable, nonatomic, strong, readonly) NSArray<NSString *> *protocols; ///< may nil
@property (nonatomic, assign, readonly) SEL getter;               ///< getter (nonnull)
@property (nonatomic, assign, readonly) SEL setter;               ///< setter (nonnull)

/**
 Creates and returns a property info object.
 
 @param property property opaque struct
 @return A new object, or nil if an error occurs.
 */
- (instancetype)initWithProperty:(objc_property_t)property;
@end

@interface GizClassInfo : NSObject

@property (nonatomic, assign, readonly) Class cls; ///< class object
@property (nullable, nonatomic, assign, readonly) Class superCls; ///< super class object
@property (nullable, nonatomic, assign, readonly) Class metaCls;  ///< class's meta class object
@property (nonatomic, readonly) BOOL isMeta; ///< whether this class is meta class
@property (nonatomic, strong, readonly) NSString *name; ///< class name
@property (nullable, nonatomic, strong, readonly) GizClassInfo *superClassInfo; ///< super class's class info
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, GizClassIvarInfo *> *ivarInfos; ///< ivars
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, GizClassMethodInfo *> *methodInfos; ///< methods
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, GizClassPropertyInfo *> *propertyInfos; ///< properties

/**
 If the class is changed (for example: you add a method to this class with
 'class_addMethod()'), you should call this method to refresh the class info cache.
 
 After called this method, `needUpdate` will returns `YES`, and you should call
 'classInfoWithClass' or 'classInfoWithClassName' to get the updated class info.
 */
- (void)setNeedUpdate;

/**
 If this method returns `YES`, you should stop using this instance and call
 `classInfoWithClass` or `classInfoWithClassName` to get the updated class info.
 
 @return Whether this class info need update.
 */
- (BOOL)needUpdate;

/**
 Get the class info of a specified Class.
 
 @discussion This method will cache the class info and super-class info
 at the first access to the Class. This method is thread-safe.
 
 @param cls A class.
 @return A class info, or nil if an error occurs.
 */
+ (nullable instancetype)classInfoWithClass:(Class)cls;

/**
 Get the class info of a specified Class.
 
 @discussion This method will cache the class info and super-class info
 at the first access to the Class. This method is thread-safe.
 
 @param className A class name.
 @return A class info, or nil if an error occurs.
 */
+ (nullable instancetype)classInfoWithClassName:(NSString *)className;

@end

NS_ASSUME_NONNULL_END
