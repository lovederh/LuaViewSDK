//
//  LVSystem.m
//  LVSDK
//
//  Created by dongxicheng on 1/15/15.
//  Copyright (c) 2015 dongxicheng. All rights reserved.
//

#import "LVSystem.h"
#import "LView.h"

@implementation LVSystem


// // lv 扩展API
static int lv_vmVersion (lv_State *L) {
    lv_pushstring(L, "1.2.0") ;
    return 1; /* number of results */
}

// // lv 扩展API
static int osVersion (lv_State *L) {
    NSString* v = [[UIDevice currentDevice] systemVersion];
    lv_pushstring(L, v.UTF8String);
    return 1; /* number of results */
}

static int ios (lv_State *L) {
    lv_pushboolean(L, 1);
    return 1;
}

static int scale (lv_State *L) {
    CGFloat s = [UIScreen mainScreen].scale;
    lv_pushnumber( L, s);
    return 1; /* number of results */
}


// // lv 扩展API
static int platform (lv_State *L) {
    NSString* name = [[UIDevice currentDevice] systemName];
    NSString* version = [[UIDevice currentDevice] systemVersion];
    NSString* buf = [NSString stringWithFormat:@"%@;%@",name,version];
    lv_pushstring(L, [buf UTF8String] ) ;
    return 1; /* number of results */
}

static int device (lv_State *L) {
    NSString* name = [[UIDevice currentDevice] localizedModel];
    NSString* version = [[UIDevice currentDevice] model];
    NSString* buf = [NSString stringWithFormat:@"%@;%@",name,version];
    lv_pushstring(L, [buf UTF8String] ) ;
    return 1; /* number of results */
}

// // lv 扩展API
static int screenSize (lv_State *L) {
    CGSize s = [UIScreen mainScreen].bounds.size;
    lv_pushnumber(L, s.width );
    lv_pushnumber(L, s.height );
    return 2; /* number of results */
}

//
static int static_gc (lv_State *L) {
    lv_gc(L, 2, 0);
    return 0;
}

static int __index (lv_State *L) {
    if( lv_gettop(L)>=2 && lv_type(L, 2)==LV_TSTRING ){
        NSString* key = lv_paramString(L, 2);
        lvL_getmetatable(L, META_TABLE_System );
        lv_getfield(L, -1, key.UTF8String);
        if( lv_type(L, -1)==LV_TFUNCTION ) {
            lv_CFunction function =  lv_tocfunction(L,-1);
            if( function ) {
                lv_settop(L, 0);
                function(L);
                return lv_gettop(L);
            }
        }
    }
    return 0; /* new userdatum is already on the stack */
}

+(int) classDefine:(lv_State *)L {
    {
        const struct lvL_reg functions [] = {
            {"ios", ios},
            {"osVersion", osVersion},
            {"vmVersion", lv_vmVersion},
            {"version", lv_vmVersion},
            {"scale", scale},
            {"platform",platform},
            {"device",device},
            {NULL, NULL}
        };
        lv_createClassMetaTable(L, META_TABLE_System);
        lvL_openlib(L, NULL, functions, 0);
    }
    
    const char* TEMP_TABLE = "lv.System.__index";
    {
        lv_createClassMetaTable(L, TEMP_TABLE);
        const struct lvL_reg temp [] = {
            {"__index", __index},
            {NULL, NULL}
        };
        lvL_openlib(L, NULL, temp, 0);
    }
    {
        const struct lvL_reg staticFunctions [] = {
            {"screenSize", screenSize},
            {"gc",static_gc},
            {NULL, NULL}
        };
        lvL_openlib(L, "System", staticFunctions, 0);
    }
    lv_getglobal(L, "System");
    lvL_getmetatable(L, TEMP_TABLE );
    lv_setmetatable(L, -2);
    return 0;
}

@end