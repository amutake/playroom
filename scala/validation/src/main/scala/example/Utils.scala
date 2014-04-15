package example

import scalaz._
import Scalaz._

object Utils {

  import Validation._

  def parsableInt(s: String): Valid[Int] = {
    try {
      s.toInt.successNel
    } catch {
      case _: NumberFormatException => ValueError("cannot parse \"" + s + "\" to Int").failureNel
    }
  }

  def natural(n: Int): Valid[Int] = if (n >= 0) {
    n.successNel
  } else {
    ValueError(n.toString + " is not a natural number").failureNel
  }
}
