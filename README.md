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

meshExample =
 URLDownload@
  "https://raw.githubusercontent.com/c3m-labs/ImportMesh/master/Tests/Gmsh/box_H1.msh";
Import[meshExample, "ElementMesh"]["Wireframe"]
```

![example](https://i.stack.imgur.com/IAazP.png "Import base")

Support is also provided for import as a string if the format type of the file is known:

```mathematica

inpText =
  ReadString@
   "https://raw.githubusercontent.com/c3m-labs/ImportMesh/master/Tests/Abaqus/nle1xf4f.inp";
ImportString[inpText, "AbaqusMesh"]["Wireframe"]
```

![example](https://i.stack.imgur.com/4cBAV.png "Import string")

This also allows for loading of assets off the web:

```mathematica

Import[
  "https://raw.githubusercontent.com/c3m-labs/ImportMesh/master/Tests/Elfen/disc_Q1.mes",
  "ElfenMesh"
  ]["Wireframe"]
```

![example](https://i.stack.imgur.com/EqN8o.png "Import web")

Specific elements may also be extracted when the format is known:

```mathematica

ImportString[inpText, {"AbaqusMesh", "Elements"}]

{"Mesh", "MeshNodes", "MeshElements"}
```

```mathematica

ImportString[inpText, {"AbaqusMesh", "MeshNodes"}]

{{0., 1.}, {0., 1.4375}, {0., 1.875}, {0., 2.3125}, {0.,
  2.75}, {0.659994, 0.932966}, {0.742355, 1.34813}, {0.824716,
  1.7633}, {0.907077, 2.17846}, {0.989438, 2.59363}, {1.165,
  0.81283}, {1.3195, 1.18442}, {1.474, 1.55602}, {1.6285,
  1.92761}, {1.783, 2.2992}, {1.53326, 0.649529}, {1.74826,
  0.957066}, {1.96326, 1.2646}, {2.17826, 1.57214}, {2.39326,
  1.87968}, {1.78302, 0.453}, {2.04547, 0.67675}, {2.30791,
  0.9005}, {2.57036, 1.12425}, {2.8328, 1.348}, {1.93252,
  0.233178}, {2.22794, 0.354165}, {2.52335, 0.475152}, {2.81877,
  0.596139}, {3.11419, 0.717125}, {2., 0.}, {2.3125, 0.}, {2.625,
  0.}, {2.9375, 0.}, {3.25, 0.}}

  ```

More information on how to manipulate and visualize `ElementMesh` objects is available in official [documentation](https://reference.wolfram.com/language/FEMDocumentation/tutorial/ElementMeshVisualization.html)

## Contributions

Contributions to ImportMesh package are very welcome. You can open a [new issue](https://github.com/c3m-labs/ImportMesh/issues/new) with bug report or feature request.

These are some things you can help with:

 - Test package with different mesh files
 - Provide sample mesh files from other, not yet supported, software
 - Propose code improvements (style or performance)
