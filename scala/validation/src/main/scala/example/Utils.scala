package example

import scalaz._
import Scalaz._

object Utils {

  import Validation._

  val parsableInt: String => Valid[Int] = { s =>
    try {
      s.toInt.successNel
    } catch {
      case _: NumberFormatException => ValueError("cannot parse \"" + s + "\" to Int").failureNel
    }
  }

  val natural: Int => Valid[Int] = n => if (n >= 0) {
    n.successNel
  } else {
    ValueError(n.toString + " is not a natural number").failureNel
  }
}
