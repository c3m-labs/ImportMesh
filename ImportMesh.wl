(* ::Package:: *)

(* ::Section::Closed:: *)
(*Header comments*)


(* :Title: ImportMesh *)
(* :Context: ImportMesh` *)
(* :Author: Matevz Pintar, C3M, Slovenia *)
(* :Summary: Utilities for importing FEM meshes from other software. *)
(* :Copyright: C3M d.o.o., 2018 *)
(* :Package Version: 0.2.0 *)
(* :Mathematica Version: 11.2 *)


(* ::Section::Closed:: *)
(*Begin package*)


(* Mathematica FEM functionality is needed. *)
BeginPackage["ImportMesh`",{"NDSolve`FEM`"}];


(* ::Section::Closed:: *)
(*Messages*)


ImportMesh::usage="ImportMesh[\"file\"] imports data from mesh file, returning a ElementMesh object.";


(* ::Section::Closed:: *)
(*Code*)


(* Begin private context *)
Begin["`Private`"];


(* 
Implementation for each mesh file format has its own private subcontext (e.g. ImportMesh`Private`Gmsh`).
This is because low level helper functions (e.g. getNodes) are doing same things differentl< for different formats.
Some common private functions are implemented in ImportMesh`Private` context and inside other subcontext they 
to be called by their full name.
*)


(* ::Subsection::Closed:: *)
(*Common functions*)


convertToElementMesh[nodes_,allElements_]:=Module[
	{sDim,point,line,surface,solid,head,meshElementsOpt},
	
	(* Spatial dimensions of the problem. *)
	sDim=Last@Dimensions[nodes];
	
	point=Cases[allElements,PointElement[__],2];
	line=Cases[allElements,LineElement[__],2];
	surface=Cases[allElements,TriangleElement[__]|QuadElement[__],2];
	solid=Cases[allElements,TetrahedronElement[__]|HexahedronElement[__],2];
	
	(* If number of dimensions is 3 but no solid elements are specified, 
	then we use ToBoundaryMesh to create ElementMesh. And similarly for 2 dimensions. *)
	If[
		TrueQ[(sDim==3&&solid=={})||(sDim==2&&surface=={})]
		,
		head=ToBoundaryMesh;
		meshElementsOpt={}
		,
		head=ToElementMesh;
		meshElementsOpt={"MeshElements"->Switch[sDim,1,line,2,surface,3,solid]}
	];
	(* "Coordinates" and "MeshElements" are the only required fields. 
	Order of rules given seems important. Also use of Sequence is a little hack, because Nothing didn't work.
	Possible bug?  *)	
	head[
		"Coordinates"->nodes,
		Sequence@@meshElementsOpt,
		"BoundaryElements"->Switch[sDim,1,point,2,line,3,surface],
		"PointElements"->point,
		"CheckIncidentsCompletness"->False,
		"CheckIntersections"->False,
		"DeleteDuplicateCoordinates"->False
	]//Quiet
]


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


ImportMesh`Private`importAbaqusMesh[file_,scale_:1]:=Module[
	{list,nodes,allElements},
	
	list=ReadList[file,String];
	nodes=getNodes[list];
	allElements=getElements[list];
	
	ImportMesh`Private`convertToElementMesh[nodes,allElements]
]


End[]; (* "`Abaqus`" *)


(* ::Subsection::Closed:: *)
(*Comsol (.mphtxt)*)


(* Begin private context *)
Begin["`Comsol`"];


(* ::Subsubsection::Closed:: *)
(*Helper functions*)


getNumber[list_List,key_]:=ToExpression@Flatten@StringCases[list,x__~~key:>x];


getPosition[list_List,key_]:=ToExpression@Flatten@Position[list,key]


getNodes[list_]:=Module[
	{noNodes,start,listOfStrings},
	noNodes=getNumber[list," # number of mesh points"];
	start=getPosition[list,"# Mesh point coordinates"];
	listOfStrings=Join@@MapThread[
		Take[list,{#1+1,#1+#2}]&,
		{start,noNodes}
	];
	Map[
		Internal`StringToDouble,
		StringSplit@listOfStrings,
		{2}
	]
]


takeLines[list_List,start_Integer,noLines_Integer]:=ToExpression@StringSplit@Take[list,{start+1,start+noLines}]


switchType={
	"vtx"->PointElement,
	"edg"|"edg2"->LineElement,
	"tri"|"tri2"->TriangleElement,"quad"|"quad2"->QuadElement,
	"tet"|"tet2"->TetrahedronElement,"hex"|"hex2"->HexahedronElement
};


modification["quad",nodes_]:=nodes[[{1,2,4,3}]]
modification["quad2",nodes_]:=nodes[[{1,2,4,3,5,8,9,6}]]
modification["hex",nodes_]:=nodes[[{1,2,4,3,5,6,8,7}]]
modification["hex2",nodes_]:=nodes[[{1,2,4,3,5,6,8,7,9,12,13,10,23,26,27,24,14,16,22,20}]]
modification["tet2",nodes_]:=nodes[[{1,2,3,4,5,7,6,9,10,8}]]
modification[type_,nodes_]:=nodes


getElements[list_,type_,length_,startElement_,startDomain_]:=With[
	{head=type/.switchType},
	{
	head[
		(* +1 because node counting starts from 0 *)
		(modification[type,#]&/@takeLines[list,startElement,length])+1,
		Flatten@takeLines[list,startDomain,length]
	]
	}
]


(* ::Subsubsection::Closed:: *)
(*Main function*)


ImportMesh`Private`importComsolMesh[file_,scale_:1]:=Module[
	{list,sdim,nodes,types,lengths,startElements,startMarkers,allElements},
	
	list=ReadList[file,String];
	types=Flatten@StringCases[list,Whitespace~~x__~~" # type name":>x];
	lengths=getNumber[list," # number of elements"];
	startElements=getPosition[list,"# Elements"];
	(* I think both "Domains"  and "Geometric entity indices" can be considered as markers. *)
	startMarkers=getPosition[list,"# Domains"|"# Geometric entity indices"];

	nodes=getNodes[list];
	allElements=MapThread[
		getElements[list,#1,#2,#3,#4]&,
		{types,lengths,startElements,startMarkers}
	];
	
	ImportMesh`Private`convertToElementMesh[nodes,allElements]
]



End[]; (* "`Comsol`" *)


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


ImportMesh`Private`importGmshMesh[file_,scale_:1]:=Module[
	{list,nodes,markers,allElements},
	
	list=ReadList[file,String];
	nodes=getNodes[list];
	markers=getMarkers[list];
	allElements=getElements[list];
	
	ImportMesh`Private`convertToElementMesh[nodes,allElements]
]


End[]; (* "`Gmsh`" *)


(* ::Subsection::Closed:: *)
(*Elfen (.mes)*)


(* Begin private context *)
Begin["`Elfen`"];


(* ::Subsubsection::Closed:: *)
(*Helper functions*)


getPosition[list_List,key_]:=ToExpression@Flatten@Position[list,key]


getTypes[list_]:=Module[
	{start,n},
	start=First@getPosition[list,"element_type_numbers"];
	n=ToExpression@list[[start+1]];
	
	ToExpression/@list[[start+2;;start+1+n]]
]


getNodes[list_]:=Module[
	{start,dim,n},
	(* We assume all nodes are listed only on one place in the file. *)
	start=First@getPosition[list,"coordinates"];
	dim=ToExpression@list[[start+1]];
	n=ToExpression@list[[start+2]];
	
	Partition[
		Internal`StringToDouble/@list[[start+3;;start+3+(n*dim)-1]],
		dim
	]
]


$elfenTypes={
	21->{TriangleElement,{1,2,3}},
	22->{QuadElement,{1,2,3,4}},
	23->{TriangleElement,{1,3,5,2,4,6}},
	24|25->{QuadElement,{1,3,5,7,2,4,6,8}},
	31->{TetrahedronElement,{1,2,3,4}},
	33->{HexahedronElement,{1,2,3,4,5,6,7,8}},
	34->{TetrahedronElement,{1,3,5,10,2,4,6,8,9,7}},
	36->{HexahedronElement,{1,3,5,7,13,15,17,19,2,4,6,8,14,16,18,20,9,10,11,12}}
};


processElements[list_,startLine_Integer,type_Integer]:=Module[
	{nNodes,nElms,connectivity,head,reordering},
	
	nNodes=ToExpression@list[[startLine+1]];
	nElms=ToExpression@list[[startLine+2]];
	
	connectivity=Partition[
		ToExpression/@list[[startLine+3;;startLine+3+(nNodes*nElms)-1]],
		nNodes
	];
	{head,reordering}=type/.$elfenTypes;
	
	head[connectivity[[All,reordering]] ]
]


getElements[list_]:=Module[
	{startPositions,types},
	
	startPositions=getPosition[list,"element_topology"];
	types=getTypes[list];
	
	MapThread[
		processElements[list,#1,#2]&,
		{startPositions,types}
	]
]


(* ::Subsubsection::Closed:: *)
(*Main function*)


ImportMesh`Private`importElfenMesh[file_,scale_:1]:=Module[
	{list,nodes,markers,allElements},
	
	list=ReadList[file,
		Word,
		RecordLists->True,
		RecordSeparators -> {"#","\"","{","}","*","\n"}
	]//Flatten;
	nodes=getNodes[list];
	allElements=getElements[list];
	
	ImportMesh`Private`convertToElementMesh[nodes,allElements]
]


End[]; (* "`Elfen`" *)


(* ::Subsection::Closed:: *)
(*Import all file types*)


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
		"mes",importElfenMesh[file,scale],
		"mphtxt",importComsolMesh[file,scale],
		"msh",importGmshMesh[file,scale],
		_,Message[ImportMesh::nosup];$Failed
	]
]


(* ::Section::Closed:: *)
(*End package*)


End[]; (* "`Private`" *)


EndPackage[];
