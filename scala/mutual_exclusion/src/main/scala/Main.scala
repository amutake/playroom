import akka.actor._

object Main {

  def main(args: Array[String]) = {
    val system = ActorSystem()
    // 調整者を作る
    val moderator = system.actorOf(Props[Moderator])
    // ワーカーを5つ作る
    val workers = (1 to 5).map { id =>
      system.actorOf(Props(classOf[Worker], id, moderator))
    }
    // ワーカーを起動させる
    workers.foreach { worker =>
      worker ! Start
    }
  }
}
