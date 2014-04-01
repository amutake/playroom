package me.amutake

import com.wix.accord._
import com.wix.accord.combinators._
import com.wix.accord.dsl._
import com.wix.accord.transform._

case class Person(first: String, last: String)
case class Data(id: Int, person: Person, description: Option[String])

object Data {

  val personValidator = new ValidationTransform.TransformedValidator({
    final class $anon extends Validator[Person] {
      def apply(person: Person) = {
        val sv = Contextualizer(person.first) is notEmpty
        sv(person.first).withDescription("person.first")
      }
    }
    new $anon
  }, {
    final class $anon extends Validator[Person] {
      def apply(person: Person) = {
        val sv = Contextualizer(person.last) is notEmpty
        sv(person.last).withDescription("person.last")
      }
    }
    new $anon
  })

  val dataValidator = new ValidationTransform.TransformedValidator({
    final class $anon extends Validator[Data] {
      def apply(data: Data) = {
        val sv = Contextualizer(data.id) must be >= 0
        sv(data.id).withDescription("data.id")
      }
    }
    new $anon
  }, {
    final class $anon extends Validator[Data] {
      def apply(data: Data) = {
        val sv = Contextualizer(data.person) is valid(personValidator)
        sv(data.person).withDescription("data.person")
      }
    }
    new $anon
  }, {
    final class $anon extends Validator[Data] {
      def ok[T]: Validator[T] = new NilValidator[T]
      def apply(data: Data) = {
        // val sv = Contextualizer(data.description) must be >= Some(0) // ERROR: No implicit Ordering defined for Some[Int].
        val sv = data.description.fold(ok[String]) { desc =>
          Contextualizer(desc) is notEmpty
        }
        sv(data.description).withDescription("data.description") // ERROR: found: Option[String], required: String.
      }
    }
    new $anon
  })
}
