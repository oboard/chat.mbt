///|
fn main {
  // 打开数据库连接
  let engine = SQLiteEngine::open("chat.db")
  defer engine.close()
  // 自动迁移数据库
  @morm.auto_migrate(engine, [Message::table()])
  let message_mapper = Message::mapper(engine)

  // 创建应用
  let app = @mocket.new()
  let index_html = @fs.read_file_to_string("index.html") catch {
    _ => "Error loading index.html"
  }
  app.get("/", _ => HTML(index_html))
  // 获取所有消息
  app.get("/messages", _ => {
    let messages = message_mapper.find_all()
    Json(messages.to_json())
  })
  // 发送消息
  app.post("/send", e => if e.req.body is Json(json) {
    let message = try! @json.from_json(json)
    let message = message_mapper.save(message)
    Json(message.to_json())
  } else {
    e.res.status_code = 400
    Text("Invalid JSON body")
  })
  for route in app.mappings.keys() {
    println(route)
  }
  app.serve(port=3000)
}
