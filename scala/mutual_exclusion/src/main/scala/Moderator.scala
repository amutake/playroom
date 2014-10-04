import scala.collection.mutable.Queue

import akka.actor._

// 調整者のクラス
class Moderator extends Actor with ActorLogging {

  // 現在リソースを使っているワーカーID
  var inUse: Option[ActorRef] = None
  // リソースの解放を待つワーカーIDのキュー
  val queue: Queue[ActorRef] = Queue()

  def receive = {
    // リソースを使いたいというリクエストが来たとき
    case Request => {
      if (inUse.isEmpty) {   // 誰もリソースを使っていない場合
        inUse = Some(sender) // リクエストを送った人
        sender ! OK          // リソースの使用の許可
      } else { // 誰かがリソースを使っている場合
        queue.enqueue(sender) // キューに追加
        sender ! Wait         // 待つように指示
      }
    }
    // リソースを使い終わったというメッセージが来たとき
    case Finish => inUse match {
      // Finish というメッセージを送ってきたワーカーが現在リソースを使っているワーカーである場合
      case Some(id) if sender == id => {
        inUse = None // 誰もリソースを使っていないように変更
        if (queue.nonEmpty) { // リソースの解放を待っているワーカーがいる場合
          val next = queue.dequeue // キューの先頭がリソースを使う次のワーカーになる
          inUse = Some(next)
          next ! OK                // リソースの使用を許可
        }
      }
      // それ以外(おかしいメッセージの場合)
      // 1. 誰もリソースを使っていない(と調整者は思っている)のに Finish というメッセージが来た
      // 2. リソースを使っているワーカーではないワーカーから Finish というメッセージが来た
      case _ => {
        log.warning("invalid message: Finish")
      }
    }
  }
}
