(* ::Package:: *)

(* ::Section::Closed:: *)
(*Header comments*)


(* :Title: ImportMesh *)
(* :Context: ImportMesh` *)
(* :Author: Matevz Pintar, C3M, Slovenia *)
(* :Summary: Utilities for importing FEM meshes from other software. *)
(* :Copyright: C3M d.o.o., 2018 *)
(* :Package Version: 0.1.0 *)
(* :Mathematica Version: 11.2 *)


(* ::Section::Closed:: *)
(*Begin package*)


(* Mathematica FEM functionality is needed. *)
BeginPackage["ImportMesh`",{"NDSolve`FEM`"}];


(* ::Section::Closed:: *)
(*Messages*)


ImportMesh::usage="ImportMesh[\"file\"] imports data from mesh file, returning a ElementMesh object.";


(* Implementation for each software has its own private subcontext, but their main function
 should be defined in public context, so they can be found by the other public functions. *)
 (* TODO: Find out a better way to use separate subcontexts for each implementation. *)
importAbaqusMesh;
importGmshMesh


(* ::Section::Closed:: *)
(*Code*)


(* ::Subsection::Closed:: *)
(*Abaqus (.inp)*)


(* Begin private context *)
Begin["`Abaqus`"];


(* ::Subsubsection::Closed:: *)
(*Helper functions*)


getPosition[list_List,key_]:=ToExpression@Flatten@Position[list,s_String/;StringStartsQ[s,key]]


getElementInfo[list_,line_Integer]:=First[
	StringCases[Part[list,line],"*ELEMENT,TYPE="~~type__~~",ELSET="~~m__:>{type,m}],
	{}
]


getNodes[list_]:=Module[
	{start,listOfStrings},
	(* We assume all nodes are listed only on one place in the file. *)
	start=First@getPosition[list,"*NODE"];
	(* Collect lines until another symbol "*" appears. *)
	listOfStrings=StringSplit[
		StringDelete[" "]@TakeWhile[Drop[list,start],(StringPart[#,1]=!="*")&],
		","
	];
	Map[
		Internal`StringToDouble,
		listOfStrings[[All,2;;]],
		{2}
	]
]


$abaqusTypes={
	Alternatives["S3","S3R"]->TriangleElement,
	Alternatives["S4","S4R"]->QuadElement,
	Alternatives["C3D4","C3D4H"]->TetrahedronElement,
	Alternatives["C3H8","C3D8H","C3D8R"]->HexahedronElement
};


processElements[list_,startLine_Integer]:=Module[
	{listOfStrings,type,connectivity},
	listOfStrings=StringSplit[
		StringDelete[" "]@TakeWhile[Drop[list,startLine],(StringPart[#,1]=!="*")&],
		","
	];
	(* For now we ignore element markers (2nd position) *)
	type=First@getElementInfo[list,startLine]/.$abaqusTypes;
	connectivity=Map[
		ToExpression,
		listOfStrings[[All,2;;]],
		{2}
	];
	
	type[connectivity]
]


getElements[list_]:=Module[
	{startPositions},
	startPositions=getPosition[list,"*ELEMENT"];
	processElements[list,#]&/@startPositions
]


(* ::Subsubsection::Closed:: *)
(*Main function*)


importAbaqusMesh::msg="`1`";

importAbaqusMesh[file_,scale_:1]:=Module[
	{list,nodes,sdim,markers,allElements,point,line,surface,solid},
	
	list=ReadList[file,String];
	nodes=getNodes[list];
	(* Spatial dimensions of the problem. *)
	sdim=Last@Dimensions[nodes];
	allElements=getElements[list];


	point=Cases[allElements,PointElement[__],2];
	line=Cases[allElements,LineElement[__],2];
	surface=Cases[allElements,TriangleElement[__]|QuadElement[__],2];
	solid=Cases[allElements,TetrahedronElement[__]|HexahedronElement[__],2];
	
	(* If number of dimensions is 3 but no solid elements are specified, 
	then we use ToBoundaryMesh to create ElementMesh. And similarly for 2 dimensions. *)
	If[
		TrueQ[(sdim==3&&solid=={})||(sdim==2&&surface=={})],
		ToBoundaryMesh[
			"Coordinates"->nodes,
			"BoundaryElements"->Switch[sdim,1,point,2,line,3,surface],
			"PointElements"->point,
			"CheckIncidentsCompletness"->False,
			"CheckIntersections"->False,
			"DeleteDuplicateCoordinates"->False
		]//Quiet
		,
		ToElementMesh[
			(* "Coordinates" and "MeshElements" are the only required fields. 
			Order of rules given seems important. Possible bug?  *)
			"Coordinates"->nodes,
			"MeshElements"->Switch[sdim,1,line,2,surface,3,solid],
			"BoundaryElements"->Switch[sdim,1,point,2,line,3,surface],
			"PointElements"->point,
			"CheckIncidentsCompletness"->False,
			"CheckIntersections"->False,
			"DeleteDuplicateCoordinates"->False
	]//Quiet
	]
]


End[]; (* "`Abaqus`" *)


(* ::Subsection::Closed:: *)
(*Gmsh (.msh)*)


(* Begin private context *)
Begin["`Gmsh`"];


(* ::Subsubsection::Closed:: *)
(*Helper functions*)


getStartPosition[list_List,key_]:=ToExpression@First[Flatten@Position[list,key],$Failed]


getNumber[list_List,key_]:=ToExpression@Part[list,getStartPosition[list,key]+1];


getNodes[list_]:=Module[
	{noNodes,start},
	start=getStartPosition[list,"$Nodes"];
	noNodes=ToExpression@Part[list,start+1];
	Map[
		Internal`StringToDouble,
		Rest/@StringSplit@Take[list,{start+2,start+1+noNodes}],
		{2}
	]
]


getMarkers[list_]:=Module[
	{start,noEntites},
	start=getStartPosition[list,"$PhysicalNames"];
	(* In case there are no markers specified return $Failed *)
	If[start===$Failed,Return[$Failed]];
	start=start+1;
	noEntites=ToExpression@Part[list,start];
	(* {dimension, integer name, string name} *)
	ToExpression@StringSplit@Take[list,{start+1,start+noEntites}]
]


(* {Head, order, noNodes, reordering} *)
elementData={
	1->{LineElement,1,2,{1,2}},
	2->{TriangleElement,1,3,{1,2,3}},
	3->{QuadElement,1,4,{1,2,3,4}},
	4->{TetrahedronElement,1,4,{1,2,3,4}},
	5->{HexahedronElement,1,8,{1,2,3,4,5,6,7,8}},
	8->{LineElement,2,3,{1,2,3}},
	9->{TriangleElement,2,6,{1,2,3,4,5,6}},
	11->{TetrahedronElement,2,10,{1,4,2,3,8,10,5,9,6,7}},
	15->{PointElement,1,1,{1}},
	16->{QuadElement,2,8,{1,2,3,4,5,6,7,8}},
	17->{HexahedronElement,2,20,{1,2,3,4,5,6,7,8,9,12,17,10,18,11,19,20,13,16,14,15}},
	_->$Failed
};


Clear[restructure]
restructure[list_]:=Block[
	{head,order,noNodes,nodes,noMarkers,markers,reordering},
	{head,order,noNodes,reordering}=list[[1,1]]/.elementData;
	noMarkers=list[[1,2]];
	nodes=Part[list,All,(3+noMarkers);;];
	markers=Part[list,All,3];
	head[nodes[[All,reordering]],markers]
]


getElements[list_]:=Module[
	{start,noEntites,raw},
	start=getStartPosition[list,"$Elements"]+1;
	noEntites=ToExpression@Part[list,start];
	raw=Rest/@ToExpression@StringSplit@Take[list,{start+1,start+noEntites}];
	
	restructure/@(Values@GroupBy[raw,First])
]


(* ::Subsubsection::Closed:: *)
(*Main function*)


importGmshMesh::msg="`1`";

importGmshMesh[file_,scale_:1]:=Module[
	{list,nodes,sdim,markers,allElements,point,line,surface,solid},
	
	list=ReadList[file,String];
	nodes=getNodes[list];
	(* Spatial dimensions of the problem. *)
	sdim=Last@Dimensions[nodes];
	
	markers=getMarkers[list];
	allElements=getElements[list];
	
	
	point=Cases[allElements,PointElement[__],2];
	line=Cases[allElements,LineElement[__],2];
	surface=Cases[allElements,TriangleElement[__]|QuadElement[__],2];
	solid=Cases[allElements,TetrahedronElement[__]|HexahedronElement[__],2];
	
	(* If number of dimensions is 3 but no solid elements are specified, 
	then we use ToBoundaryMesh to create ElementMesh. And similarly for 2 dimensions. *)
	If[
		TrueQ[(sdim==3&&solid=={})||(sdim==2&&surface=={})],
		ToBoundaryMesh[
			"Coordinates"->nodes,
			"BoundaryElements"->Switch[sdim,1,point,2,line,3,surface],
			"PointElements"->point,
			"CheckIncidentsCompletness"->False,
			"CheckIntersections"->False,
			"DeleteDuplicateCoordinates"->False
		]//Quiet
		,
		ToElementMesh[
			(* "Coordinates" and "MeshElements" are the only required fields. 
			Order of rules given seems important. Possible bug?  *)
			"Coordinates"->nodes,
			"MeshElements"->Switch[sdim,1,line,2,surface,3,solid],
			"BoundaryElements"->Switch[sdim,1,point,2,line,3,surface],
			"PointElements"->point,
			"CheckIncidentsCompletness"->False,
			"CheckIntersections"->False,
			"DeleteDuplicateCoordinates"->False
	]//Quiet
	]
]


End[]; (* "`Gmsh`" *)


(* ::Subsection::Closed:: *)
(*Import all file types*)


Begin["`Private`"];


ImportMesh::nosup="Mesh file extension is currently not supported.";

Options[ImportMesh]={"ScaleSize"->1};

ImportMesh[file_,opts:OptionsPattern[]]:=Module[
	{scale},
	If[Not@TrueQ@FileExistsQ[file],Message[ImportMesh::noopen,file];Return[$Failed]];
	scale=N@OptionValue["ScaleSize"];
	
	(*PrintTemporary["Converting mesh..."];*)
	Switch[
		FileExtension[file],
		"inp",importAbaqusMesh[file,scale],
		"msh",importGmshMesh[file,scale],
		_,Message[ImportMesh::nosup];$Failed
	]
]


End[];(* "`Private`" *)


(* ::Section::Closed:: *)
(*End package*)


EndPackage[];
