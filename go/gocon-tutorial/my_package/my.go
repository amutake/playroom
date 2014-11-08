package my_package

import (
	"fmt"
)

func Hoge() string {
	fmt.Println("hello")
	return "hello"
}

// type 型名 実体
// コンストラクタはない
type Fuga struct {
	// フィールド名 型
	A string
	b int
}

// 普通、NewFuga() みたいに、普通の関数としてコンストラクタを書く
func NewFuga(a string) *Fuga {
	// return &Fuga{a, 100}
	// or
	return &Fuga{
		b: 100,
		A: a,
	}
}

func (f *Fuga) String() string {
	return f.A
}

// getter (golang では getB() みたいな名前にはしない B() そのまま)
func (f *Fuga) B() int {
	return f.b
}
