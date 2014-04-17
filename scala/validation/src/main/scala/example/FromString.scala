package example

import scalaz.ValidationNel
import scalaz.std.option.none
import scalaz.syntax.std.option.{ToOptionIdOps, ToOptionOpsFromOption}
import scalaz.syntax.apply.ToApplyOpsUnapply
import scalaz.syntax.validation.ToValidationV

import example.Validation._
import example.Utils._

object FromString {

  def validateNat(str: String): Valid[Nat] = {
    str.successNel /\ parsableInt /\ natural <^> Nat

    // str |> parsableInt _ /\ natural <^> Nat

    // or

    // str.successNel
    //   .flatMap(parsableInt)
    //   .flatMap(natural)
    //   .map(Nat)

    // or

    // for {
    //   n <- parsableInt(str)
    //   n <- natural(n)
    // } yield Nat(n)

    // or

    // for {
    //   n <- (parsableInt _ >=> natural)(str)
    // } yield Nat(n)

  }

  def validateListRange(offsetStr: Option[String], limitStr: Option[String]): Valid[ListRange] = {
    val offset = offsetStr match {
      case None => none.successNel
      case Some(s) => s.successNel /\ parsableInt /\ natural <^> (_.some)
    }
    val limit = limitStr match {
      case None => none.successNel
      case Some(s) => s.successNel /\ parsableInt /\ natural <^> (_.some)
    }

    (offset |@| limit)(ListRange)
    // or
    // ListRange |> (offset |@| limit).apply // ApplicativeBuilder.apply を呼んでいるので
  }

  def test = {
    println("======= validateNat =======")
    println(validateNat("10"))
    println(validateNat("-1"))
    println(validateNat("aa"))
    println(validateNat(""))

    println("======= validateListRange =======")
    println(validateListRange(Some("5"), Some("3")))
    println(validateListRange(Some("5"), None))
    println(validateListRange(Some("5"), Some("-3")))
    println(validateListRange(Some("aaa"), Some("-2")))
    println(validateListRange(Some(""), Some("")))
  }
}
