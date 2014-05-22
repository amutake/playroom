package main

import (
	"flag"
	"fmt"
)

func main() {

	str := flag.String("string", "hogehoge", "string value")

	flag.Parse()

	fmt.Println(*str)
	fmt.Scan()
}
