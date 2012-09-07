(*i camlp4deps: "parsing/grammar.cma" i*)
(*i camlp4use: "pa_extend.cmp" i*)

(* Arcane incantations  *)

let _ = Mltop.add_known_module "Ltac_ext_plugin";;
let _ = Pp.msgnl (Pp.str "Loading the LTac extension plugin")


open Tacexpr

(** Run tactic [k] with constr [x] as argument. *)
let run_cont k x =
  let k = TacDynamic(Util.dummy_loc, Tacinterp.tactic_in (fun _ -> k)) in
  let x = TacDynamic(Util.dummy_loc, Pretyping.constr_in x) in
  let tac = <:tactic<let cont := $k in cont $x>> in
  Tacinterp.interp tac

(** [iter_tac tac] applies [tac] to all the hypotheses that occur in
    the original goal. 

    [tac] is called on each hypothesis name that occur in the original
    goal: if one such hypothesis [H] gets removed because of a
    side-effect of [tac], [tac H] will be called nevertheless. 

    If, for some [H], [tac H] creates new hypotheses, these will _not_
    be processed in this iteration.
*)

let iter_tac tac gl = 
  let l = List.map 
    (fun id -> 
      try 
	(* we run the tactic, with an argument being the name of the hypothesis *)
	run_cont tac (Term.mkVar id)
      with 
	(* if anything goes wrong (e.g., the tactic we apply has side
	   effects, and remove another hypothesis), we just do
	   nothing, and we continue to fold through the hypotheses *)
	Not_found -> Tacticals.tclIDTAC
    )
    (Tacmach.pf_ids_of_hyps gl)
  in
  Tacticals.tclTHENLIST l gl
;;
    
    
TACTIC EXTEND iter_tac
  | ["iter_tac" tactic(t)] -> 
    [fun gl -> 
      iter_tac t gl
    ]
END;;

