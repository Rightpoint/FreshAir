//
//  RZFDefines.h
//  FreshAir
//
//  Created by Brian King on 1/26/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#define RZF_KP(Classname, keypath) ({\
Classname *_rzf_keypath_obj; \
__unused __typeof(_rzf_keypath_obj.keypath) _rzf_keypath_prop; \
@#keypath; \
})
