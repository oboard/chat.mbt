 pub impl @oboard/morm.Entity for Message with table(_self) -> @oboard/morm.Table { Message::table() }
 pub fn Message::table() -> @oboard/morm.Table {
 @oboard/morm.Table::{
   name: "message",
   schema: None,
   catalog: None,
   columns: [
      {
        name: "id",
        column_type: VarChar(36),
        size: 0,
        nullable: false,
        auto_increment: false,
        primary_key: true,
        unique: false,
        comment: "",
        charset: None,
        collation: None,
        default_value: None,
        engine_options: [

        ],
      },
      {
        name: "content",
        column_type: VarChar(255),
        size: 0,
        nullable: false,
        auto_increment: false,
        primary_key: false,
        unique: false,
        comment: "",
        charset: None,
        collation: None,
        default_value: None,
        engine_options: [

        ],
      },
      {
        name: "created_at",
        column_type: DateTime,
        size: 0,
        nullable: false,
        auto_increment: false,
        primary_key: false,
        unique: false,
        comment: "",
        charset: None,
        collation: None,
        default_value: None,
        engine_options: [

        ],
      }
   ],
   indexes: [

   ],
   foreign_keys: [

   ],
   temporary: false,
   if_not_exists: true,
   engine: None,
   charset: None,
   collation: None,
   tablespace: None,
   comment: "",
   auto_increment: None,
   engine_options: [

   ],
 }
 }

 pub fn Message::_from(row : Map[String, @engine.Param]) -> Message {
    let id_param = match row.get("id") { Some(value) => value; None => panic() }
    let id : String = (try! @engine.from_param(id_param) : String)
    let content_param = match row.get("content") { Some(value) => value; None => panic() }
    let content : String = (try! @engine.from_param(content_param) : String)
    let created_at_param = match row.get("created_at") { Some(value) => value; None => panic() }
    let created_at : String = (try! @engine.from_param(created_at_param) : String)
     return Message::{
      id,
      content,
      created_at,
     }
 }
 pub impl @engine.FromParam for Message with from_param(value) {
   match value {
     @engine.Object(obj) => {
       let row : Map[String, @engine.Param] = Map::new()
       for key in obj.keys() {
         if obj.get(key) is Some(value) {
           row.set(key, value)
         }
       }
       Message::_from(row)
     }
     _ => raise @engine.ParamDecodeError("Message::from_param: expected Json object row")
   }
 }

 pub struct MessageMapperImpl {
   engine : &@engine.Engine
 }
 pub fn MessageMapperImpl::new(engine : &@engine.Engine) -> MessageMapperImpl {
   MessageMapperImpl::{ engine, }
 }
 pub impl MessageMapper for MessageMapperImpl with save(
   self, entity : Message
 ) -> Message {
   let q = @oboard/morm.upsert_into("message").from(entity)
   let res = self.engine.exec(q)
   if res.rows is [result, ..] {
     return Message::_from(result)
   }
   panic()
 }
 pub impl MessageMapper for MessageMapperImpl with find_all(
   self
 ) -> Array[Message] {   let out : Array[Message] = []
   for row in self.engine.exec(@morm.select_from("message")).rows {
     out.push(Message::_from(row))
   }
   out
 }
