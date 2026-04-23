///|
async fn main {
  // 打开数据库连接
  let engine = @sqlite3.SQLiteEngine::open("chat.db")
  defer engine.close()
  // 自动迁移数据库
  @morm.auto_migrate(engine, [Message::table()])
  let message_mapper = MessageMapperImpl::new(engine)

  // 创建应用
  let app = @mocket.new()
  let index_html = @fs.read_file("index.html").text() catch {
    _ => "Error loading index.html"
  }
  app.get("/", _ => @mocket.html(index_html))
  // 获取所有消息
  app.get("/messages", _ => {
    message_mapper.find_all().to_json() catch {
      _ => return @mocket.HttpResponse::new(InternalServerError)
    }
  })
  // 发送消息
  app.post("/send", e => {
    try {
      let message : Message = e.req.body()
      message_mapper.save(message).to_json()
    } catch {
      _ => return @mocket.HttpResponse::new(InternalServerError)
    }
  })
  println("http://localhost:3000")
  app.serve(port=3000)
}
