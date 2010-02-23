#import "ClassDeconstruction.h"
#import </usr/include/objc/objc-class.h>
#import </usr/include/objc/Protocol.h>

#import <objc/objc.h>
#import <objc/objc-runtime.h>

static NSString* TFMethodNameKey=@"method_name";
static NSString* TFMethodTypesKey=@"method_types";
static NSString* TFIvarNameKey=@"ivar_name";
static NSString* TFIvarTypeKey=@"ivar_type";
static NSString* TFIvarOffsetKey=@"ivar_offset";
static NSString* TFIvarObjectKey=@"ivar_object";

@class _NSZombie, NSFault, NSRTFD;

@implementation NSObject (ClassDeconstruction)


// ===========================================================
// - deconstruct:
// ===========================================================
- (void)deconstruct;
{
    [self deconstruct: [self class]];
}


// ===========================================================
// - deconstruct:
// ===========================================================
- (void)deconstruct: (Class)aClass;
{
    struct objc_class *class = aClass;
    const char *name = class->name;
    int k;
    void *iterator = 0;
    struct objc_method_list *mlist;
	
    NSLog(@"Deconstructing class %s, version %d",
          name, class->version);
    NSLog(@"%s size: %d", name,
          class->instance_size);
    if (class->ivars == nil)
        NSLog(@"%s has no instance variables", name);
    else
    {
        NSLog(@"%s has %d ivar%c", name,
              class->ivars->ivar_count,
              ((class->ivars->ivar_count == 1)?' ':'s'));
        for (k = 0;
             k < class->ivars->ivar_count;
             k++)
            NSLog(@"%s ivar #%d: %s", name, k,
                  class->ivars->ivar_list[k].ivar_name);
    }
    mlist = class_nextMethodList(aClass, &iterator);
    if (mlist == nil)
        NSLog(@"%s has no methods", name);
    else do
    {
        for (k = 0; k < mlist->method_count; k++)
        {
            NSLog(@"%s implements %@", name,
                  NSStringFromSelector(mlist->method_list[k].method_name));
        }
    }
        while ( mlist = class_nextMethodList(aClass, &iterator) );
	
    if (class->super_class == nil)
        NSLog(@"%s has no superclass", name);
    else
    {
        NSLog(@"%s superclass: %s", name, class->super_class->name);
        [self deconstruct: class->super_class];
    }
}





//returns an NSArray of NSDictionary
//each item in the array = 1 ivar
//dictionary = description of the ivar
- (NSArray *)ivarsOfSelf
{       
	NSMutableArray *ivars;
	NSDictionary *info;
	NSString *name,*type;
	int i,n;
	struct objc_class *class;
	struct objc_ivar_list* ivar_list_struct;
	struct objc_ivar *ivar_list;
	struct objc_ivar ivar;
	id ivarObject;
	
	//if (anObject==nil)
	//	return [NSArray array];
	
	//get the objc_ivar_list
	//if (flag)
// class=self;
//	else
	class=[self class];
	ivar_list_struct=(*class).ivars;
	if (ivar_list_struct==NULL)
		return [NSArray array];
	n=ivar_list_struct->ivar_count;
	ivar_list=ivar_list_struct->ivar_list;
	ivars=[NSMutableArray arrayWithCapacity:n];
	
	
	//get the ivars info
	for (i=0;i<n;i++) 
	{
		ivar=ivar_list[i];
		name=[NSString stringWithCString:ivar.ivar_name];
		type=[NSString stringWithCString:ivar.ivar_type];
	//	if(!flag && [[type substringToIndex:1] isEqualToString:@"@"])
		if( [[type substringToIndex:1] isEqualToString:@"@"])
			object_getInstanceVariable(self,ivar.ivar_name,(void **)&ivarObject);
//		else
//			ivarObject=[NSNull null];
		info=[NSDictionary dictionaryWithObjectsAndKeys: name,TFIvarNameKey, type,TFIvarTypeKey, [NSNumber numberWithInt:ivar.ivar_offset], TFIvarOffsetKey, ivarObject, TFIvarObjectKey, nil];
		[ivars addObject:info];
	}
	
	
	return [[ivars copy] autorelease];
}


