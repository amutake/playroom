package main

import (
	"log"
	"net/http"
	"strconv"

	"github.com/codegangsta/martini"
	"github.com/martini-contrib/binding"
	"github.com/martini-contrib/render"
)

type ToDo struct {
	Done    bool   `json:"done"`
	Content string `json:"content"`
}

type ToggleReq struct {
	Id int `form:"id"`
}

var (
	ToDoList = []ToDo{
		ToDo{Done: true, Content: "Learn Golang"},
		ToDo{Done: false, Content: "Learn Vue.js"},
	}
)

func main() {
	m := martini.Classic()
	m.Use(render.Renderer())

	m.Get("/todos", func(res http.ResponseWriter, ren render.Render) {
		res.Header().Add("Access-Control-Allow-Origin", "*")
		ren.JSON(200, ToDoList)
	})

	m.Post("/todos", binding.Json(ToDo{}), func(todo ToDo, res http.ResponseWriter, ren render.Render) {
		ToDoList = append(ToDoList, todo)
		res.Header().Add("Access-Control-Allow-Origin", "*")
		ren.JSON(200, todo)
	})

	m.Post("/todos/toggle", binding.Form(ToggleReq{}), func(
		toggleReq ToggleReq,
		res http.ResponseWriter,
		ren render.Render,
	) string {
		id := toggleReq.Id
		log.Print(id)
		res.Header().Add("Access-Control-Allow-Origin", "*")
		ToDoList[id].Done = !ToDoList[id].Done
		return strconv.FormatBool(true)
	})

	m.Run()
}
