///|
#morm.mapper(Message)
pub trait MessageMapper {
  #morm.query("SELECT * FROM Message")
  find_all(Self) -> FixedArray[Message]
}
