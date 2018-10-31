(* ::Package:: *)

(* Paclet Info File *)
Paclet[
	Name -> "ImportMesh",
	Version -> "0.3.1",
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
		{"PacletServer",
			"Tags" -> {"finite-elements","mesh","FEM","import"},
			"Categories" -> {"FEM"},
			"Description" -> "Utilities for importing FEM meshes from other software.",
			"License" -> "MIT"
		}
	}
]