//returns an NSArray of NSDictionary
//each item in the array = 1 method
//dictionary = description of the method
- (NSArray *)methodsOfSelf
{       
	NSMutableArray *methods;
	NSDictionary *info;
	int i,n;
	struct objc_class *class;
	struct objc_method *method;
	void *iterator = 0;
	struct objc_method_list *methodList;
	
	
//	if (anObject==nil)
//		return [NSArray array];
// if (flag)
//		class=self;
//	else
		class=[self class];
	
	
	//count methods
	n=0;
	while( methodList = class_nextMethodList(class, &iterator ) )
		n+=(*methodList).method_count;
	methods=[NSMutableArray arrayWithCapacity:n];
	
	
	//retrieve method info
	while( methodList = class_nextMethodList([self class], &iterator ) ) {
		n=(*methodList).method_count;
		for (i=0;i<n;i++) {
			method=(*methodList).method_list + i;
			info=[NSDictionary dictionaryWithObjectsAndKeys: NSStringFromSelector(method->method_name),TFMethodNameKey, [NSString stringWithCString:method->method_types],TFMethodTypesKey, nil];
			[methods addObject:info];
		}
	}
	return [[methods copy] autorelease];
}


// ===========================================================
// - describeIvars:
// ===========================================================
- (NSString *) describeIvars
{
	//ivars
	NSMutableString *description=[NSMutableString string];
	NSArray *ivars;
	NSEnumerator *e;
	NSDictionary *dico;
	id class, sup;
	
	class = [self class];
	ivars = [NSObject ivarsOfObject:self classObject:NO];

	// at the moment can only cope with a chain of 5 objects
	sup=[class superclass];
	ivars  = [ivars arrayByAddingObjectsFromArray: [NSObject ivarsOfObject:sup classObject:YES] ];
	sup=[sup superclass];
	ivars  = [ivars arrayByAddingObjectsFromArray: [NSObject ivarsOfObject:sup classObject:YES] ];
	sup=[sup superclass];
	ivars  = [ivars arrayByAddingObjectsFromArray: [NSObject ivarsOfObject:sup classObject:YES] ];
	sup=[sup superclass];
	ivars  = [ivars arrayByAddingObjectsFromArray: [NSObject ivarsOfObject:sup classObject:YES] ];
	sup=[sup superclass];
	ivars  = [ivars arrayByAddingObjectsFromArray: [NSObject ivarsOfObject:sup classObject:YES] ];
	
	[description appendString:@"\n"];
	[description appendString:[NSString stringWithFormat:@"\n%@object <%@:%p>\n", (@"class :"), class, self]];
	[description appendString:@"ivars:\n"];
	e = [ivars objectEnumerator];
	
	// loop through all found ivars
	while (dico=[e nextObject]) 
	{
		// [description appendFormat:@"   %@   = %@ at offset %@", [dico objectForKey:TFIvarNameKey], [dico objectForKey:TFIvarTypeKey], [dico objectForKey:TFIvarOffsetKey]];
		[description appendFormat:@"    %@ class:%@ ", [dico objectForKey:TFIvarNameKey], [dico objectForKey:TFIvarTypeKey] ];
		
		id ivarObject=[dico objectForKey:TFIvarObjectKey];
		
		if (ivarObject!=[NSNull null])
			 [description appendFormat:@"description: %@\n",[ivarObject description]];
		 else 
			 [description appendString:@"\n"];
	}
	[description appendString:@"\n"];
	
	
	return [NSString stringWithString:description];
}


