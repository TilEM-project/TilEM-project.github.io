---
title: Image Processing Pipeline
layout: page
type: task
receives:
    - tile.raw
sends:
    - tile.processed
    - tile.statistics.min_max_mean
    - tile.statistics.focus
    - tile.statistics.histogram
    - tile.minimap
    - tile.transform
    - tile.jpeg
github: AllenInstitute/TEM_graph
toc: true
---

### Introduction

The image processing pipeline is primarily written in C++ with some Python bindings and nodes.
It utilizes the [Intel Thread Building Blocks](https://www.intel.com/content/www/us/en/developer/tools/oneapi/onetbb.html) library for parallelism, and [OpenCV](https://opencv.org/) for image processing.
The overall data-flow is shown in the diagram below.

{% diagram layout=neato %}
from diagrams.programming.language import Cpp, Python
from diagrams.generic.blank import Blank
from diagrams import Node

with Cluster("Intel TBB", graph_attr={"bgcolor": "#FFE0B2"}):
    input = Python("Receive Tile File-path", pin="true", pos="0, 0", href="#receive-tile-filepath")
    load = Cpp("Load Tile", pin="true", pos="0.25, 0", href="#load-tile")
    to_gpu = Cpp("Transfer to GPU", pin="true", pos="0.5, 0", href="#transfer-to-gpu")
    flip = Cpp("Horizontal Flip", pin="true", pos="0.75, 0", href="#flip")
    flatfield = Cpp("Flat-Field Correction", pin="true", pos="1, 0", href="#flat-field-correction")
    clahe = Cpp("CLAHE", pin="true", pos="1.25, 0", href="#clahe")
    min_max_mean = Cpp("Min, Max, Mean", pin="true", pos="1.5, 0.625", href="#min-max-mean")
    output_min_max_mean = Python("Send Min, Max, Mean", pin="true", pos="1.75, 0.625", href="#send-min-max-mean")
    fft = Cpp("FFT", pin="true", pos="1.5, 0.375", href="#fft")
    focus = Cpp("Compute Focus Score", pin="true", pos="1.75, 0.375", href="#focus-score")
    output_focus = Python("Send Focus Score", pin="true", pos="2, 0.375", href="#send-focus-score")
    from_gpu_hist = Cpp("Transfer to CPU Memory", pin="true", pos="1.5, -0.125", href="#histogram-transfer-to-cpu-memory")
    hist = Cpp("Calculate Histogram", pin="true", pos="1.75, -0.125", href="#calculate-histogram")
    save_hist = Cpp("Save Histogram", pin="true", pos="2, -0.125", href="#save-histogram")
    output_hist = Python("Send Histogram File-path", pin="true", pos="2.25, -0.125", href="#send-histogram")
    clone = Cpp("Clone", pin="true", pos="1.5, 0.125", href="#clone")
    downsample = Cpp("Down-sample", pin="true", pos="1.75, 0.125", href="#down-sample")
    from_gpu_jpeg = Cpp("Transfer to CPU Memory", pin="true", pos="2, 0.125", href="#down-sampled-image-to-cpu-memory")
    save_jpeg = Cpp("Save JPEG", pin="true", pos="2.25, 0.125", href="#save-jpeg")
    output_jpeg = Python("Send JPEG", pin="true", pos="2.5, 0.125", href="#send-jpeg-filepath")
    lens_correction = Cpp("Lens Correction", pin="true", pos="1.5, -0.375", href="#lens-correction")
    from_gpu = Cpp("Transfer to CPU Memory", pin="true", pos="1.75, -0.375", href="#transfer-to-cpu-memory")
    save = Cpp("Save Tile", pin="true", pos="2, -0.375", href="#save-tile")
    output = Python("Send Processed Tile Filepath", pin="true", pos="2.25, -0.375", href="#send-tile-filepath")
    matcher = Cpp("Tile Matcher", pin="true", pos="1.5, -0.625", href="#tile-matcher")
    minimap_from_gpu = Cpp("Transfer to CPU Memory", pin="true", pos="1.75, -0.625", href="#minimap-to-cpu-memory")
    save_minimap = Cpp("Save Mini-Map", pin="true", pos="2, -0.625", href="#save-minimap")
    output_minimap = Python("Send Mini-Map", pin="true", pos="2.25, -0.625", href="#send-minimap")
    output_transform = Python("Send Transform", pin="true", pos="1.5, -0.875", href="#send-transform")

input >> load >> to_gpu >> flip >> flatfield >> clahe >> lens_correction >> from_gpu >> save >> output
clahe >> min_max_mean >> output_min_max_mean
clahe >> fft >> focus >> output_focus
clahe >> from_gpu_hist >> hist >> save_hist >> output_hist
lens_correction >> matcher >> minimap_from_gpu >> save_minimap >> output_minimap
matcher >> output_transform
clahe >> clone >> downsample >> from_gpu_jpeg >> save_jpeg >> output_jpeg

input << Edge(label="tile.raw", href="{{ '/topics.html#tile-raw' | relative_url }}") << Blank(pin="true", pos="-0.375, 0")
output_min_max_mean >> Edge(headlabel="tile.statistics.min_max_mean", href="{{ '/topics.html#tile-statistics-min_max_mean' | relative_url }}") >> Blank(pin="true", pos="2.875, 0.625")
output_focus >> Edge(headlabel="tile.statistics.focus", href="{{ '/topics.html#tile-statistics-focus' | relative_url }}") >> Blank(pin="true", pos="2.875, 0.375")
output_jpeg >> Edge(headlabel="tile.jpeg", href="{{ '/topics.html#tile-jpeg' | relative_url }}") >> Blank(pin="true", pos="2.875, 0.125")
output_hist >> Edge(headlabel="tile.statistics.histogram", href="{{ '/topics.html#tile-statistics-histogram' | relative_url }}") >> Blank(pin="true", pos="2.875, -0.125")
output >> Edge(headlabel="tile.processed", href="{{ '/topics.html#tile-processed' | relative_url }}") >> Blank(pin="true", pos="2.875, -0.375")
output_minimap >> Edge(headlabel="tile.minimap", href="{{ '/topics.html#tile-minimap' | relative_url }}") >> Blank(pin="true", pos="2.875, -0.625")
output_transform >> Edge(headlabel="tile.transform", href="{{ '/topics.html#tile-transform' | relative_url }}") >> Blank(pin="true", pos="2.875, -0.875")
{% enddiagram %}

### Functionality

#### Receive Tile Filepath

Uses
: [SubscribeRawTileNode](#subscriberawtilenode)

This node receives the metadata and the path to a raw tile to process from the [message broker]({{ '/broker.html' | relative_url }}) on the [tile.raw]({{ '/topics.html#tile-raw | relative_url}}) topic, and passes the filename to the load tile node.


#### Load Tile

Uses
: [IMReadNode](#imreadnode)

This node receives the metadata and filename, and uses OpenCV to load a tile into CPU memory from SSD based storage.

#### Transfer to GPU

Uses
: [ToGPUNode](#togpunode)

After the tile is loaded into CPU memory, it is transferred into GPU memory for more efficient processing.

#### Flip

Uses
: [FlipNodeGPU](#flipnodegpu)

On the GPU, the tile is horizontally flipped.

#### Flat-Field Correction

Uses:
: [FlatFieldNodeGPU](#flatfieldnodegpu)

The flat-field correction is applied to the tile using brightfield and darkfield images stored on the SSD.
The brightfield and darkfield file modification times are checked during each execution to check if they need to be reloaded.

#### CLAHE

Uses
: [CLAHENodeGPU](#clahenodegpu)

The Contrast Limited Adaptive Histogram Equalization algorithm is applied to the tile.
The resulting image is sent to multiple functions for further analysis, including an [FFT](#fft) for calculating the [focus score](#focus-score), calculating the [minimum, maximum, and mean](#min-max-mean) pixel values, [histogram](#calculate-histogram), [clone](#clone) for [UI]({{ 'ui.html' | relative_url }}) display, and further processing, starting with the [lens correction](#lens-correction).

#### Lens Correction

Uses
: [LensCorrectionNodeGPU](#lenscorrectionnodegpu)

To remove distortion, a lens correction is applied.
This is performed using two images stored on the SSD and reloaded whenever the file modification times are newer than the images stored in memory.
The output is send to the [tile matcher](#tile-matcher) and a [to cpu](#transfer-to-cpu-memory) node for saving to disk.

#### Transfer to CPU Memory

Uses
: [FromGPUNode](#fromgpunode)

In order to save the tile, it must first be transferred to CPU memory.

#### Save Tile

Uses
: [IMWriteNode](#imwritenode)

The processed tile can now be saved to disk.

#### Send Tile Filepath

Uses
: [PublishFileNode](#publishfilenode)

The filepath of the processed tile can now be sent via the [broker]({{ '/broker.html' | relative_url }}) to other services on the [tile.processed]({{ '/topics.html#tile-processed' | relative_url }}) topic.

#### Tile Matcher

Uses
: [MatcherNodeGPU](#matchernodegpu)

This node performs template matching of each tile with its neighbors. It outputs both a minimap image (a down-sampled overview of the entire montage) and the metadata from the matching itself.

#### Send Transform

Uses
: [PublishTransformNode](#publishtransformnode)

This node sends the transform of the matched tile along with other metadata to the [tile.transform]({{ '/topics.html#tile-transform' | relative_url }}) topic via the [broker]({{ '/broker.html' | relative_url }}).

#### Minimap to CPU Memory

Uses
: [FromGPUNode](#fromgpunode)

Before it can be saved, the minimap must be moved to CPU memory.

#### Save Minimap

Uses
: [IMWriteNode](#imwritenode)

The minimap can is saved to disk.

#### Send Minimap

Uses
: [PublishFileNode](#publishfilenode)

The path to the minimap can now be sent via the [broker]({{ '/broker.html' | relative_url }}) on the [tile.minimap]({{ '/topics.html#tile-minimap' | relative_url }}) topic.

#### Min, Max, Mean

Uses
: [MinMaxMeanNodeGPU](#minmaxmeannode)

This node calculates the minimum, maximum, and mean pixel values.

#### Send Min, Max, Mean

Uses
: [PublishMinMaxMeanNode](#publishminmaxmeannode)

This node sends the minimum, maximum, and mean pixel values to other services via the [broker]({{ '/broker.html' | relative_url }}) on the [tile.statistics.min_max_mean]({{ '/topics.html#tile-statistics-min_max_mean' | relative_url }}) topic.

#### FFT

Uses
: [FFTNodeGPU](#fftnodegpu)

This node crops out the center of the tile and computes the Fast Fourier Transform.

#### Focus Score

Uses
: [FocusNodeGPU](#focusnodegpu)

This node uses the FFT data to create a metric for the quality of the focus.

#### Send Focus Score

Uses
: [PublishFocusNode](#publishfocusnode)

This node sends the focus score to other services via the [broker]({{ '/broker.html' | relative_url }}) on the [tile.statistics.focus]({{ '/topics.html#tile-statistics-focus' | relative_url }}) topic.

#### Clone

Uses
: [CloneNodeGPU](#clonenodegpu)

This node copies the image data, since the following node modifies it in-place.

#### Down-sample

Uses
: [ResizeNodeGPU](#resizenodegpu)

This node down-samples the partially processed tile for [UI]({{ '/ui.html' | relative_url }}) display.

#### Down-sampled Image to CPU Memory

Uses
: [FromGPUNode](#fromgpunode)

The down-sampled image must be moved to CPU memory before it can be saved to disk.

#### Save JPEG

Uses
: [IMWriteNode](#imwritenode)

The down-sampled image should be saved using JPEG compression for the [UI]({{ '/ui.html' | relative_url }}).

#### Send JPEG Filepath

Uses
: [PublishFileNode](#publishfilenode)

The path to the JPEG compressed image can be published via the [broker]({{ '/broker.html' | relative_url }}) on the [tile.jpeg]({{ '/topics.html#tile-jpeg' | relative_url }}) topic.

#### Histogram Transfer to CPU Memory

Uses
: [FromGPUNode](#fromgpunode)

Transfer the image to CPU memory before computing the histogram.

#### Calculate Histogram

Uses
: [HistogramNode](#histogramnode)

A small histogram image is created using this node.

#### Save Histogram

Uses
: [IMWriteNode](#imwritenode)

This node saves the histogram to SSD storage.

#### Send Histogram

Uses
: [PublishFileNode](#publishfilenode)

This node sends the filepath to the histogram to other services using the [broker]({{ '/broker.html' | relative_url }}) on the [tile.statistics.histogram]({{ '/topics.html#tile-statistics-histogram' | relative_url }}) topic.

### Nodes

Each node can be provided keyword arguments as described below.
Many non-input nodes accept a `concurrency` argument controlling how many copies of that node may be crated.
Two predefined values are available in the `TEM_graph.consts` module, `serial`, and `unlimited`.
All nodes should also allow their name to be set using the `name` keyword argument.

#### IMReadNode

Language
: C++

Input
: [str_message](#str_message)

Output
: [mat_message](#mat_message)

Arguments
: `name (string) = IMReadNode`: The name for the node.
: `concurrency (int) = unlimited`: The maximum number of copies of the node to run.
: `flags (int) = IMREAD_GRAYSCALE`: OpenCV flags for configuring the underlying OpenCV IMRead function.

This node uses OpenCV to read an image from disk.
The path to the image must be provided in the input message and the output message contains the image data.
Two flags are provided in the `TEM_graph.consts` module, `IMREAD_GRAYSCALE`, and `IMREAD_ANYDEPTH`.

#### IMWriteNode

Language
: C++

Input
: [mat_message](#mat_message)

Output
: [str_message](#str_message)

Arguments
: `name (string) = IMWriteNode`: The name for the node.
: `concurrency (int) = unlimited`: The maximum number of copies of the node to run.
: `output_dir (string) = .`: The directory to save images to.
: `extension (string) = .tiff`: The file extension to use when saving images.
: `params (int vector) = [IMWRITE_TIFF_COMPRESSION, 1]`: The parameters to pass to the underlying OpenCV IMWrite function.

This node uses OpenCV to write an image to disk.
The input message contains the image data, and the output message will contain the path where the image was written.
The image will be saved in the `output_dir` directory with the tile ID from the metadata as the filename and with the extension supplied in the arguments.
The `params` are passed to the underlying OpenCV `IMWrite()` function to control different options, with the defaults here saving an uncompressed TIFF image.
One parameter is defined in `TEM_graph.consts`, which is `IMWRITE_TIFF_COMPRESSION`.

#### ToGPUNode

Language
: C++

Input
: [mat_message](#mat_message)

Output
: [gpu_mat_message](#gpu_mat_message)

Arguments
: `name (string) = ToGPUNode`: The name for the node.
: `concurrency (int) = unlimited`: The maximum number of copies of the node to run.

This node transfers OpenCV image data from CPU memory to GPU memory for further processing.

#### FromGPUNode

Language
: C++

Input
: [gpu_mat_message](#gpu_mat_message)

Output
: [mat_message](#mat_message)

Arguments
: `name (string) = ToGPUNode`: The name for the node.
: `concurrency (int) = unlimited`: The maximum number of copies of the node to run.

This node transfers OpenCV image data from GPU memory to CPU memory for saving etc.

#### CloneNode

Language
: C++

Input
: [mat_message](#mat_message)

Output
: [mat_message](#mat_message)

Arguments
: `name (string) = CloneNode`: The name for the node.
: `concurrency (int) = unlimited`: The maximum number of copies of the node to run.

This node copies the image data to a new location, so that nodes that modify it in-place do not accidentally cause other nodes to receive the modified data.

#### CloneNodeGPU

Language
: C++

Input
: [gpu_mat_message](#gpu_mat_message)

Output
: [gpu_mat_message](#gpu_mat_message)

Arguments
: `name (string) = CloneNode`: The name for the node.
: `concurrency (int) = unlimited`: The maximum number of copies of the node to run.

This node has identical functionality to the [CloneNode](#clonenode), but uses GPU processing.

#### FlipNode

Language
: C++

Input
: [mat_message](#mat_message)

Output
: [mat_message](#mat_message)

Arguments
: `name (string) = FlipNode`: The name for the node.
: `concurrency (int) = unlimited`: The maximum number of copies of the node to run.
: `axis (int) = horizontal`: The axis to flip the image along.

This node flips an image in-place along a provided axis.
The `TEM_graph.consts` module contains three values, `horizontal`, `vertical`, and `both`.

#### FlipNodeGPU

Language
: C++

Input
: [gpu_mat_message](#gpu_mat_message)

Output
: [gpu_mat_message](#gpu_mat_message)

Arguments
: `name (string) = FlipNode`: The name for the node.
: `concurrency (int) = unlimited`: The maximum number of copies of the node to run.
: `axis (int) = horizontal`: The axis to flip the image along.

This node has identical functionality to the [FlipNode](#flipnode), but uses GPU processing.

#### ResizeNode

Language
: C++

Input
: [mat_message](#mat_message)

Output
: [mat_message](#mat_message)

Arguments
: `name (string) = FlipNode`: The name for the node.
: `concurrency (int) = unlimited`: The maximum number of copies of the node to run.
: `scale (double) = 0.5`: The scaling to apply to the image.
: `interpolation (int) = INTER_AREA`: The interpolation method to use.

This node resizes the incoming image in-place.
The `TEM_graph.consts` module contains interpolation constants, `INTER_NEAREST`, `INTER_LINEAR`, `INTER_CUBIC`, `INTER_AREA`, `INTER_LANCZOS4`, `INTER_LINEAR_EXACT`, and `INTER_NEAREST_EXACT`.

#### ResizeNodeGPU

Language
: C++

Input
: [gpu_mat_message](#gpu_mat_message)

Output
: [gpu_mat_message](#gpu_mat_message)

Arguments
: `name (string) = FlipNode`: The name for the node.
: `concurrency (int) = unlimited`: The maximum number of copies of the node to run.
: `scale (double) = 0.5`: The scaling to apply to the image.
: `interpolation (int) = INTER_LINEAR`: The interpolation method to use.

This node has identical functionality to the [DownsampleNode](#downsamplenode), but uses GPU processing.

#### FlatFieldNode

Language
: C++

Input
: [mat_message](#mat_message)

Output
: [mat_message](#mat_message)

Arguments
: `name (string) = FlatFieldNode`: The name for the node.
: `concurrency (int) = unlimited`: The maximum number of copies of the node to run.
: `brightfield_path (string) = brightfield.tiff`: The path to a brightfield image.
: `darkfield_path (string) = darkfield.tiff`: The path to a darkfield image.

This node performs flatfield corrections using the supplied brightfield and darkfield images.
The incoming image is modified in-place.
If the brightfield or darkfield images have a modification date newer then when they were loaded, they are automatically reloaded.

#### FlatFieldNodeGPU

Language
: C++

Input
: [gpu_mat_message](#gpu_mat_message)

Output
: [gpu_mat_message](#gpu_mat_message)

Arguments
: `name (string) = FlatFieldNode`: The name for the node.
: `concurrency (int) = unlimited`: The maximum number of copies of the node to run.
: `brightfield_path (string) = brightfield.tiff`: The path to a brightfield image.
: `darkfield_path (string) = darkfield.tiff`: The path to a darkfield image.

This node has identical functionality to the [FlatFieldNode](#flatfieldnode), but uses the GPU for processing.

#### CLAHENode

Language
: C++

Input
: [mat_message](#mat_message)

Output
: [mat_message](#mat_message)

Arguments
: `name (string) = CLAHENode`: The name for the node.
: `concurrency (int) = unlimited`: The maximum number of copies of the node to run.
: `clipLimit (double) = 2`: The threshold for contrast limiting.
: `tileGridSize (int) = 16`: The number of rows and columns the image will be split into.

This node performs Contrast Limited Adaptive Histogram Equalization in-place on incoming tiles.

#### CLAHENodeGPU

Language
: C++

Input
: [gpu_mat_message](#gpu_mat_message)

Output
: [gpu_mat_message](#gpu_mat_message)

Arguments
: `name (string) = CLAHENode`: The name for the node.
: `concurrency (int) = unlimited`: The maximum number of copies of the node to run.
: `clipLimit (double) = 2`: The threshold for contrast limiting.
: `tileGridSize (int) = 16`: The number of rows and columns the image will be split into.

This node has identical functionality to the [CLAHENode](#clahenode), but uses the GPU for processing.

#### MatcherNode

Language
: C++

Input
: [mat_message](#mat_message)

Output
: [mat_message](#mat_message)

Arguments
: `name (string) = MatcherNode`: The name for the node.

This node must be run single threaded.
It receives incoming image tiles and fits them to the montage matching the `montage_id` in the metadata.
It outputs a minimap (a down-sampled) image of the entire montage, along with the fit metadata.
If the `montage_id` is a zero length string, the tile is a preview tile and no matching should be performed.
In this case, a zero size image should be output.

#### MatcherNodeGPU

Language
: C++

Input
: [gpu_mat_message](#gpu_mat_message)

Output
: [gpu_mat_message](#gpu_mat_message)

Arguments
: `name (string) = MatcherNode`: The name for the node.

This node has identical functionality to the [MatcherNode](#matchernode), but uses the GPU for processing.

#### MinMaxMeanNode

Language
: C++

Input
: [mat_message](#mat_message)

Output
: [int_vec_message](#int_vec_message)

Arguments
: `name (string) = MinMaxMeanNode`: The name for the node.
: `concurrency (int) = unlimited`: The maximum number of copies of the node to run.

This node outputs a vector of the minimum, maximum, and mean pixel values of the input image.

#### MinMaxMeanNodeGPU

Language
: C++

Input
: [gpu_mat_message](#gpu_mat_message)

Output
: [int_vec_message](#int_vec_message)

Arguments
: `name (string) = MinMaxMeanNode`: The name for the node.
: `concurrency (int) = unlimited`: The maximum number of copies of the node to run.

This node has identical functionality to the [MinMaxMeanNode](#minmaxmeannode), but uses the GPU for processing.

#### FFTNode

Language
: C++

Input
: [mat_message](#mat_message)

Output
: [mat_message](#mat_message)

Arguments
: `name (string) = FFTNode`: The name for the node.
: `concurrency (int) = unlimited`: The maximum number of copies of the node to run.
: `dftSize (int) = 256`: The pixel width and height of a square to crop out of the center of the image.

The FFT node calculates the magnitude spectrum of a square section of the incoming tile image that is `dftSize` wide and tall.

#### FFTNodeGPU

Language
: C++

Input
: [gpu_mat_message](#gpu_mat_message)

Output
: [gpu_mat_message](#gpu_mat_message)

Arguments
: `name (string) = FFTNode`: The name for the node.
: `concurrency (int) = unlimited`: The maximum number of copies of the node to run.
: `dftSize (int) = 256`: The pixel width and height of a square to crop out of the center of the image.

This node has identical functionality to the [FFTNode](#fftnode), but uses the GPU for processing.

#### FocusNode

Language
: C++

Input
: [mat_message](#mat_message)

Output
: [float_message](#float_message)

Arguments
: `name (string) = FFTNode`: The name for the node.
: `concurrency (int) = unlimited`: The maximum number of copies of the node to run.
: `dftSize (int) = 256`: The width and height of the incoming FFT magnitude spectrum.
: `frequencyStart (int) = 50`: The lower bound of spatial frequencies to evaluate for focus.
: `frequencyEnd (int) = 251`: The upper bound of spatial frequencies to evaluate for focus.

This node calculates a focus score based using a FFT magnitude spectrum.

#### FocusNodeGPU

Language
: C++

Input
: [gpu_mat_message](#gpu_mat_message)

Output
: [float_message](#float_message)

Arguments
: `name (string) = FFTNode`: The name for the node.
: `concurrency (int) = unlimited`: The maximum number of copies of the node to run.
: `dftSize (int) = 256`: The width and height of the incoming FFT magnitude spectrum.
: `frequencyStart (int) = 50`: The lower bound of spatial frequencies to evaluate for focus.
: `frequencyEnd (int) = 251`: The upper bound of spatial frequencies to evaluate for focus.

This node has identical functionality to the [FocusNode](#focusnode), but uses the GPU for processing.

#### HistogramNode

Language
: C++

Input
: [mat_message](#mat_message)

Output
: [mat_message](#mat_message)

Arguments
: `name (string) = HistogramNode`: The name for the node.
: `concurrency (int) = unlimited`: The maximum number of copies of the node to run.
: `bins (int) = 256`: The number of bins to use when calculating the histogram.
: `width (int) = 512`: The width of the resulting histogram image.
: `height (int) = 200`: The height of the resulting histogram image.

This node creates a histogram plot as an image.

#### SubscribeRawTileNode

Language
: Python

Output
: [str_message](#str_message)

Arguments
: `host (string) = 127.0.0.1`: The host of the message broker.
: `port (int) = 61616`: The port to use to connect to the message broker.
: `username (string) = None`: The username to use when connecting to the message broker.
: `password (string) = None`: The password to use when connecting to the message broker.
: `wait_interval (float) = 0.1`: The amount of time to wait in seconds when a new file is not availble to process.

#### PublishFileNode

Language
: Python

Input
: [str_message](#str_message)

Output
: [str_message](#str_message)

Arguments
: `service (string) = None`: The service name to provide to the broker. Must not be `None`.
: `host (string) = 127.0.0.1`: The host of the message broker.
: `port (int) = 61616`: The port to use to connect to the message broker.
: `username (string) = None`: The username to use when connecting to the message broker.
: `password (string) = None`: The password to use when connecting to the message broker.
: `name (string) = PublishFileNode`: The name for the node.
: `concurrency (int) = unlimited`: The maximum number of copies of the node to run.
: `topic (string) = None`: The topic to publish the file path on. Must not be `None`.

This node publishes the path to a file (usually the output of am [IMWriteNode](#imwritenode)) using the [TEM_comms]({{ '/topics.html' | relative_url }}) library.
The node outputs the input data without modification.

#### PublishFocusNode

Language
: Python

Input
: [float_message](#float_message)

Output
: [float_message](#float_message)

Arguments
: `service (string) = None`: The service name to provide to the broker. Must not be `None`.
: `host (string) = 127.0.0.1`: The host of the message broker.
: `port (int) = 61616`: The port to use to connect to the message broker.
: `username (string) = None`: The username to use when connecting to the message broker.
: `password (string) = None`: The password to use when connecting to the message broker.
: `name (string) = PublishFocusNode`: The name for the node.
: `concurrency (int) = unlimited`: The maximum number of copies of the node to run.

This node publishes the focus score on the [tile.statistics.focus]({{ '/topics.html#tile-statistics-focus' | relative_url }}) topic using the [TEM_comms]({{ '/topics.html' | relative_url }}) library.
The node outputs the input data without modification.

#### PublishMinMaxMeanNode

Language
: Python

Input
: [int_vec_message](#int_vec_message)

Output
: [int_vec_message](#int_vec_message)

Arguments
: `service (string) = None`: The service name to provide to the broker. Must not be `None`.
: `host (string) = 127.0.0.1`: The host of the message broker.
: `port (int) = 61616`: The port to use to connect to the message broker.
: `username (string) = None`: The username to use when connecting to the message broker.
: `password (string) = None`: The password to use when connecting to the message broker.
: `name (string) = PublishMinMaxMeanNode`: The name for the node.
: `concurrency (int) = unlimited`: The maximum number of copies of the node to run.

This node publishes the minimum, maximum, and mean pixel values on the [tile.statistics.min_max_mean]({{ '/topics.html#tile-statistics-min_max_mean' | relative_url }}) topic using the [TEM_comms]({{ '/topics.html' | relative_url }}) library.
The node outputs the input data without modification.

#### PublishTransformNode

Language
: Python

Input
: [mat_message](#mat_message)

Output
: [mat_message](#mat_message)

Arguments
: `service (string) = None`: The service name to provide to the broker. Must not be `None`.
: `host (string) = 127.0.0.1`: The host of the message broker.
: `port (int) = 61616`: The port to use to connect to the message broker.
: `username (string) = None`: The username to use when connecting to the message broker.
: `password (string) = None`: The password to use when connecting to the message broker.
: `name (string) = PublishTransformNode`: The name for the node.
: `concurrency (int) = unlimited`: The maximum number of copies of the node to run.

This node publishes the transform and other matching data from the message metadata on the [tile.transform]({{ '/topics.html#tile-transform' | relative_url }}) topic using the [TEM_comms]({{ '/topics.html' | relative_url }}) library.
The node outputs the input data without modification.

### Message Types

All data types are defined as having some metadata, along with data.
The common metadata includes the following keys:

tile_id (string)
: The unique ID of the tile

montage_id (string)
: The unique ID of the montage

row (int)
: The row in the montage where the tile is located

column (int)
: The column in the montage where the tile if located

overlap (int)
: The number of pixels of overlap between tiles

#### str_message

This message type consists of metadata and a string. This is often used for storing file paths. It has the following keys:

metadata (Metadata)
: The message metadata

data (string)
: The string data

#### mat_message

This message type consists of metadata and OpenCV image data. It has the following keys:

metadata (Metadata)
: The message metadata

data (cv::Mat)
: Image data

#### gpu_mat_message

This message type consists of metadata and OpenCV image data residing on the GPU. It has the following keys:

metadata (Metadata)
: The message metadata

data (cv::cuda::GpuMat)
: Image data on the GPU

#### float_message

This message type consists of metadata and a single floating point value. It has the following keys:

metadata (Metadata)
: The message metadata

data (float)
: A floating point value

#### int_vec_message

This message type consists of metadata and a vector of integers. It has the following keys:

metadata (Metadata)
: The message metadata

data (int vector)
: A vector of integers

### Python API

Pipelines can be defined and run using a simple Python API.
The library for doing so can be imported using,

```python
import TEM_graph
```

A graph can then be created using,

```python
graph = TEM_graph.graph()
```

Nodes are acessible in the `TEM_graph.nodes` submodule.
For example, a CLAHE node could be created using,

```python
CLAHE_node = TEM_graph.nodes.CLAHENode(
    clipLimit=3,
)
```

Alternatively, if this operation should be performed on a GPU, the GPU version of the node could be crated,

```python
CLAHE_node = TEM_graph.nodes.CLAHENodeGPU(
    clipLimit=3,
)
```

> **Please note:**
>
> before this node could be used, the image data would have to be moved to GPU memory using the [ToGPUNode](#togpunode).

Once the desired nodes are created, they can be connected together using the `TEM_graph.make_edge()` function.
For example,

```python
TEM_graph.make_edge(to_GPU_node, CLAHE_node)
```

would connect the output of the `to_GPU_node` to the input of the `CLAHE_node`.
Once the graph is assembled, input nodes must be actived using the `.activate()` method of the input node.

After the graph is running, the `graph.wait_for_all()` function will wait for processing to be complete.
Alternatively, the `graph.cancel()` function can be used to immediately halt data processing.

### Config File

To further streamline pipeline creation, a [YAML](https://yaml.org/) configuration file format was created.
An example the following pipeline could be crated using a configuration file.

{% diagram %}
from diagrams.programming.language import Cpp, Python
from diagrams.generic.blank import Blank
from diagrams import Node

with Cluster("Intel TBB", graph_attr={"bgcolor": "#FFE0B2"}):
    input = Python("SubscribeRawTileNode", href="#subscriberawtilenode")
    load = Cpp("IMReadNode", href="#imreadnode")
    min_max_mean = Cpp("MinMaxMeanNode", href="#minmaxmeannode")
    output_min_max_mean = Python("PublishMinMaxMeanNode", href="#publishminmaxmeannode")
    hist = Cpp("HistogramNode", href="#histogramnode")
    save_hist = Cpp("IMWriteNode", href="imwritenode")
    output_hist = Python("PublishFileNode", href="#publishfilenode")

input >> load >> min_max_mean >> output_min_max_mean
load >> hist >> save_hist >> output_hist
{% enddiagram %}

The configuration file to create this pipeline is:

```yaml
nodes: # All nodes must be defined under this key
  input: # This is the name of the first node
    type: SubscribeRawTileNode # This is the name of the class that instantiates the node
    to: read # The name of the node which should recieve the output of this node
  read:
    type: IMReadNode
    to: # Multiple node names can also be specified
      - histogram
      - min_max_mean
  histogram:
    type: HistogramNode
    to: save
  save:
    type: IMWriteNode
    args: # Keyword arguments can be defined that will be provided to the node when it is initialized
      output_dir: /tmp/
    to: send_histogram
  send_histogram:
    type: PublishFileNode
    args:
      service: publish_histogram
      topic: tile.statistics.histogram
    # The 'to' key is not required
  min_max_mean:
    type: MinMaxMeanNode
    to: send_min_max_mean
  send_min_max_mean:
    type: PublishMinMaxMeanNode
    args:
      service: publish_min_max_mean
```

Once a pipeline configuration file has been written, a command line utility can be used to run the pipeline:

```bash
TEM_graph pipeline.yaml
```
