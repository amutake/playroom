mod method {
    struct Person {
        age: int,
        name: &'static str
    }

    pub fn new_person(age: int, name: &'static str) -> Person {
        Person { age: age, name: name }
    }

    pub fn print(person: &Person) {
        println!("Person {{ age = {}, name = {} }}", person.age, person.name)
    }

    impl Person {
        pub fn print(&self) {
            println!("Person {{ age = {}, name = {} }}", self.age, self.name)
        }

        pub fn update_age(&mut self, age: int) {
            self.age = age
        }
    }
}

fn main() {
    let mut p = method::new_person(22, "amutake");
    method::print(&p);
    p.update_age(23);
    p.print();
}
