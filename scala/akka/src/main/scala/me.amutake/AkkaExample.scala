package me.amutake

import akka.actor._

object AkkaExample {

  // 商品
  sealed trait Item
  case object Tea extends Item
  case object Coffee extends Item

  // 自動販売機の操作
  sealed trait Control
  case object PutCoin extends Control
  case object TeaButton extends Control
  case object CoffeeButton extends Control

  // 自動販売機アクター
  // 1コインでお茶とコーヒーが買える
  class VendingMachine extends Actor with ActorLogging {

    // コインが十分にあるかどうかをチェックしてログを残すだけ
    def returnItem(numCoins: Int, item: Item): Unit = {
      log.info(s"現在のコイン: ${numCoins.toString} 枚")
      if (numCoins > 0) {
        log.info(item.toString)
        context.become(behavior(numCoins - 1))
      } else {
        log.info(s"コインが足りません: ${item.toString}")
        context.become(behavior(numCoins))
      }
    }

    // 振る舞いの定義。コインの数を状態として持っている。
    // context.become で振る舞いを変える際に、次の状態も一緒に渡してやる
    // 参考: Erlang,
    //    Agha 先生の論文 http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.89.9331&rep=rep1&type=pdf の第3章の Simple Actor Language
    def behavior(numCoins: Int): Receive = {
      case PutCoin => {
        log.info(s"操作: ${PutCoin.toString}")
        context.become(behavior(numCoins + 1))
      }
      case TeaButton => {
        log.info(s"操作: ${TeaButton.toString}")
        returnItem(numCoins, Tea)
      }
      case CoffeeButton => {
        log.info(s"操作: ${CoffeeButton.toString}")
        returnItem(numCoins, Coffee)
      }
    }

    // 初期化
    def receive: Receive = behavior(0)
  }

  def main(args: Array[String]) = {
    val system = ActorSystem()
    val vm = system.actorOf(Props[VendingMachine])

    vm ! TeaButton
    vm ! PutCoin
    vm ! PutCoin
    vm ! TeaButton
    vm ! CoffeeButton
    vm ! TeaButton

    system.shutdown()
  }
}
