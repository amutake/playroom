use std::io::{Command, IoResult};
use std::os::args;

static BIN_NAME: &'static str = "rust_program_by_runrust";

fn main() {
    let args = args();
    if args.is_empty() {
        println!("Usage: runrust <path>");
        println!("");
        println!("  execute rust program")
    } else {
        for arg in args.iter() {
            println!("processing {}...", arg);
            match compile(arg) {
                Err(reason) => println!("{}", reason.desc),
                Ok(_) => match run() {
                    Err(reason) => println!("{}", reason.desc),
                    Ok(_) => match remove() {
                        Err(reason) => println!("{}", reason.desc),
                        Ok(_) => println!("done"),
                    },
                },
            }
        }
    }
}

fn compile(path: &String) -> IoResult<()> {
    match Command::new("rustc").arg("-o").arg(BIN_NAME).arg(path).output() {
        Err(reason) => Err(reason),
        Ok(output) => {
            println!("{}", String::from_utf8(output.output));
            Ok(())
        }
    }
}

fn run() -> IoResult<()> {
    match Command::new(BIN_NAME).output() {
        Err(reason) => Err(reason),
        Ok(output) => {
            println!("{}", String::from_utf8(output.output));
            Ok(())
        }
    }
}

fn remove() -> IoResult<()> {
    match Command::new("rm").arg(BIN_NAME).output() {
        Err(reason) => Err(reason),
        Ok(output) => {
            println!("{}", String::from_utf8(output.output));
            Ok(())
        }
    }
}
