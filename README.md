平台文档管理系统后端接口文档

1. 用户相关接口

1.1 用户注册
接口地址：POST /api/users

请求体（JSON）：
{
  "email": "user@example.com",
  "password_hash": "<加密后的hash>",
  "role": "guest",             // 默认 guest，可选 guest/vvip/consultant 等
  "status": 1,                 // 默认1，激活
  "user_metadata": {           // 可选
    "real_name": "张三"
  }
}

响应体（JSON）：
{
  "id": "<用户UUID>",
  "email": "user@example.com",
  "role": "guest",
  "status": 1,
  "failed_login_attempts": 0,
  "locked_until": null,
  "last_login_at": null,
  "created_at": "2024-01-01T12:00:00Z",
  "updated_at": "2024-01-01T12:00:00Z",
  "deleted_at": null,
  "user_metadata": {}
}
数据库交互：写入 users 表（详见models.py）。

业务流程：注册前会检查邮箱是否已存在。存在则返回 400 错。

1.2 用户登录
接口地址：POST /api/users/login

请求体（JSON）：

{
  "email": "user@example.com",
  "password_hash": "<加密后的hash>"
}

响应体（JSON）：

{
  "access_token": "<用户UUID>",
  "token_type": "bearer"
}
数据库交互：查询 users，密码校验成功则更新时间、token。

前端交互：登录成功后，保存 access_token，后续可用于鉴权。

2. 文档相关接口
2.1 上传文档并保存版本
接口地址：POST /api/documents_save/{doc_type}

路径参数：

doc_type：文档类型，枚举值，仅允许如下三种之一

resume

personal_statement

recommendation

请求体（JSON）：

{
  "user_id": "<用户UUID>",
  "content_md": "# markdown 文档内容"
}

响应体（JSON）：

{
  "id": "<文档UUID>",
  "user_id": "<用户UUID>",
  "type": "resume",                       // 当前文档类型
  "current_version_id": "<版本UUID>",
  "content_md": "# markdown 文档内容",     // 当前内容
  "created_at": "2024-01-01T12:00:00Z",
  "updated_at": "2024-01-01T12:00:00Z"
}
数据库交互：

documents表：按用户和类型查找文档，不存在则新建。

document_versions表：新建一个新版本，并更新文档当前版本号。


2.2 获取某用户指定类型文档的当前内容
接口地址：POST /api/documents/{doc_type}

路径参数：

doc_type：文档类型，枚举值，仅允许如下三种之一

resume

personal_statement

recommendation

请求体（JSON）：

{
  "user_id": "<用户UUID>"
}

响应体（JSON）：

{
  "id": "<文档UUID>",
  "user_id": "<用户UUID>",
  "type": "resume",                      // 或 personal_statement, recommendation
  "current_version_id": "<版本UUID>",
  "content_md": "# 当前版本的 markdown 内容",
  "created_at": "2024-01-01T12:00:00Z",
  "updated_at": "2024-01-01T12:00:00Z"
}

数据库交互：

查询documents表找到user_id+doc_type的文档。

取出current_version_id，再去document_versions查出内容。

如果未找到，返回404maincrud。

3. 数据库结构简述（与接口相关）

3.1 users 表（用户信息）
字段：id, email, password_hash, role, status, failed_login_attempts, user_metadata, created_at, updated_at 等。

3.2 documents 表（文档基本信息）
字段：id, user_id, type(resume/personal_statement/recommendation), current_version_id, created_at, updated_at。

3.3 document_versions 表（文档版本信息）
字段：id, document_id, version_number, content, created_by, created_at。

4. 枚举类型说明

所有文档类型均仅允许三种，禁止其他类型，后端和数据库完全对应（详见models.py和schemas.py）：

resume

personal_statement

recommendation

5. 前端交互注意事项

注册和登录接口需处理好异常（如重复邮箱、账号/密码错误）。

上传和获取文档时，请严格传递用户UUID和类型doc_type。

文档内容使用 content_md 字段，支持 Markdown。

新建或覆盖文档时，后端自动创建版本，前端可据返回内容渲染最新文档。

6. 示例流程

上传简历（resume）示例：

前端请求：

POST /api/documents_save/resume
{
  "user_id": "c81d8d9a-xxxx-xxxx-xxxx-xxxxxxxxxx",
  "content_md": "# 个人简历内容"
}

返回：

{
  "id": "...",
  "user_id": "...",
  "type": "resume",
  "current_version_id": "...",
  "content_md": "# 个人简历内容",
  "created_at": "...",
  "updated_at": "..."
}