package example

import scalaz._
import Scalaz._

import org.json4s._
import org.json4s.jackson._
import org.json4s.jackson.JsonMethods._

import org.json4s.scalaz.JsonScalaz._
import org.json4s.scalaz._

import example.Validation.{Valid, JsonError, jsonError, ResultToValid, ValidWrapper, ExtractValid, ValidFunctionWrapper}

object FromJson {

  // json4s-scalaz を使った場合

  implicit def groupJSONR: JSONR[Group] =
    Group.applyJSON(field[Int]("id"), field[String]("name"))
  implicit def nelJSONR[T: JSONR]: JSONR[NonEmptyList[T]] = new JSONR[NonEmptyList[T]] {
    def read(json: JValue) = json match {
      case JArray(x :: xs) => (fromJSON[T](x) |@| xs.traverse(fromJSON[T]))(NonEmptyList[T])
      case JArray(Nil) => UncategorizedError("NonEmptyList", "Array is empty", List()).failureNel
      case x => UnexpectedJSONError(x, classOf[JArray]).failureNel
    }
  }
  implicit def userJSONR: JSONR[User] =
    User.applyJSON(field[Int]("id"), field[String]("name"), field[NonEmptyList[Group]]("groups"))
  implicit def listRangeJSONR: JSONR[ListRange] =
    ListRange.applyJSON(field[Option[Int]]("offset"), field[Option[Int]]("limit"))

  def validateUser(str: String): Valid[User] = {
    fromJSON[User](parse(str))
  }

  /* なんだか微妙
   * 微妙な点
   * 1. JsonScalaz.Error のみを使うような設計になっていて拡張しづらい。
   * 2. JsonScalaz.Error を含み他のエラーもつけたようなラッパ(ここでの Valid のような)を作り、
   *    その型を返すようなバリデータを作っても、JSONR は Result しか使えなく、Valid は Result になれないので、JSON の方に流用できない。
   * 3. 簡単そうなので作りなおしてもいいけど、json4s-scalaz とほとんど同じになりそう。
   * 4. JSON のパースに失敗したら例外を吐き、
   */


  // 下は json4s-scalaz を使わないバージョン

  def validParse(str: String): Valid[JValue] = try {
    parse(str).successNel
  } catch {
    case e: Throwable => JsonError(e.toString).failureNel
  }

  def validField[T](name: String)(validate: JValue => Valid[T])(json: JValue): Valid[T] = json match {
    case JObject(fs) =>
      fs.find(_._1 == name)
        .map(f => validate(f._2))
        .orElse(validate(JNothing).fold(_ => none, x => some(x.successNel)))
        .getOrElse(jsonError(NoSuchFieldError(name, json)).failureNel)
    case x => jsonError(UnexpectedJSONError(x, classOf[JObject])).failureNel
  }

  def int: JValue => Valid[Int] = (json: JValue) => json match {
    case JInt(x) => x.intValue.successNel
    case x => JsonError("expected int but got " + x.toString).failureNel
  }

  def option[T]: (JValue => Valid[T]) => JValue => Valid[Option[T]] = validate => json => json match {
    case JNothing | JNull => None.successNel
    case x => validate(x).map(some)
  }

  def validateListRange(json: JValue): Valid[ListRange] = {
    val natOpt = option(int >=> Utils.natural)
    val offset = validField("offset")(natOpt)(json)
    val limit = validField("limit")(natOpt)(json)
    (offset |@| limit)(ListRange)
  }

  def test = {

    val validStr = """
{
  "id": 0,
  "name": "amutake",
  "groups": [{
    "id": 0,
    "name": "titech"
  }, {
    "id": 1,
    "name": "psg"
  }]
}
"""

    val invalidStr1 = """
{
  "id": 0,
  "name": "amutake",
  "groups": []
}
"""

    val invalidStr2 = """
{
  "id": 0,
  "name": null,
  "groups": [{
    "id": 0,
    "name": "titech"
  }, {
    "id": null,
    "name": "psg"
  }]
}
"""

    println("======= validateUser =======")
    println(validateUser(validStr))
    println(validateUser(invalidStr1))
    println(validateUser(invalidStr2))

    val validListRange = """
{
  "offset": 10,
  "limit": null
}
"""
    val invalidListRange = """
{
  "offset": "11"
}
"""
    println("========= validateListRange ==========")
    println(validParse(validListRange).flatMap(validateListRange))
    println(validParse(invalidListRange).flatMap(validateListRange))

    val cannotParse = """
{
  offset: 0,
  limit: 1
}
"""
    println("======= cannotParse =======")
    println(validParse(cannotParse).flatMap(validateListRange))
  }
}
