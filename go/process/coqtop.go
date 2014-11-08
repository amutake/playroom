package main

import (
	"bufio"
	"fmt"
	"io"
	"log"
	"os"
	"os/exec"
	"reflect"
)

func main() {
	coqtop := exec.Command("coqtop", "-emacs")

	stdout, err := coqtop.StdoutPipe()
	defer stdout.Close()
	if err != nil {
		log.Fatal(err)
		return
	}

	stdin, err := coqtop.StdinPipe()
	defer stdin.Close()
	if err != nil {
		log.Fatal(err)
		return
	}

	stderr, err := coqtop.StderrPipe()
	defer stderr.Close()
	if err != nil {
		log.Fatal(err)
		return
	}

	fmt.Println(reflect.TypeOf(stderr))
	coqtop.Start()

	ch := make(chan []byte)
	go run(ch, stdin, stdout, stderr)
	input(ch)
}

func run(ch chan []byte, stdin io.WriteCloser, stdout io.ReadCloser, stderr io.ReadCloser) {
	for cmd := range ch {
		go func() {
			fmt.Printf("received1: %s", cmd)
			stdin.Write(cmd)
			fmt.Printf("received2: %s", cmd)
			buf := make([]byte, 1024)
			n, err := stderr.Read(buf)
			fmt.Printf("received3: %s", cmd)
			if err != nil {
				log.Fatal(err)
			}
			fmt.Printf("%s\n", buf[0:n])
		}()
	}
}

func input(ch chan []byte) {
	in := bufio.NewReader(os.Stdin)
	for {
		line, _, err := in.ReadLine()
		if err != nil {
			log.Fatal(err)
		}
		ch <- line
	}
}
