package me.amutake

import com.wix.accord._
import com.wix.accord.dsl._
import com.wix.accord.transform._

object Sample {

  def main(args: Array[String]) = {
    val validData = Data(1, Person("hoge", "valid"))
    val invalidData = Data(-1, Person("", "invalid"))
    println(validate(validData)(Data.dataValidator))
    println(validate(invalidData)(Data.dataValidator))
  }
}
