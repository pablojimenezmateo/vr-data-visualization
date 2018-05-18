# VR data visualization

This project aims to bring an open source tool for people to visualize data in a virtual 3D environment.

![ScreenShot](https://github.com/pjimenezmateo/vr-data-visualization/raw/master/data/Screenshot.png)

Features
---------------------

* You can drag, drop and resize the data using an HTC Vive controller
* Poor man's camera, so you can develop without a VR headset
* Hooked signals, you only need to copy the Template scene in the scenes folder and all the signals will be hooked to it
* 3 examples implemented

Using the examples
-----------------------

You will need the awesome [Godot game engine](https://godotengine.org/).
Open the project and instance Countries, Raytracer or MatlabImport as a child of the ARVRNode.

Examples
-----------------------

**Countries**: Is a simple scatter plot with data from the Wikipedia, using GDP, debt and population as axis, the color of the sphere corresponds to the continent it is in and the size of the sphere corresponds with the minimum wage.

**MatlabImport**: An example of a [Surfaceplot](https://es.mathworks.com/help/matlab/ref/surf.html) exported from Matlab to Godot (is the one in the example of the documentation).

**RayTracer**: A raytracer scenario, the yellow sphere represents the router and if you touch the ground you can see all the paths that get to that point.

Videos of the examples can be found on the following links: [Countries](https://www.youtube.com/watch?v=IMrD1QjOqII), [MatlabImporter](https://www.youtube.com/watch?v=53G5QqK0LJE) and [Raytracer](https://www.youtube.com/watch?v=uInngPAg3Aw).

Controls
-----------------------

Use only one controller.

**Trigger**: While pressed the data will move and rotate according to the controller position.

**Trackpad**: Press it to toggle on and off the scale mode. When on, slide your finger up on the trackpad to make the data bigger or down to make it smaller.

Licensing
---------
Copyright 2018 Pablo Jiménez Mateo

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.