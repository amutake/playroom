package main

import (
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

func CrossDomain() martini.Handler {
	return func(res http.ResponseWriter) {
		res.Header().Add("Access-Control-Allow-Origin", "*")
	}
}

func main() {
	m := martini.Classic()
	m.Use(render.Renderer())
	m.Use(CrossDomain())

	m.Get("/todos", func(ren render.Render) {
		ren.JSON(200, ToDoList)
	})

	m.Post("/todos", binding.Json(ToDo{}), func(todo ToDo, ren render.Render) {
		ToDoList = append(ToDoList, todo)
		ren.JSON(200, todo)
	})

	m.Post("/todos/toggle", binding.Form(ToggleReq{}), func(toggleReq ToggleReq, ren render.Render) string {
		id := toggleReq.Id
		ToDoList[id].Done = !ToDoList[id].Done
		return strconv.FormatBool(true)
	})

	m.Run()
}
