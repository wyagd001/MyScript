base_url: https://dagx.io/

[TOCM]

[TOC]

### 用户 /user
对象属性

|key    |   类型    |   说明   |
|---    |   ---    |   ---    |
|id     | int      |   |
|name   | string   | 用户名 |

#### 1注册

| POST |  **/user/register**  |
| --- | --- |
| 请求参数 | **name**  : 名称<br> **code** : 验证码|
| 说明 |注册接口|