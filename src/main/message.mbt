///|
#morm.entity
pub(all) struct Message {
  #morm.id
  #morm.uuid
  id : String
  #morm.varchar(length="255")
  content : String
  #morm.datetime
  created_at : String
  // user_id : Int
  // conversation_id : Int
} derive(ToJson, FromJson)

///|
#morm.mapper(Message)
pub trait MessageMapper {
  async save(Self, Message) -> Message
  async find_all(Self) -> Array[Message]
}

///|
pub impl @mocket.BodyReader for Message with from_request(req) {
  @json.from_json(req.body())
}

// #morm.entity
// pub(all) struct Conversation {
//   #morm.primary_key
//   #morm.auto_increment
//   id : Int
// } derive(ToJson, FromJson)

// ///|
// #morm.entity
// pub(all) struct User {
//   #morm.primary_key
//   #morm.auto_increment
//   id : Int
//   #morm.varchar(length="255")
//   name : String
// } derive(ToJson, FromJson)
