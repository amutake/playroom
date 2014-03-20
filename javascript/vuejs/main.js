var api = {
    fetch: function() {
        var self = this;
        $.ajax({
            url: "http://localhost:3000/todos",
            type: "GET"
        }).done(function(todos) {
            self.todos = todos;
        });
    },
    add: function() {
        var self = this;
        $.ajax({
            url: "http://localhost:3000/todos",
            type: "POST",
            data: JSON.stringify(self.form)
        }).done(function(todo) {
            self.todos.push(todo);
            self.form.content = "";
        });
    },
    toggle: function(id) {
        var self = this;
        $.ajax({
            url: "http://localhost:3000/todos/toggle",
            type: "POST",
            data: {
                id: id
            }
        }).done(function(ok) {
            if (ok) {
                self.todos[id].done = !self.todos[id].done
            }
        });
    }
};

var vm = new Vue({
    el: '#demo',
    data: {
        title: 'todos',
        todos: [],
        form: {
            done: false,
            content: ""
        }
    },
    methods: {
        fetch: api.fetch,
        add: api.add,
        toggle: api.toggle
    },
    created: function() {
        this.fetch();
    }
});
