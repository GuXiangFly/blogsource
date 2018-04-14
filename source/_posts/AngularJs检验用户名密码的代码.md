---
title: AngularJs检验用户名密码的代码
date: 2017-3-11 23:09:04
tags: [Angular,前端]

---
# AngularJs检验用户名密码的代码

# 检测用户名的规则
``` javascript
        function checkUname(name){
            if(!name || /^\s*$/.test(name)){
                return {
                    msg:"用户名不能为空",
                    isTrue:false
                };
            }else if(/^\d+$/.test(name)){
                return {
                    msg:"用户名不能为纯数字",
                    isTrue:false
                };
            }else if(!/^[A-Za-z0-9_\u4E00-\u9FA5]+$/.test(name)){
                return {
                    msg:"用户名不符合规则",
                    isTrue:false
                };
            }else if(strLength(name)<6 || strLength(name)>14){
                return {
                    msg:"用户名长度应在6到14位之间",
                    isTrue:false
                };
            }else{
                return {
                    msg:"",
                    isTrue:true
                };
            }
        }
```

# 验证密码强度
```javascript
 //返回密码的强度级别  
        function checkStrong(sPW) {
            if (sPW.length < 8 || sPW.length > 16) {
                return 0;
            }    
            if(/^[0-9]+$/.test(sPW) || /^[a-zA-Z]+$/.test(sPW) ){
                return 1;
            }else{
                if(sPW.length <12){
                    return 2;
                }else{
                    return 3;
                }
            }
        }
```

# 验证密码规则

```JavaScript
function checkPwd(pwd){
            if(!pwd || /^\s*$/.test(pwd)){
                return {
                    msg:"密码不可为空",
                    isTrue:false,
                    strong:1
                };
            }else{
                if(!/^[a-zA-Z0-9]+$/.test(pwd)){
                    return {
                        msg:"密码格式错误,只能为数字,字母或数字母混合!",
                        isTrue:false,
                        strong:1
                    };
                }else{
                    var S_level = checkStrong(pwd);
                    switch (S_level) {
                        case 0:
                            return {
                                msg:"密码长度不符合要求，必须8-16位！",
                                isTrue:false,
                                strong:1
                            };
                            break;
                        case 1:
                            return {
                                msg:"",
                                isTrue:true,
                                strong:2
                            };
                            break;
                        case 2:
                            return {
                                msg:"",
                                isTrue:true,
                                strong:3
                            };
                            break;
                        default:
                            return {
                                msg:"",
                                isTrue:true,
                                strong:4
                            };
                    }
                }
            }
        }
```


# 验证密码一致性
```JavaScript
 function checkRePwd(pwd,re_pwd){
            if(pwd != re_pwd){
                return {
                    msg:"输入的密码不一致！",
                    isTrue:false
                };
            }else{
                return {
                    msg:"",
                    isTrue:true
                };
            }
        }
```