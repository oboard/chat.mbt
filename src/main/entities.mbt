// ///|
// #morm.entity
// pub(all) struct User {
//   #morm.primary_key
//   #morm.auto_increment
//   id : Int
//   #morm.varchar(length="255")
//   name : String
// } derive(ToJson, FromJson)

///|
#morm.entity
pub(all) struct Message {
  #morm.primary_key
  #morm.uuid
  id : String
  #morm.varchar(length="255")
  content : String
  #morm.datetime
  created_at : String
  // user_id : Int
  // conversation_id : Int
} derive(ToJson, FromJson)

// #morm.entity
// pub(all) struct Conversation {
//   #morm.primary_key
//   #morm.auto_increment
//   id : Int
// } derive(ToJson, FromJson)