// ===========================================================
// - describeSelf:
// ===========================================================
- (NSString *)describeSelf
{
	NSEnumerator *e;
	NSDictionary *dico;
	id class,sup;
	NSArray *classMethods,*methods,*ivars;
	NSMutableString *description=[NSMutableString string];
	
	
	//initializations
//	if (NSStringFromClass([self class]==@"Class"))
//		class = self;
//	else
	class = [self class];
//	id metaclass	= objc_getMetaClass([NSStringFromClass(class) UTF8String]);
	classMethods	= [[self class] methodsOfObject: [self class] classObject:YES];
	methods			= [self methodsOfSelf];
	ivars			= [self ivarsOfSelf];
	
	
	//class and superclasses
	[description appendString:[NSString stringWithFormat:@"\n%@object <%@:%p>\n", (@"class :"), class, self]];
	[description appendString:@"!! ivars:\n"];
	[description appendString:@"\n"];
	[description appendString:[NSString stringWithFormat:@"description:\n%@\n", self]];
	[description appendString:@"\n"];
	[description appendString:[NSString stringWithFormat:@"class: %@\n",class]];
	sup=[class superclass];
	[description appendString:[NSString stringWithFormat:@"super1: %@\n",sup]];
	sup=[sup superclass];
	[description appendString:[NSString stringWithFormat:@"super2: %@\n",sup]];
	sup=[sup superclass];
	[description appendString:[NSString stringWithFormat:@"super3: %@\n",sup]];
	sup=[sup superclass];
	[description appendString:[NSString stringWithFormat:@"super4: %@\n",sup]];
	sup=[sup superclass];
	[description appendString:[NSString stringWithFormat:@"super5: %@\n",sup]];
	
	
	//methods
	[description appendString:@"\n"];
	[description appendString:@"class methods:\n"];
	e=[classMethods objectEnumerator];
	while (dico=[e nextObject])
		[description appendFormat:@"   %@ (%@)\n", [dico objectForKey:TFMethodNameKey],[dico objectForKey:TFMethodTypesKey]];
	[description appendString:@"\n"];
	[description appendString:@"instance methods:\n"];
	e=[methods objectEnumerator];
	while (dico=[e nextObject])
		[description appendFormat:@"   %@ (%@)\n", [dico objectForKey:TFMethodNameKey],[dico objectForKey:TFMethodTypesKey]];
	
	
	//ivars
	[description appendString:@"\n"];
	[description appendString:@"ivars:\n"];
	e=[ivars objectEnumerator];
	while (dico=[e nextObject]) {
		[description appendFormat:@"   %@   = %@ at offset %@\n",
			[dico objectForKey:TFIvarNameKey],
			[dico objectForKey:TFIvarTypeKey],
			[dico objectForKey:TFIvarOffsetKey]];
		/*
		 id ivarObject=[dico objectForKey:TFIvarObjectKey?];
		 if (ivarObject!=[NSNull null])
		 [description appendFormat:@"      object=<%@:%p>\n",[ivarObject class],ivarObject];
		 */
	}
	
	
	[description appendString:@"\n\n"];
	return [NSString stringWithString:description];
}




//returns an NSArray of NSDictionary
//each item in the array = 1 ivar
//dictionary = description of the ivar
+ (NSArray *)ivarsOfObject:(id)anObject classObject:(BOOL)flag
{       
	NSMutableArray *ivars;
	NSDictionary *info;
	NSString *name,*type;
	int i,n;
	struct objc_class *class;
	struct objc_ivar_list* ivar_list_struct;
	struct objc_ivar *ivar_list;
	struct objc_ivar ivar;
	id ivarObject;
	
	
	if (anObject==nil)
		return [NSArray array];
	
	
	//get the objc_ivar_list
	if (flag)
		class=anObject;
	else
		class=[anObject class];
	ivar_list_struct=(*class).ivars;
	if (ivar_list_struct==NULL)
		return [NSArray array];
	n=ivar_list_struct->ivar_count;
	ivar_list=ivar_list_struct->ivar_list;
	ivars=[NSMutableArray arrayWithCapacity:n];
	
	
	//get the ivars info
	for (i=0;i<n;i++) {
		ivar=ivar_list[i];
		name=[NSString stringWithCString:ivar.ivar_name];
		type=[NSString stringWithCString:ivar.ivar_type];
		
		
		if(!flag && [[type substringToIndex:1] isEqualToString:@"@"])
			object_getInstanceVariable(anObject,ivar.ivar_name,(void **)&ivarObject);
		else
			ivarObject=[NSNull null];
		info=[NSDictionary dictionaryWithObjectsAndKeys:name,TFIvarNameKey,type,TFIvarTypeKey,[NSNumber numberWithInt:ivar.ivar_offset],TFIvarOffsetKey,ivarObject,TFIvarObjectKey,nil];
		[ivars addObject:info];
	}
	
	
	return [[ivars copy] autorelease];
}


