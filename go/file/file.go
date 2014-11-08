package main

import (
	"fmt"
	"log"
	"os"
)

func main() {
	file, err := os.Open("./hoge")
	defer file.Close()
	if err != nil {
		log.Fatal(err)
	}
	_, err = file.Write([]byte("hogehoge"))
	if err != nil {
		log.Fatal(err)
	}
	buf := make([]byte, 1024)
	n, _ := file.Read(buf)
	fmt.Printf("%s\n=====\n", buf[0:n])

	nn, _ := file.Read(buf)
	fmt.Printf("%s\n=====\n", buf[0:nn])
}
