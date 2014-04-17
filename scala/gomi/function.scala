object FunctionTest {

  def f(a: Int)(b: Int) = a + b
  // def f(a: Int) = (b: Int) => a + b
  def g(a: Int) = a.toString

  implicit class MyFunction[A, B](val f: Function[A, B]) {
    def >>[C](g: B => C): A => C = a => g(f(a))
  }

  // def test = (f(1) >> g)

  def compose[A,B,C](f: A => B, g: B => C) = (a: A) => g(f(a))

  def test2 = compose(f(1), g)
}
