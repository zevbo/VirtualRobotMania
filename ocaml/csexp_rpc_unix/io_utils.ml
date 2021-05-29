open! Core
open! Async
open! Import

let input_of_reader reader =
  Input.create
    reader
    ~really_read:(fun r bytes -> Reader.really_read r bytes)
    ~close:Reader.close
    ~close_finished:Reader.close_finished

let output_of_writer writer =
  Output.create
    writer
    ~write_bytes:Writer.write_bytes
    ~close:Writer.close
    ~close_finished:Writer.close_finished
