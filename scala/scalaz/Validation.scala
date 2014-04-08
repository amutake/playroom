import scalaz.Validation
import scalaz.ValidationNel
import scalaz.std.option.none
import scalaz.syntax.std.option.{ToOptionIdOps, ToOptionOpsFromOption}
import scalaz.syntax.apply.ToApplyOpsUnapply
import scalaz.syntax.validation.ToValidationV

import scalaz._
import Scalaz._

object ValidationExample {

  implicit class Pipe[A](x: A) {
    def |> [B](f: Function[A, B]) = f.apply(x)
  }

  implicit class ValidationNelWrapper[E, A](val v: ValidationNel[E, A]) {
    // flatMap。演算子は適当
    def /\ [B](f: Function[A, ValidationNel[E, B]]) = v.flatMap(f)
    // fmap。<$> は定義できなかった
    def <^> [B](f: Function[A, B]) = v.map(f)
  }

  implicit def ExtractValidationNel[E, A](v: ValidationNelWrapper[E, A]) = v.v

  // ==== utility function ====

  // parseInt から名前を変えた
  def parsableInt(s: String): ValidationNel[String, Int] = {
    try {
      s.toInt.successNel
    } catch {
      case _: NumberFormatException => ("cannot parse \"" + s + "\" to Int").failureNel
    }
  }

  def natural(n: Int): ValidationNel[String, Int] = if (n >= 0) {
    n.successNel
  } else {
    (n.toString + " is not a natural number").failureNel
  }

  // ==== HogeInput ====

  case class HogeInput(id: Int)

  def validateHogeInput(idStr: String): ValidationNel[String, HogeInput] = {
    idStr.successNel /\ parsableInt /\ natural <^> HogeInput

    idStr.successNel
      .flatMap(parsableInt)
      .flatmap(natural)
      .map(HogeInput)

    // for {
    //   id <- parsableInt(idStr)
    //   id <- natural(id)
    // } yield HogeInput(id)
  }

  def validateHogeInputOption(idStr: Option[String]): ValidationNel[String, HogeInput] = {
    val id = idStr match {
      case None => "id not found".failureNel
      case Some(s) => s.successNel /\ parsableInt /\ natural
    }
    id <^> HogeInput
  }

  // ==== ListRange ====

  case class ListRange(offset: Option[Int], limit: Option[Int])

  def validateListRange(offsetStr: Option[String], limitStr: Option[String]): ValidationNel[String, ListRange] = {
    val offset: ValidationNel[String, Option[Int]] = offsetStr match {
      case None => None.successNel
      case Some(s) => s.successNel /\ parsableInt /\ natural <^> (_.some)
    }
    val limit = limitStr match {
      case None => None.successNel
      case Some(s) => s.successNel /\ parsableInt /\ natural <^> (_.some)
    }

    ListRange |> (offset |@| limit).apply // ApplicativeBuilder.apply を呼んでいるので
    // (offset |@| limit)(ListRange)
  }

  // ==== test ====

  def test = {
    println("======= validateHogeInput =======")
    println(validateHogeInput("10"))
    println(validateHogeInput("-1"))
    println(validateHogeInput("aa"))
    println(validateHogeInput(""))

    println("======= validateHogeInputOption =======")
    println(validateHogeInputOption(Some("10")))
    println(validateHogeInputOption(Some("")))
    println(validateHogeInputOption(None))

    println("======= validateListRange =======")
    println(validateListRange(Some("5"), Some("3")))
    println(validateListRange(Some("5"), None))
    println(validateListRange(Some("5"), Some("-3")))
    println(validateListRange(Some("aaa"), Some("-2")))
    println(validateListRange(Some(""), Some("")))
  }
}
