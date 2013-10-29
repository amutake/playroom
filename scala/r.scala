object R {

  val s = """
あいうえおかきくけこ
    さしすせそたちつてと
[this is link](http://google.com)

- aaa
- bbb
- ccc

あかさたな
"""

  def r(str: String) = {
    println(str.r.findFirstIn(s).getOrElse("none"))
  }
}
