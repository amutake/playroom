package main // 実行するパッケージは main というパッケージで

import (
	"./my_package" // 相対パスも書ける
	"fmt"          // 一旦使わないみたいなのは、_ をつける。e.g. _ "fmt"
)

func main() { // main 関数の引数はなし
	// fmt.Println("Hello, World!")
	// var fuga *my_package.Fuga // 変数の宣言
	// fuga = my_package.NewFuga("fuga")
	fuga := my_package.NewFuga("fuga")
	fmt.Println(fuga.A)
	if a := fuga.A; a == "fuga" { // ここのスコープは、if と else の中だけ
		fmt.Println(fuga.String(), fuga.B())
		fmt.Println(a)
	} else {
		fmt.Println("error")
		fmt.Println(a)
	}

	for i := 0; i < 3; i++ { // 普通の
		fmt.Println(i)
	}

	// i, v := range slice or array // i番目、値はv
	// k, v := range map
	// i がいらないときは、_ にする
	for i, v := range []int{1, 2, 3} { // foreach てきな
		fmt.Println(i, v)
	}

	//	switch

	// slice
	// golang の配列は、サイズ付きで、値渡しになるので、関数に渡すと、コピーになる
	// 普通は slice をつかう
	// s := []int{}
	var s []int
	// make(型、大きさ、キャパ
	s = make([]int, 10, 100)
	fmt.Println(len(s)) // 1
	s = []int{1, 2, 3}
	// slice trick で検索すると、いろいろでてくる
	s2 := s[0:1]
	fmt.Println(s2)
	s = append(s, 4)
	ss := []int{4, 5, 6}
	s = append(s, ss...) // 可変長の引数にスライスを渡すときは、... を使う
	fmt.Println(s)

	// map 連想配列
	// map[キーの型]値の型
	// キーは、== で同じになるものを書く
	// var m map[string]int
	// m = make(map[string]int)
	m := make(map[string]int)
	m["hoge"] = 100
	v, ok := m["hoge"]
	fmt.Println(v, ok)
	v, ok = m["fuga"]
	fmt.Println(v, ok)
	for k, v := range m {
		fmt.Println(k, v)
	}
	m = map[string]int{
		"hoge": 100,
		"fuga": 200,
	}
	for k, v := range m {
		fmt.Println(k, v)
	}
}

func Func() (a int, b int, c int) {
	// a := 0 ではない。上で宣言しているので
	a = 0
	b = 10
	c = 100
	return
}
