# ImportMesh
Utilities for importing FEM meshes to Mathematica. Currently supported file formats:

 - .inp ([Hypermesh](https://www.altairhyperworks.com/product/HyperMesh) / Abaqus)
 - .mes ([Elfen](http://www.rockfieldglobal.com/))
 - .msh ([Gmsh](http://gmsh.info/))
 - .mphtxt ([Comsol](https://www.comsol.com/))

## Installation

Download `ImportMesh.zip` file from [the releases page](https://github.com/c3m-labs/ImportMesh/releases) and extract it to the folder that you get by evaluating 
`SystemOpen@FileNameJoin[{$UserBaseDirectory, "Applications"}]` in Mathematica. Then load the package by evaluating ``Get["ImportMesh`"]``.

## Usage

The only (currently) avaliable function is  `ImportMesh`. It creates `ElementMesh` object from a text file:

    mesh=ImportMesh["path/to/your_mesh_file"];
    mesh["Wireframe"]

![screenshot](https://i.imgur.com/OpzA8J5.png "Quad mesh")
	
More information on how to manipulate and visualize `ElementMesh` objects is available in official [documentation](https://reference.wolfram.com/language/FEMDocumentation/tutorial/ElementMeshVisualization.html)

## Contributions

Contributions to ImportMesh package are very welcome. You can open a [new issue](https://github.com/c3m-labs/ImportMesh/issues/new) with bug report or feature request.

These are some things you can help with:

 - Test package with different mesh files
 - Provide sample mesh files from other, not yet supported, software
 - Propose code improvements (style or performance)
