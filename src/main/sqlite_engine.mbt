///|
priv struct SQLiteEngine {
  conn : @sqlite3.Connection
}

///|
impl @engine.Engine for SQLiteEngine with dialect(_self) -> @dialect.Dialect {
  Sqlite3
}

///|
fn SQLiteEngine::open(filename : String) -> SQLiteEngine {
  { conn: try! @sqlite3.Connection::open(filename) }
}

///|
impl @engine.Engine for SQLiteEngine with close(self) -> Unit {
  try! self.conn.close()
}

///|
impl @engine.Engine for SQLiteEngine with exec(
  self,
  sql : String,
  params : FixedArray[Json],
) -> @engine.QueryResult {
  let mut error = None
  let rows = []
  println(sql + ";")
  println(params.to_json().stringify())
  try {
    let stmt = self.conn.prepare(sql + ";")
    params.eachi((index, val) => match val {
      Number(val, ..) => stmt.bind(index~, val~)
      String(val) => stmt.bind(index~, val~)
      True => stmt.bind(index~, val=1)
      False => stmt.bind(index~, val=0)
      Null => stmt.bind_null(index~)
      _ => abort("unexpected value")
    })
    // 构造第一行的 Json（按列名 -> 值）

    while stmt.step() == true {
      let obj : Map[String, Json] = {}
      let col_cnt = stmt.column_count()
      let mut index = 0
      while index < col_cnt {
        let name = stmt.column_name(index~)
        match stmt.column_type(index~) {
          // NULL
          5 => obj[name] = Json::null()
          // INTEGER
          1 => {
            let v : Int = stmt.column(index~)
            obj[name] = Json::number(v.to_double())
          }
          // FLOAT/DOUBLE
          2 => {
            let v = stmt.column(index~)
            obj[name] = Json::number(v)
          }
          // TEXT
          3 => {
            let s = stmt.column(index~)
            obj[name] = Json::string(s)
          }
          // BLOB（按字符串显示）
          4 => {
            let s = stmt.column_blob_as_string(index~)
            obj[name] = Json::string(s)
          }
          // 其他类型按字符串处理
          _ => {
            let s = stmt.column_blob_as_string(index~)
            obj[name] = Json::string(s)
          }
        }
        index = index + 1
      }
      rows.push(obj.to_json())
    }
    stmt.finalize()
  } catch {
    SqliteError(err) => {
      println(err)
      error = Some(err.to_string())
    }
  }
  { ok: true, rows_affected: 0, rows: FixedArray::from_array(rows), error }
}
