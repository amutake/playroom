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
  implicit def userJSONR: JSONR[User] =
    User.applyJSON(field[Int]("id"), field[String]("name"), field[List[Group]]("groups"))

  def validateUser(str: String): Valid[User] = {
    fromJSON[User](parse(str)).leftMap(_.map(jsonError))
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

    val invalidStr = """
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
    println(validateUser(invalidStr))
  }
}
