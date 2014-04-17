package example

import scalaz._
import Scalaz._

import org.json4s._
import org.json4s.jackson._
import org.json4s.jackson.JsonMethods._

import org.json4s.scalaz.JsonScalaz._
import org.json4s.scalaz._

import example.Validation.{Valid, jsonError}

object FromJson {

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

  def validateUser(str: String): Valid[User] = {
    fromJSON[User](parse(str))
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
  }
}
