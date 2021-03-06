open Base

exception Type_ex of string

class node _ty _mem = object(self)
  val mem : (string * node) list = _mem
  val ty = _ty
  method get (id : string) : node option =
    match List.findi mem ~f:(fun i a -> let (a, _) = a in String.is_prefix a ~prefix:id) with
    | None -> None
    | Some (_ , (_, res)) -> Some res
end

class ty _id _hash _mem = object(self)
  val mem : (string * ty) list = _mem
  val id : string = _id
  val hash : int = _hash
  method size = 10 (*depends on member *)

  method hash = hash
  method id = id
  method mem = mem

  method crt (args : node list) : node =
    new node self
      (List.map2
         ~f:(fun a b ->
           let (x, y) = a in
           if y#hash != any_ty#hash && y#hash != b#ty#hash
           then raise (Type_ex "unable to construct type | different type expected")
           else (x, b))
         self#mem args)
end

module Table = Table.Make(struct type val_t = t end)

(* intrinsic types *)

let current_hash = ref 0
let next_hash () =
  let hash = !current_hash + 1 in
  current_hash := hash;
  hash


let any_ty = new ty "any" (next_hash ()) []
let () = Table.add "any" any_ty

let id_ty = new ty "id" (next_hash ()) []
let () = Table.add "id" id_ty

let list_ty = new ty "list" (next_hash ()) [("next", list_ty); ("val", any_ty)]
let () = Table.add "list" list_ty


(* intrinsic nodes *)

let null_node = new node any_ty []

class id_node _v = object(self)
  inherit node id_ty []
  val v : string = _v
end

(* -------------------- *)
