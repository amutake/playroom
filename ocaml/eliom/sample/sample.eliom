{shared{
  open Eliom_lib
  open Eliom_content
  open Html5
  open Html5.D
}}

module Sample_app =
  Eliom_registration.App (
    struct
      let application_name = "sample"
    end)

let main_service =
  Eliom_service.service ~path:[] ~get_params:Eliom_parameter.unit ()

let () =
  Sample_app.register
    ~service:main_service
    (fun () () ->
      Lwt.return
        (Eliom_tools.F.html
           ~title:"sample"
           ~css:[["css";"sample.css"]]
           Html5.F.(body [
             h2 [pcdata "Welcome from Eliom's destillery!"];
           ])))

{client{

  let mywidget s1 s2 =
    let button = div ~a:[a_class["button"]][pcdata s1] in
    let content = div ~a:[a_class["content"]][pcdata s2] in
    div ~a:[a_class ["mywidget"]][button; content]

  let _ =
    lwt _ = Lwt_js_events.onload () in
    Dom.appendChild
      (Dom_html.document##body)
      (To_dom.of_element (mywidget "Click me" "Hello!"));
    Lwt.return ()
}}