//returns an NSArray of NSDictionary
//each item in the array = 1 method
//dictionary = description of the method
+ (NSArray *)methodsOfObject:(id)anObject classObject:(BOOL)flag
{       
	NSMutableArray *methods;
	NSDictionary *info;
	int i,n;
	struct objc_class *class;
	struct objc_method *method;
	void *iterator = 0;
	struct objc_method_list *methodList;
	
	
	if (anObject==nil)
		return [NSArray array];
	if (flag)
		class=anObject;
	else
		class=[anObject class];
	
	
	//count methods
	n=0;
	while( methodList = class_nextMethodList(class, &iterator ) )
		n+=(*methodList).method_count;
	methods=[NSMutableArray arrayWithCapacity:n];
	
	
	//retrieve method info
	while( methodList = class_nextMethodList([anObject class], &iterator ) ) {
		n=(*methodList).method_count;
		for (i=0;i<n;i++) {
			method=(*methodList).method_list + i;
			info=[NSDictionary dictionaryWithObjectsAndKeys:NSStringFromSelector(method->method_name),TFMethodNameKey,[NSString stringWithCString:method->method_types],TFMethodTypesKey,nil];
			[methods addObject:info];
		}
	}
	return [[methods copy] autorelease];
}


+ (NSString *)describeObject:(id)anObject classObject:(BOOL)flag
{
	NSEnumerator *e;
	NSDictionary *dico;
	id class,sup;
	NSArray *classMethods,*methods,*ivars;
	NSMutableString *description=[NSMutableString string];
	
	
	//initializations
	if (flag)
		class=anObject;
	else
		class=[anObject class];
	id metaclass=objc_getMetaClass([NSStringFromClass(class) UTF8String]);
	classMethods=[self methodsOfObject:metaclass classObject:YES];
	methods=[self methodsOfObject:anObject classObject:flag];
	ivars=[self ivarsOfObject:anObject classObject:flag];
	
	
	//class and superclasses
	[description appendString:[NSString stringWithFormat:@"\n%@object <%@:%p>\n",
		(flag?@"class ":@""),class,anObject]];
	[description appendString:@"\n"];
	[description appendString:[NSString stringWithFormat:@"description:\n%@\n",anObject]];
	[description appendString:@"\n"];
	[description appendString:[NSString stringWithFormat:@"class: %@\n",class]];
	sup=[class superclass];
	[description appendString:[NSString stringWithFormat:@"super1: %@\n",sup]];
	sup=[sup superclass];
	[description appendString:[NSString stringWithFormat:@"super2: %@\n",sup]];
	sup=[sup superclass];
	[description appendString:[NSString stringWithFormat:@"super3: %@\n",sup]];
	sup=[sup superclass];
	[description appendString:[NSString stringWithFormat:@"super4: %@\n",sup]];
	sup=[sup superclass];
	[description appendString:[NSString stringWithFormat:@"super5: %@\n",sup]];
	
	
	//methods
	[description appendString:@"\n"];
	[description appendString:@"class methods:\n"];
	e=[classMethods objectEnumerator];
	while (dico=[e nextObject])
		[description appendFormat:@"   %@ (%@)\n",[dico objectForKey:TFMethodNameKey],[dico objectForKey:TFMethodTypesKey]];
	[description appendString:@"\n"];
	[description appendString:@"instance methods:\n"];
	e=[methods objectEnumerator];
	while (dico=[e nextObject])
		[description appendFormat:@"   %@ (%@)\n",[dico objectForKey:TFMethodNameKey],[dico objectForKey:TFMethodTypesKey]];
	
	
	//ivars
	[description appendString:@"\n"];
	[description appendString:@"ivars:\n"];
	e=[ivars objectEnumerator];
	while (dico=[e nextObject])
	{
		[description appendFormat:@"   %@   = %@ at offset %@\n",[dico objectForKey:TFIvarNameKey],[dico objectForKey:TFIvarTypeKey],[dico objectForKey:TFIvarOffsetKey]];
		/*
		 id ivarObject=[dico objectForKey:TFIvarObjectKey?];
		 if (ivarObject!=[NSNull null])
		 [description appendFormat:@"      object=<%@:%p>\n",[ivarObject class],ivarObject];
		 */
	}
	
	
	[description appendString:@"\n\n"];
	return [NSString stringWithString:description];
}


@end
