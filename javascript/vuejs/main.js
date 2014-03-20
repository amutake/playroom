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
        fetch: function() {
            var self = this;
            var endpoint = "http://localhost:3000/todos";
            $.ajax({
                url: endpoint,
                type: "GET"
            }).done(function(todos) {
                self.todos = todos;
            });
        },
        add: function() {
            var self = this;
            var endpoint = "http://localhost:3000/todos";
            var todo = self.form;
            $.ajax({
                url: endpoint,
                type: "POST",
                data: JSON.stringify(todo)
            }).done(function(todo) {
                self.fetch();
                self.form.content = "";
            });
        },
        toggle: function(id) {
            var self = this;
            var endpoint = "http://localhost:3000/todos/toggle";
            $.ajax({
                url: endpoint,
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
    },
    created: function() {
        this.fetch();
    }
});
