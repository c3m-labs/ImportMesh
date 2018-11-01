(* ::Package:: *)

(* ::Subsection::Closed:: *)
(*Description*)


(* ::Text:: *)
(*These are unit test for "ImportMesh" paclet. *)


(* "ImportMesh`" package must be loaded before running these tests, otherwise testing is aborted. *)
If[
	Not@MemberQ[$Packages,"ImportMesh`"],
	Print["Error: Package is not loaded!"];Abort[];
];


(* Tests should be always run from development environment - there they make sense. *)
With[{
	dir=FileNameJoin[{"Location"/.PacletInformation["ImportMesh"],"Tests"}]
	},
	If[
		DirectoryQ[dir],
		$testDir=dir,
		Print["Cannot find directory with tests."];Abort[]
	]
];


(* Currently it is unclear what this line does, it is automatically generated during conversion to .wlt *)
BeginTestSection["Tests"]


(* ::Subsection::Closed:: *)
(*Abaqus*)


(* ::Subsubsection::Closed:: *)
(*Custom input files*)


VerificationTest[
	ImportMesh[FileNameJoin[{$testDir,"Abaqus","Tet4_cube.inp"}]],	
	_ElementMesh,
	SameTest->MatchQ,
	TestID->"Abaqus_Tet4"
]


VerificationTest[
	ImportMesh[FileNameJoin[{$testDir,"Abaqus","Hex8_cube.inp"}]],	
	_ElementMesh,
	SameTest->MatchQ,
	TestID->"Abaqus_Hex8"
]


(* ::Subsubsection::Closed:: *)
(*Input files from Abaqus documentation*)


