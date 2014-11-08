package ghci

import (
	"fmt"
	"io"
	"log"
	"os"
	"os/exec"
	"sync"
	"time"
)

func main() {
	ghci := exec.Command("ghci")

	stdout, err := ghci.StdoutPipe()
	defer stdout.Close()
	if err != nil {
		log.Fatal(err)
		return
	}

	stdin, err := ghci.StdinPipe()
	defer stdin.Close()
	if err != nil {
		log.Fatal(err)
		return
	}

	ghci.Start()

	var wg sync.WaitGroup
	wg.Add(2)
	go func() {
		io.Copy(os.Stdout, stdout)
		wg.Done()
	}()
	go func() {
		io.Copy(stdin, os.Stdin)
		wg.Done()
	}()

	time.Sleep(time.Second)
	ghci.Process.Kill()
	wg.Wait()

	fmt.Println("done")

	// var quit = []byte(":q\n")
	// stdin.Write(quit)

	// buf := make([]byte, 1024)
	// n, err := stdout.Read(buf)
	// if err != nil {
	// 	log.Fatal(err)
	// 	return
	// }

	// fmt.Printf("%s\n", buf[0:n])
	// io.Copy(os.Stdout, stdout)
	// io.Copy(stdin, os.Stdin)
	//	io.Copy(os.Stdout, ghci.Stdout)
}
