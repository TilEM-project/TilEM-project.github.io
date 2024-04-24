---
layout: topics
title: Topics
topics:
    tile.raw:
        description: This message is sent whenever a new tile is ready.
        payload:
            tile_id:
                type: string
                description: The tile ID.
                example: 69005602-15b0-4407-bf5b-4bddd6629141
            montage_id:
                type: string
                description: The montage ID. If `null`, the tile is for UI display purposes only.
                example: 4330c7cf-e45b-4950-89cf-82dc0f815fe9
            path:
                type: string
                description: The path where the raw tile is stored.
                example: /storage/raw/69005602-15b0-4407-bf5b-4bddd6629141.tiff
            row:
                type: int
                description: The row of the montage where the tile was imaged.
                example: 5
            column:
                type: int
                description: The column of the montage where the tile was imaged.
                example: 24
            overlap:
                type: float
                description: The percent overlap of the tiles expressed as a decimal number.
                example: 0.1
    tile.statistics.min_max_mean:
        description: This message contains simple statistics about a processed tile.
        payload:
            tile_id:
                type: string
                description: The tile ID.
                example: 69005602-15b0-4407-bf5b-4bddd6629141
            min:
                type: int
                description: The minimum pixel value.
                example: 5
            max:
                type: int
                description: The maximum pixel value.
                example: 249
            mean:
                type: int
                description: The mean pixel value.
                example: 187
    tile.statistics.histogram:
        description: This message contains a path to a histogram saved to disk.
        payload:
            tile_id:
                type: string
                description: The tile ID.
                example: 69005602-15b0-4407-bf5b-4bddd6629141
            path:
                type: string
                description: The path where the histogram is stored.
                example: /storage/histogram/69005602-15b0-4407-bf5b-4bddd6629141.tiff
    tile.statistics.focus:
        description: This message contains the focus score.
        payload:
            tile_id:
                type: string
                description: The tile ID.
                example: 69005602-15b0-4407-bf5b-4bddd6629141
            min:
                type: float
                description: The focus score.
                example: 2.67
    tile.processed:
        description: This message contains the path to a fully processed tile.
        payload:
            tile_id:
                type: string
                description: The tile ID.
                example: 69005602-15b0-4407-bf5b-4bddd6629141
            path:
                type: string
                description: The path where the processed tile is stored.
                example: /storage/processed/69005602-15b0-4407-bf5b-4bddd6629141.tiff
    tile.jpeg:
        description: This message contains the path to a downsampled and JPEG compressed tile primarily for UI use.
        payload:
            tile_id:
                type: string
                description: The tile ID.
                example: 69005602-15b0-4407-bf5b-4bddd6629141
            path:
                type: string
                description: The path where the compressed tile is stored.
                example: /storage/jpeg/69005602-15b0-4407-bf5b-4bddd6629141.jpeg
    tile.minimap:
        description: This message contains the path to low resolution map image of the full montage.
        payload:
            tile_id:
                type: string
                description: The tile ID.
                example: 69005602-15b0-4407-bf5b-4bddd6629141
            path:
                type: string
                description: The path where the minimap is stored.
                example: /storage/minimap/69005602-15b0-4407-bf5b-4bddd6629141.jpeg
    tile.transform:
        description: This message contains a transform between the base coordinate system of the montage and the tile to move it into the correct location in the montage.
        payload:
            tile_id:
                type: string
                description: The tile ID.
                example: 69005602-15b0-4407-bf5b-4bddd6629141
            rotation:
                type: float
                description: The rotation in radians of the tile for it to fit in the montage.
                example: 3.14
            x:
                type: float
                description: The X location of the tile for it to fit in the montage in units of pixels.
                example: 1019172
            y:
                type: float
                description: The Y location of the tile for it to fit in the montage in units of pixels.
                example: 1918840
    camera.settings:
        description: This message is used to modify camera settings.
        payload:
            exposure:
                type: float or null
                description: The camera exposure in microseconds, or `null` if the value should remain unchanged.
                example: 1000.0
            width:
                type: int or null
                description: The image width, or `null` if the value should remain unchanged.
                example: 10000
            height:
                type: int or null
                description: The current image height, or `null` if the value should remain unchanged.
                example: 10000
    camera.command:
        description: This message signals that an image should be acquired by the camera.
        payload:
            tile_id:
                type: string
                description: The tile ID.
                example: 69005602-15b0-4407-bf5b-4bddd662914
    camera.image:
        description: This message contains a path to the most recently acquired image.
        payload:
            tile_id:
                type: string
                description: The tile ID.
                example: 69005602-15b0-4407-bf5b-4bddd662914
            path:
                type: string
                description: The path to the image on disk.
                example: /storage/raw/69005602-15b0-4407-bf5b-4bddd6629141.tiff
    camera.status:
        description: This message is regularly published and includes various status information about the camera.
        payload:
            exposure:
                type: float
                description: The current exposure time in microseconds.
                example: 1000.0
            width:
                type: int
                description: The current image width.
                example: 10000
            height:
                type: int
                description: The current image height.
                example: 10000
            temp:
                type: float
                description: The current temperature of the camera.
                example: 25.8
            target_temp:
                type: float
                description: The target temperature for temperature control.
                example: 20.0
            device_name:
                type: string
                description: The camera device name.
                example: Ximea Camera
            device_model_id:
                type: int
                description: The model ID of the camera.
                example: 0
            sensor_model_id:
                type: int
                description: The model ID of the camera sensor.
                example: 0
            device_sn:
                type: string
                description: The camera serial number.
                example: alkdsjfalkj
            sensor_sn:
                type: string
                description: The serial number of the camera sensor.
                example: aljewoia
---

The topics are listed below.