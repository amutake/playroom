package me.amutake

import akka.actor._

object RingBenchmarks {

  sealed trait Msg
  case class Start(n: Int, t: Int) extends Msg
  case class First(first: ActorRef) extends Msg

  class MasterActor extends Actor {
    def receive = {
      case Start(n, t) => {
        val (rootId, firstId) = makeRing(n, t)
        rootId ! First(firstId)
      }
    }

    def makeRing(n: Int, t: Int): (ActorRef, ActorRef) = { // return value: (the address of the root actor, the address of the next actor of root actor)
      val rootId = context.actorOf(Props(classOf[RootActor], t))
      var next = rootId
      val nodeIds = 1 to n map { _ =>
        next = context.actorOf(Props(classOf[NodeActor], next))
      }
      (rootId, next)
    }
  }

  class RootActor(val init: Int) extends Actor {
    def receive = {
      case First(first) => {
        first ! ()
        context.become(behavior(init - 1, first))
      }
    }
    def behavior(n: Int, next: ActorRef): Receive = {
      case () => {
        if (n == 0) {
          context.system.shutdown()
        } else {
          next ! ()
          context.become(behavior(n - 1, next))
        }
      }
    }
  }

  class NodeActor(val next: ActorRef) extends Actor {
    def receive = {
      case () => next ! ()
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
