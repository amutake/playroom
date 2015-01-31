package io.github.amutake.server

import akka.actor.ActorSystem
import akka.http.Http
import akka.http.model.{ HttpRequest, HttpResponse, HttpMethods, Uri }
import akka.stream.FlowMaterializer

object Main extends App {

  implicit val system = ActorSystem("server")
  implicit val materializer = FlowMaterializer()

  val binding = Http().bind("localhost", 8080)

  binding.startHandlingWithSyncHandler {
    case HttpRequest(HttpMethods.GET, Uri.Path("/ping"), _, _, _) =>
      HttpResponse(entity = "pong")
    case _ => HttpResponse(404, entity = "NotFound")
  }
}
