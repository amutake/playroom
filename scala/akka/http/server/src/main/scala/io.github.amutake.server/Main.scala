package io.github.amutake.server

import scala.concurrent.Await
import scala.concurrent.duration._

import akka.actor.ActorSystem
import akka.http.Http
import akka.http.model.{ HttpEntity, HttpRequest, HttpResponse, HttpMethods, Uri, ContentTypes }
import akka.stream.FlowMaterializer
import akka.util.ByteString

import org.json4s._
import org.json4s.jackson.JsonMethods._

object Main extends App {

  implicit val system = ActorSystem("server")
  implicit val materializer = FlowMaterializer()

  val binding = Http().bind("localhost", 8080)

  binding.startHandlingWithSyncHandler {
    case HttpRequest(HttpMethods.GET, Uri.Path("/ping"), _, _, _) =>
      HttpResponse(entity = "pong")
    case HttpRequest(HttpMethods.GET, Uri.Path("/json"), _, entity, _) => {
      println("================== 1 ======================")
      val bs = entity.dataBytes.fold(ByteString.empty) { case (bs, b) => bs.concat(b) }
      println("================== 2 ======================")
      val str = Await.result(bs, 1.second).decodeString("UTF-8")
      println("================== 3 ======================")
      val json = parse(str)
      println("================== 4 ======================")
      HttpResponse(entity = HttpEntity(pretty(json))
        .withContentType(ContentTypes.`application/json`))
    }
    case _ => HttpResponse(404, entity = "NotFound")
  }
}
