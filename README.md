# ImportMesh
Utilities for importing FEM meshes to Mathematica. Currently supported file formats:

 - .inp ([Abaqus](https://www.3ds.com/products-services/simulia/products/abaqus/))
 - .mes ([Elfen](http://www.rockfieldglobal.com/))
 - .msh ([Gmsh](http://gmsh.info/))
 - .mphtxt ([Comsol](https://www.comsol.com/))

## Installation

Download `ImportMesh.zip` file from [the releases page](https://github.com/c3m-labs/ImportMesh/releases) and extract it to the folder that you get by evaluating
`SystemOpen@FileNameJoin[{$UserBaseDirectory, "Applications"}]` in Mathematica. Then load the package by evaluating ``Get["ImportMesh`"]``.

Alternately run `Get["https://raw.githubusercontent.com/c3m-labs/ImportMesh/master/ImportMesh.wl"]`

## Usage

The only (currently) public function is  `ImportMesh`. It creates `ElementMesh` object from a text file:

    mesh=ImportMesh["path/to/your_mesh_file"];
    mesh["Wireframe"]

![screenshot](https://i.imgur.com/OpzA8J5.png "Quad mesh")

There are also functions in the ``"`Package`"`` subcontext that implement `ImportMesh`.

Similarly, support is added for `Import` registration, so it is possible to import a file as an `"ElementMesh"` and get it to work as expected.

For example:

```mathematica

meshExample = ImportMesh`Package`importMeshExamples["msh"][[1]];
Import[meshExample, "ElementMesh"]["Wireframe"]
```

Support is also provided for import as a string if the format type of the file is known:

```mathematica

inpText = ReadString@ImportMesh`Package`importMeshExamples["inp"][[5]];
ImportString[inpText, "AbaqusMesh"]["Wireframe"]
```

This also allows for loading of assets off the web:

```mathematica

Import["https://raw.githubusercontent.com/c3m-labs/ImportMesh/master/\
Tests/Elfen/disc_Q1.mes", "ElfenMesh"
  ]["Wireframe"]
```

More information on how to manipulate and visualize `ElementMesh` objects is available in official [documentation](https://reference.wolfram.com/language/FEMDocumentation/tutorial/ElementMeshVisualization.html)

## Contributions

Contributions to ImportMesh package are very welcome. You can open a [new issue](https://github.com/c3m-labs/ImportMesh/issues/new) with bug report or feature request.

These are some things you can help with:

 - Test package with different mesh files
 - Provide sample mesh files from other, not yet supported, software
 - Propose code improvements (style or performance)
