(* ::Package:: *)

(* Paclet Info File *)
Paclet[
	Name -> "ImportMesh",
	Version -> "0.3.1",
	WolframVersion -> "11.+",
    Description -> "Utilities for importing FEM meshes from other software.",
    Creator -> "info@c3m.si",
    Publisher->"C3M d.o.o.",
    URL -> "https://github.com/c3m-labs/ImportMesh",
    Tags -> {"finite-elements","mesh","import"},
    Categories -> {"FEM"},
	Extensions -> {
		{"Kernel", Root -> ".", Context ->{"ImportMesh`"}}
	}
]
