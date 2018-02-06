# ImportMesh
Utilities for importing FEM meshes to Mathematica.

Currently supported file formats:
 - .inp (Hypermesh / Abaqus)

## Installation

Download `ImportMesh.wl` file and place it to the folder that you get by evaluating 
`SystemOpen@FileNameJoin[{$UserBaseDirectory, "Applications"}]` in Mathematica.

## Usage

Evaluate:

    Get["ImportMesh`"]
	
	mesh=ImportMesh["path/to/your_mesh_file"]

![screenshot](https://i.imgur.com/OpzA8J5.png "Quad mesh")
	
More information on how to manipulate and visualize `ElementMesh` objects is available in official [documentation](https://reference.wolfram.com/language/FEMDocumentation/tutorial/ElementMeshVisualization.html)
