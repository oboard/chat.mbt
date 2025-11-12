# oboard/chat

一个使用 MoonBit + Mocket + SQLite + MORM 的极简聊天服务示例。核心由四个文件协同构成：

- `src/main/main.mbt`：应用入口、HTTP 路由与服务启动
- `src/main/mapper.mbt`：查询接口（由 MORM 生成具体实现）
- `src/main/entities.mbt`：实体模型与数据库映射
- `src/main/moon.pkg.json`：包配置与生成管线（pre-build）

## 架构总览

- 持久化：SQLite（数据库文件 `chat.db`）
- ORM：MORM（基于注解生成表结构、Mapper 实现）
- HTTP：Mocket（极简 HTTP server）
- 运行时流程：
  1. 打开数据库连接并自动迁移表结构
  2. 通过 MORM 生成的 Mapper 访问数据
  3. 暴露 REST 接口 `/messages` 与 `/send`

## 文件详解

### `src/main/main.mbt`

- 打开数据库连接并在函数退出时关闭：
  - `let engine = SQLiteEngine::open("chat.db")`
  - `defer engine.close()`
- 自动迁移：
  - `@morm.auto_migrate(engine, [Message::table()])`
  - 根据实体模型同步创建/变更 SQLite 表（仅用于示例，生产可控约束更严谨）。
- Mapper 获取：
  - `let message_mapper = Message::mapper(engine)`
  - 返回实现了 `MessageMapper` 的生成对象，封装对数据库的访问。
- HTTP 路由：
  - `GET /messages`：查询所有消息并返回 JSON 数组
    - `let messages = message_mapper.find_all()`
    - `Json(messages.to_json())`
  - `POST /send`：接收 JSON 请求体，保存消息并返回保存后的 JSON
    - `if e.req.body is Json(json)` → `@json.from_json(json)` 反序列化为 `Message`
    - `let message = message_mapper.save(message)`
    - `Json(message.to_json())`
  - 启动服务：`app.serve(port=3000)`

### `src/main/mapper.mbt`

- 使用 MORM 注解定义 Mapper 接口：
  - `#morm.mapper(Message)` 指定作用的实体类型
  - `pub trait MessageMapper`：公开查询接口集合
  - `#morm.query("SELECT * FROM Message")`：声明 SQL
  - `find_all(Self) -> FixedArray[Message]`：返回所有消息的强类型数组
- MORM 在预构建阶段会读取该 trait 并生成 `mapper.g.mbt`，提供具体实现与引擎集成（通过 `Message::mapper(engine)` 取得）。

### `src/main/entities.mbt`

- 使用 MORM 注解定义实体与字段映射：
  - `#morm.entity`：声明实体类型
  - `pub(all) struct Message`：对外公开结构体
  - 字段：
    - `id : String` + `#morm.primary_key` + `#morm.uuid`（字符串主键，自动生成 UUID）
    - `content : String` + `#morm.varchar(length="255")`
    - `created_at : String` + `#morm.datetime`
  - `derive(ToJson, FromJson)`：自动派生 JSON 序列化/反序列化
- 这些注解驱动 MORM 在迁移时创建对应的 SQLite 表结构，并在生成 Mapper 时做类型映射。

### `src/main/moon.pkg.json`

- 包配置：
  - `"is-main": true`：可运行主包
  - `"import"`：依赖的包，包括 `oboard/chat/sqlite3`（SQLite FFI 封装）、`oboard/morm`、`oboard/morm/engine`、`oboard/morm/dialect`、`oboard/mocket`。
- 预构建管线（`pre-build`）：
  - 对 `entities.mbt` 与 `mapper.mbt` 分别调用 `morm-gen` 生成 `entities.g.mbt` 和 `mapper.g.mbt`，并通过 `moonfmt` 格式化。
  - 生成的文件在源码同目录下，被主代码引入使用。

## 运行与接口

- 启动服务（示例）：
  - `moon run` 或在 IDE 中执行主函数
  - 服务监听端口 `3000`
- 路由与行为：
  - `GET /messages`
    - 返回所有消息的 JSON 数组，形如：
      ```json
      [
        { "id": "uuid-1", "content": "hello", "created_at": "2024-10-01T12:34:56Z" },
        { "id": "uuid-2", "content": "world", "created_at": "2024-10-01T12:35:00Z" }
      ]
      ```
  - `POST /send`
    - 请求体（`Content-Type: application/json`）：
      ```json
      { "id": "uuid-optional", "content": "你好", "created_at": "2024-10-01T12:34:56Z" }
      ```
    - 返回保存后的消息 JSON：
      ```json
      { "id": "uuid-generated", "content": "你好", "created_at": "2024-10-01T12:34:56Z" }
      ```

## 数据流与执行路径

- `main.mbt` 请求进入路由 → 调用 `MessageMapper` 方法 → 通过引擎执行 SQL → 将 SQLite 行映射为 `Message` → `ToJson` 输出响应。
- 自动迁移基于实体注解生成/更新表结构，保证 `mapper` 的查询在启动后即可执行。

## 扩展建议

- 增加会话实体（Conversation），为消息关联会话 ID，并扩展 Mapper 查询（分页、按会话过滤）。
- 为 `POST /send` 增加参数校验与错误处理（例如缺少字段、非法时间格式）。
- 根据需要，改造 `created_at` 字段为更严格的类型（如专用 DateTime 类型），并在保存时由服务端生成当前时间。

## 注意事项

- 预构建生成依赖 `morm-gen` 可执行工具；请确保 `moon.pkg.json` 的 `pre-build` 命令可在你的环境中正确执行。
- SQLite 文件 `chat.db` 位于项目根目录；首次运行会自动创建并迁移。