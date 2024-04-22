---
title: Image Processing Pipeline
layout: page
---

The image processing pipeline is primarily written in C++ with some Python bindings.
It utilizes the [Intel Thread Building Blocks](https://www.intel.com/content/www/us/en/developer/tools/oneapi/onetbb.html) library for parallelism, and [OpenCV](https://opencv.org/) for image processing.

{% diagram %}
from diagrams.programming.language import Cpp, Python

with Cluster("Intel TBB", graph_attr={"bgcolor": "#FFE0B2"}):
    input = Python("Recieve Tile Filepath", pin="true", pos="0, 0", href="#recieve-tile-filepath")
    load = Cpp("Load Tile", pin="true", pos="0.25, 0", href="#load-tile")
    to_gpu = Cpp("Transfer to GPU", pin="true", pos="0.5, 0", href="#transfer-to-gpu")
    flip = Cpp("Horizontal Flip", pin="true", pos="0.75, 0", href="#flip")
    flatfield = Cpp("Flat-Field Correction", pin="true", pos="1, 0", href="#flat-field-correction")
    clahe = Cpp("CLAHE", pin="true", pos="1.25, 0", href="#clahe")
    min_max_mean = Cpp("Min, Max, Mean", pin="true", pos="1.5, 0.375", href="#min-max-mean")
    output_min_max_mean = Python("Send Min, Max, Mean", pin="true", pos="1.75, 0.375", href="#send-min-max-mean")
    fft = Cpp("FFT", pin="true", pos="1.5, 0.125", href="#fft")
    focus = Cpp("Compute Focus Score", pin="true", pos="1.75, 0.125", href="#focus-score")
    output_focus = Python("Send Focus Score", pin="true", pos="2, 0.125", href="#send-focus-score")
    from_gpu_hist = Cpp("Transfer to CPU Memory", pin="true", pos="1.5, -0.125")
    hist = Cpp("Calculate Histogram", pin="true", pos="1.75, -0.125", href="#calculate-histogram")
    save_hist = Cpp("Save Histogram", pin="true", pos="2, -0.125", href="#save-histogram")
    output_hist = Python("Send Histogram Filepath", pin="true", pos="2.25, -0.125", href="#send-histogram-filepath")
    lens_correction = Cpp("Lens Correction", pin="true", pos="1.5, -0.375", href="#lens-correction")
    from_gpu = Cpp("Transfer to CPU Memory", pin="true", pos="1.75, -0.375", href="#transfer-to-cpu-memory")
    save = Cpp("Save Tile", pin="true", pos="2, -0.375", href="#save-tile")
    output = Python("Send Processed Tile Filepath", pin="true", pos="2.25, -0.375", href="#send-tile-filepath")

input >> load >> to_gpu >> flip >> flatfield >> clahe >> lens_correction >> from_gpu >> save >> output
clahe >> min_max_mean >> output_min_max_mean
clahe >> fft >> focus >> output_focus
clahe >> from_gpu_hist >> hist >> save_hist >> output_hist
{% enddiagram %}

### Recieve Tile Filepath

This node recieves the metadata for a tile to process from the [message broker](/broker.html), and passes the filename to the load image node.

### Load Tile

This node recieves the metadata and filename, and uses openCV to load a tile into CPU memory from SSD based storage.

### Transfer to GPU

After the tile is loaded into CPU memory, it is transfered into GPU memory for more efficient processing.

### Flip

On the GPU, the tile is horizontally flipped.

### Flat-Field Correction

The flat-field correction is applied to the tile using brightfield and darkfield images stored on the SSD.
The brightfield and darkfield file modification times are checked during each execution to check if they need to be reloaded.

### CLAHE

The Contrast Limited Adaptive Histogram Equilization algorithm is applied to the tile.
The resulting image is sent to multiple functions for further analysis, including an [FFT](#fft) for calculating the [focus score](#focus-score), calculating the [minimum, maximum, and mean](#min-max-mean) pixel values, and [histogram](#calculate-histogram).

### Lens Correction

To remove distortion, a lens correction is applied.
This is performed using two images stored on the SSD and reloaded whenever the file modification times are newer than the images stored in memory.

### Transfer to CPU Memory

In order to save the tile, it must first be transferred to CPU memory.

### Save Tile

The processed tile can now be saved to disk.

### Send Tile Filepath

The filepath of the processed tile can now be sent via the [broker](/broker.html) to other services.

### Min, Max, Mean

This node calculates the minimum, maximum, and mean pixel values.

### Send Min, Max, Mean

This node sends the minimum, maximum, and mean pixel values to other services via the [broker](/broker.html).

### FFT

This node crops out the center of the tile and computes the Fast Fourier Transform.

### Focus Score

This ndoe uses the FFT data to create a metric for the quality of the focus.

### Send Focus Score

This node sends the focus score to other services via the [broker](/broker.html)

### Calculate Histogram

A small histogram image is created using this node.

### Save Histogram

This node saves the histogram to SSD storage.

### Send Histogram

This node sends the filepath to the histogram to other services using the [broker](/broker.html).