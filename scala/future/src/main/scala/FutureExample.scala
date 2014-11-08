package me.amutake.future

import scala.concurrent.{Future, Await}
import scala.util.{Success, Failure, Random}
import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.duration.Duration

object FutureExample extends App {

  val random = new Random

  def failAfter1s: Future[String] = Future {
    println("running...")
    Thread.sleep(1000)
    if (random.nextInt(2) == 0) {
      throw new Exception("ah")
    }
    "success"
  } recoverWith {
    case t: Exception => failAfter1s
  }

  val f = failAfter1s

  // f.onComplete {
  //   case Success(str) => println(str)
  //   case Failure(t) => println("error: " + t.getMessage)
  // }

  Thread.sleep(2000)

  // Await.result(f, Duration.Inf)
}
