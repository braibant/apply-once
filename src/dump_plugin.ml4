(*i camlp4deps: "parsing/grammar.cma" i*)
(*i camlp4use: "pa_extend.cmp" i*)

(* Arcane incantations  *)
let _ = Mltop.add_known_module "Dump_plugin"

let _ = Pp.msgnl (Pp.str "Loading the Output plugin")

open Tacexpr
open Tacinterp

let pp_constr fmt x = Pp.pp_with fmt (Printer.pr_constr x)

VERNAC COMMAND EXTEND PrintTimingProfile
 ["Output" global(cref) "as" string(file) ] ->
   [ 
     let f = Pervasives.open_out file in 
     let fmt = Format.formatter_of_out_channel f in 
     begin
       try
	 begin match Nametab.global cref with
	   | Libnames.ConstRef sp ->
	     begin
	       let cb = Global.lookup_constant sp in
	       match cb.Declarations.const_body with
		 | Declarations.Def lc ->
		   let (c : Term.constr) = Declarations.force lc in 
		   let (ty: Term.types) = 
		     match cb.Declarations.const_type with 
		       | Declarations.NonPolymorphicType ty -> ty
		       | _ -> Util.anomaly "Output work only for non-polymorphic values"
		   in
		   let (c: Term.constr) = Vnorm.cbv_vm (Global.env ()) c ty in
		   Format.fprintf fmt "%a" pp_constr c ;
		   Pervasives.close_out f
		 | _  -> Util.anomaly "Output work only for global definitions"
	     end   
	 end            
       with 
	 | _ ->  Pervasives.close_out f; Util.anomaly "Output error!"
     end;

   ]
END;;
