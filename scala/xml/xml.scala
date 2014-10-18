import scala.io._
import scala.xml.XML

object Main extends App {

  val str = Source.fromFile("./sample.xml", "UTF-8").mkString
  def ignoreControlCharacters(str: String) = {
    """(&#x(0[A-Fa-f0-9]|1[A-Fa-f0-9]);|&#(\d|0\d|1\d|2\d|30|31);)""".r.replaceAllIn(str, "")
  }
  try {
    println(XML.loadString(str).toString)
  } catch {
    case e: org.xml.sax.SAXParseException => {
      println("error: " + e.toString)
    }
  }
  println(XML.loadString(ignoreControlCharacters(str)).toString)
}
