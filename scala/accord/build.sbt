organization := "me.amutake"

name := "accord-sample"

scalaVersion := "2.10.3"

scalacOptions ++= Seq("-encoding", "UTF-8", "-Ymacro-debug-lite")

libraryDependencies ++= Seq(
  "com.wix" %% "accord-core" % "0.3"
)
