(* ::Package:: *)

(* Paclet Info File *)
(* BuildNumber and Internal values should be inserted during build procedure. *)
Paclet[
	Name -> "ImportMesh",
	Version -> "0.3.2",
	WolframVersion -> "11.+",
    Description -> "Utilities for importing FEM meshes from other software.",
    Creator -> "Matevz Pintar",
    Publisher->"C3M d.o.o.",
    URL -> "https://github.com/c3m-labs/ImportMesh",
    Extensions -> {
		{"Kernel",
			Root -> ".",
			Context ->{"ImportMesh`"}
		},
		(* Metadata for PacletServer (https://paclets.github.io/PacletServer) *)
		{"PacletServer",
			"Tags" -> {"finite-elements","mesh","FEM","import"},
			"Categories" -> {"FEM"},
			"Description" -> "Utilities for importing FEM meshes from other software.",
			"License" -> "MIT"
		}
	}
]
