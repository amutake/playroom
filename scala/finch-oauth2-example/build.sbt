scalaVersion := "2.11.7"

libraryDependencies ++= {
  val finch = "0.9.2"
  val circe = "0.2.1"
  val shapeless = "2.2.5"
  val finagleOAuth2 = "0.1.5"
  val jwt = "0.4.1"
  Seq(
    "com.github.finagle" %% "finch-core" % finch,
    "com.github.finagle" %% "finch-circe" % finch,
    "com.github.finagle" %% "finch-oauth2" % finch,
    "com.github.finagle" %% "finagle-oauth2" % finagleOAuth2,
    "io.circe" %% "circe-core" % circe,
    "io.circe" %% "circe-generic" % circe,
    "io.circe" %% "circe-parse" % circe,
    "com.chuusai" %% "shapeless" % shapeless,
    "com.pauldijou" %% "jwt-core" % jwt
  )
}
