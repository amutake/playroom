package example

import scalaz.NonEmptyList

case class Group(id: Int, name: String)
case class User(id: Int, name: String, groups: NonEmptyList[Group])

case class ListRange(offset: Option[Int], limit: Option[Int])
case class Nat(n: Int)
