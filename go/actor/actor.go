package main

import (
	"fmt"
)

type Actor struct {
	addr     chan interface{}
	behavior Behavior
}

type Behavior func(interface{})

type Address chan interface{}

func NewActor(init Behavior) Actor {
	return Actor{
		addr:     make(chan interface{}),
		behavior: init,
	}
}

func (actor *Actor) Become(next Behavior) {
	actor.behavior = next
}

func (actor *Actor) Run() {
	go func() {
		for {
			m := <-actor.addr
			actor.behavior(m)
		}
	}()
}

func main() {
	a1 := NewActor(func(m interface{}) {
		fmt.Println(m)
	})
	a2 := NewActor(func(m interface{}) {
		fmt.Println(m)

	})
	a1.Run()
	a2.Run()
}
