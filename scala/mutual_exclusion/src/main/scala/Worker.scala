import scala.util.Random

import akka.actor._

class Worker(id: Int, moderator: ActorRef) extends Actor with ActorLogging {

  // リソースの確保と解放を行う高階関数
  def withResource(f: Resource.type => Unit) = {
    log.info(s"resource is used by ${id}")
    f(Resource)
    log.info(s"resource is released by ${id}")
  }

  // n秒からm秒待つ関数
  def randomWait(n: Int, m: Int) = {
    val msec = Random.nextInt(m * 1000 - n * 1000) + n * 1000
    Thread.sleep(msec)
  }

  def receive: Receive = {
    // リソースの使用を許可された場合
    case OK => {
      // ここでリソースを使っているつもり(実際は数秒待つだけ)
      withResource { resource =>
        // 1s ~ 3s の間でランダムな時間待つ
        randomWait(1, 3)
      }

      // リソースを使い終わったことを調整者に伝える
      moderator ! Finish

      // 次
      self ! Start
    }
    // 待つように指示された場合
    case Wait => {} // 何もしない
    // ワーカーの実行
    case Start => {
      randomWait(1, 10)   // 数秒待つ(なんらかの計算を行っているつもり)
      moderator ! Request // リソースを使いたくなったので調整者にリソースのリクエストを送る
    }
  }

}
