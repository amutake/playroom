package example

import scalaz.ValidationNel
import org.json4s.scalaz.JsonScalaz

object Validation {

  sealed trait ValidationError
  case class JsonError(msg: String) extends ValidationError
  case class ValueError(msg: String) extends ValidationError
  case class NoSuchFieldError(msg: String) extends ValidationError

  type Valid[T] = ValidationNel[ValidationError, T]

  def jsonError(err: JsonScalaz.Error): ValidationError = err match {
    case JsonScalaz.UnexpectedJSONError(was, expected) =>
      JsonError("expected: " + expected + ", but got: " + was)
    case JsonScalaz.NoSuchFieldError(name, json) =>
      JsonError("field '" + name + "' is missing")
    case JsonScalaz.UncategorizedError(key, desc, args) =>
      JsonError("key: " + key + ", desc: " + desc + ", args: " + args)
  }
  // only when you use json4s-scalaz
  implicit def ResultToValid[T](r: JsonScalaz.Result[T]) = r.leftMap(_.map(jsonError))

  implicit class ValidWrapper[E, T](val v: ValidationNel[E, T]) {
    def /\[U](f: Function[T, ValidationNel[E, U]]) = v.flatMap(f)
    def >>=[U](f: Function[T, ValidationNel[E, U]]) = v.flatMap(f)
    def <^>[U](f: Function[T, U]) = v.map(f)
  }
  implicit def ExtractValid[E, T](v: ValidWrapper[E, T]) = v.v

  implicit class ValidFunctionWrapper[E, A, B](val f: A => ValidationNel[E, B]) {
    def >=>[C](g: B => ValidationNel[E, C]): A => ValidationNel[E, C] = { a =>
      f(a).flatMap(g)
    }
  }

  implicit class Pipe[A](x: A) {
    def |> [B](f: A => B) = f(x)
  }

}
