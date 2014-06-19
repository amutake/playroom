package me.amutake

import akka.actor._

object RingBenchmarks {

  sealed trait Msg
  case class Start(n: Int, t: Int) extends Msg
  case class Next(next: ActorRef) extends Msg
  case object End extends Msg

  class MasterActor extends Actor {
    def receive = {
      case Start(n, t) => {
        val rootId = makeRing(n, t)
        rootId ! ()
      }
      case End => {
        println("finish")
        context.system.shutdown
      }
    }

    def makeRing(n: Int, t: Int): ActorRef = { // return value: the address of the root actor
      val rootId = context.actorOf(Props(classOf[RootActor], t, self), "root")
      val nodeIds = 1 to (n - 1) map { num =>
        context.actorOf(Props[NodeActor], "node" ++ num.toString)
      }
      (rootId +: nodeIds) zip (nodeIds :+ rootId) map { case (id1, id2) =>
        id1 ! Next(id2)
      }
      rootId
    }
  }

  class RootActor(val init: Int, val master: ActorRef) extends Actor {
    def receive = {
      case Next(next) => context.become(behavior(init, next))
    }
    def behavior(n: Int, next: ActorRef): Receive = {
      case () => {
        if (n == 0) {
          master ! End
        } else {
          next ! ()
          context.become(behavior(n - 1, next))
        }
      }
    }
  }

  class NodeActor extends Actor {
    def receive = {
      case Next(next) => context.become(behavior(next))
    }
    def behavior(next: ActorRef): Receive = {
      case () => {
        next ! ()
      }
    }
  }

  def main(args: Array[String]) = {
    val n = args(0).toInt // n 個のアクターで、
    val t = args(1).toInt // t 周メッセージを回す

    val system = ActorSystem()
    val master = system.actorOf(Props[MasterActor])

    master ! Start(n, t)
  }
}