(* ::Text:: *)
(*Source of files: http://abaqus.software.polimi.it/v6.14/books/bmk/default.htm*)


(* NAFEMS LE1 test *)
VerificationTest[
	ImportMesh[FileNameJoin[{$testDir,"Abaqus","Tri3_annulus.inp"}]],	
	_ElementMesh,
	SameTest->MatchQ,
	TestID->"Abaqus_Tri3-2D"
]


(* NAFEMS LE1 test *)
VerificationTest[
	ImportMesh[FileNameJoin[{$testDir,"Abaqus","Quad4_annulus.inp"}]],	
	_ElementMesh,
	SameTest->MatchQ,
	TestID->"Abaqus_Quad4-2D"
]


(* NAFEMS LE3 test *)
VerificationTest[
	ImportMesh[FileNameJoin[{$testDir,"Abaqus","Tri3_shell.inp"}]],	
	_ElementMesh,
	SameTest->MatchQ,
	TestID->"Abaqus_Tri3-3D"
]


(* NAFEMS LE3 test *)
VerificationTest[
	ImportMesh[FileNameJoin[{$testDir,"Abaqus","Quad4_shell.inp"}]],	
	_ElementMesh,
	SameTest->MatchQ,
	TestID->"Abaqus_Quad4-3D"
]


(* ::Subsubsection::Closed:: *)
(*Tests of format registration for System`Import function*)


VerificationTest[
	Import[
		FileNameJoin[{$testDir,"Abaqus","Tri3_annulus.inp"}],
		{"AbaqusMesh","Elements"}
	],	
	{"Mesh","MeshNodes","MeshElements"},
	TestID->"Abaqus_System`Import-Elements"
]


VerificationTest[
	Import[
		FileNameJoin[{$testDir,"Abaqus","Tri3_annulus.inp"}],
		{"AbaqusMesh","Mesh"}
	],	
	ElementMesh[
		{{0.,1.},{0.,1.875},{0.,2.75},{1.16500008,0.812829971},{1.4740001,1.55601501},{1.78300011,2.29920006},{1.78302014,0.452999949},{2.30790997,0.900500059},{2.83279991,1.34800017},{2.,0.},{2.625,0.},{3.25,0.}},
		{TriangleElement[{{5,2,1},{1,4,5},{8,5,4},{4,7,8},{11,8,7},{7,10,11},{6,3,2},{2,5,6},{9,6,5},{5,8,9},{12,9,8},{8,11,12}},{1,1,1,1,1,1,1,1,1,1,1,1}]},
		{LineElement[{{2,1},{1,4},{4,7},{10,11},{7,10},{3,2},{6,3},{9,6},{12,9},{11,12}}]}
	],
	TestID->"Abaqus_System`Import-Mesh"
]


(* ::Subsubsection::Closed:: *)
(*Tests that should fail at importing*)


(* Spatial beams (or truss) are not supported. *)
VerificationTest[
	ImportMesh[FileNameJoin[{$testDir,"Abaqus","Beams.inp"}]],	
	$Failed,
	{ImportMesh::eltype,ImportMesh::fail},
	TestID->"Abaqus_unsupported-element-type"
]


(* Abaqus functionality to generate nodes and elements on-the-fly is not supported. *)
VerificationTest[
	ImportMesh[FileNameJoin[{$testDir,"Abaqus","Tri6_shell.inp"}]],	
	$Failed,
	{ImportMesh::abaqus,ImportMesh::fail},
	TestID->"Abaqus_ELGEN-keyword-fail"
]


(* ::Subsection::Closed:: *)
(*Comsol*)


VerificationTest[
	ImportMesh[FileNameJoin[{$testDir,"Comsol","Tri3_squares.mphtxt"}]],	
	_ElementMesh,
	SameTest->MatchQ,
	TestID->"Comsol_Tri3"
]


VerificationTest[
	ImportMesh[FileNameJoin[{$testDir,"Comsol","Tri6_square.mphtxt"}]],	
	_ElementMesh,
	SameTest->MatchQ,
	TestID->"Comsol_Tri6"
]


VerificationTest[
	ImportMesh[FileNameJoin[{$testDir,"Comsol","Quad4_square.mphtxt"}]],	
	_ElementMesh,
	SameTest->MatchQ,
	TestID->"Comsol_Quad4-2D"
]


VerificationTest[
	ImportMesh[FileNameJoin[{$testDir,"Comsol","Quad4_cube.mphtxt"}]],	
	_ElementMesh,
	SameTest->MatchQ,
	TestID->"Comsol_Quad4-3D"
]


VerificationTest[
	ImportMesh[FileNameJoin[{$testDir,"Comsol","Quad8_square.mphtxt"}]],	
	_ElementMesh,
	SameTest->MatchQ,
	TestID->"Comsol_Quad8"
]


VerificationTest[
	ImportMesh[FileNameJoin[{$testDir,"Comsol","Tet4_cubes.mphtxt"}]],	
	_ElementMesh,
	SameTest->MatchQ,
	TestID->"Comsol_Tet4-1"
]


VerificationTest[
	ImportMesh[FileNameJoin[{$testDir,"Comsol","Tet4_cubes_2.mphtxt"}]],	
	_ElementMesh,
	SameTest->MatchQ,
	TestID->"Comsol_Tet4-2"
]


VerificationTest[
	ImportMesh[FileNameJoin[{$testDir,"Comsol","Tet10_cube.mphtxt"}]],	
	_ElementMesh,
	SameTest->MatchQ,
	TestID->"Comsol_Tet10"
]


VerificationTest[
	ImportMesh[FileNameJoin[{$testDir,"Comsol","Hex20_cube.mphtxt"}]],	
	_ElementMesh,
	SameTest->MatchQ,
	TestID->"Comsol_Hex20"
]


(* ::Subsection::Closed:: *)
(*Elfen*)


VerificationTest[
	ImportMesh[FileNameJoin[{$testDir,"Elfen","Quad4_disc.mes"}]],	
	_ElementMesh,
	SameTest->MatchQ,
	TestID->"Elfen_Quad4"
]


VerificationTest[
	ImportMesh[FileNameJoin[{$testDir,"Elfen","Quad8_disc.mes"}]],	
	_ElementMesh,
	SameTest->MatchQ,
	TestID->"Elfen_Quad8"
]


VerificationTest[
	ImportMesh[FileNameJoin[{$testDir,"Elfen","Tet4_cube.mes"}]],	
	_ElementMesh,
	SameTest->MatchQ,
	TestID->"Elfen_Tet4"
]


VerificationTest[
	ImportMesh[FileNameJoin[{$testDir,"Elfen","Tet10_cube.mes"}]],	
	_ElementMesh,
	SameTest->MatchQ,
	TestID->"Elfen_Tet10"
]


VerificationTest[
	ImportMesh[FileNameJoin[{$testDir,"Elfen","Hex8_cube.mes"}]],	
	_ElementMesh,
	SameTest->MatchQ,
	TestID->"Elfen_Hex8"
]


VerificationTest[
	ImportMesh[FileNameJoin[{$testDir,"Elfen","Hex20_cube.mes"}]],	
	_ElementMesh,
	SameTest->MatchQ,
	TestID->"Elfen_Hex20"
]


(* ::Subsection::Closed:: *)
(*GMSH*)


(* ::Subsubsection::Closed:: *)
(*Surface mesh*)


VerificationTest[
	ImportMesh[FileNameJoin[{$testDir,"Gmsh","Tri3_cone.msh"}]],	
	_ElementMesh,
	SameTest->MatchQ,
	TestID->"Gmsh_Tri3"
]


VerificationTest[
	ImportMesh[FileNameJoin[{$testDir,"Gmsh","Tri6_cone.msh"}]],	
	_ElementMesh,
	SameTest->MatchQ,
	TestID->"Gmsh_Tri6"
]


VerificationTest[
	ImportMesh[FileNameJoin[{$testDir,"Gmsh","Quad4_box.msh"}]],	
	_ElementMesh,
	SameTest->MatchQ,
	TestID->"Gmsh_Quad4"
]


VerificationTest[
	ImportMesh[FileNameJoin[{$testDir,"Gmsh","Quad8_box.msh"}]],	
	_ElementMesh,
	SameTest->MatchQ,
	TestID->"Gmsh_Quad8"
]


(* ::Subsubsection::Closed:: *)
(*Solid mesh*)


VerificationTest[
	ImportMesh[FileNameJoin[{$testDir,"Gmsh","Tet4_cylinder.msh"}]],	
	_ElementMesh,
	SameTest->MatchQ,
	TestID->"Gmsh_Tet4"
]


VerificationTest[
	ImportMesh[FileNameJoin[{$testDir,"Gmsh","Tet10_cylinder.msh"}]],	
	_ElementMesh,
	SameTest->MatchQ,
	TestID->"Gmsh_Tet10"
]


VerificationTest[
	ImportMesh[FileNameJoin[{$testDir,"Gmsh","Hex8_box.msh"}]],	
	_ElementMesh,
	SameTest->MatchQ,
	TestID->"Gmsh_Hex8"
]


(* ::Subsection::Closed:: *)
(*EndTestSection*)


EndTestSection[]
