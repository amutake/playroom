import scala.pickling._
import json._

object Test extends App {

  case class Person(age: Int, name: String)

  val me = Person(age = 22, name = "amutake")
  val pickled = me.pickle
  println(pickled)
  println(pickled.unpickle[Person])
}
