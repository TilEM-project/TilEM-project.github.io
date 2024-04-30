---
layout: topics
title: Topics
github: AllenInstitute/TEM_comms
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
            focus:
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
            device_sn:
                type: string
                description: The camera serial number.
                example: alkdsjfalkj
    stage.aperture.command:
        description: This message is used to instruct the hardware to move to a specific aperture.
        payload:
            aperture_id:
                type: int or null
                description: The desired aperture ID, or `null` to remain unchanged.
                example: 000008
            calibrate:
                type: bool
                description: A flag to denote that the hardware should be calibrated.
                example: false
    stage.aperture.status:
        description: This message contains status information about the aperture changing hardware.
        payload:
            current_aperture:
                type: int
                description: The ID of the current aperture.
                example: 000007
            callibrated:
                type: bool
                description: A flag to denote if the hardware is calibrated.
                example: true
            error:
                type: string
                description: The current error message from the device, or an empty string if no error.
                example: ""
    stage.rotation.command:
        description: This message is used to instruct the hardware to rotate to a given tilt angle.
        payload:
            angle_x:
                type: float or null
                description: The desired tilt angle about the X axis in radians, or `null` for the angle to remain unchanged.
                example: 0.524
            angle_y:
                type: float or null
                description: The desired tilt angle about the Y axis in radians, or `null` for the angle to remain unchanged.
                example: 0.0
            calibrate:
                type: bool
                description: A flag to denote that the hardware should be calibrated.
                example: false
    stage.rotation.status:
        description: This message contains status information about the tilt imaging hardware.
        payload:
            angle_x:
                type: float
                description: The current tilt angle about the X axis in radians.
                example: 0.523
            angle_y:
                type: float
                description: The current tilt angle about the Y axis in radians.
                example: -0.001
            in_motion:
                type: bool
                description: A flag which is true when at least one actuator is in motion.
                example: true
            error:
                type: string
                description: The current error message from the device, or an empty string if no error.
                example: ""
    stage.motion.command:
        description: This message is used to instruct the stages to move to a the sample to a given location.
        payload:
            x:
                type: int or null
                description: The desired X stage location in nanometers, or `null` for the location to remain unchanged.
                example: 750176
            y:
                type: int or null
                description: The desired Y stage location in nanometers, or `null` for the location to remain unchanged.
                example: 531087
            calibrate:
                type: bool
                description: A flag to denote that the hardware should be calibrated.
                example: false
    stage.motion.status:
        description: This message contains status information about the aperture changing hardware.
        payload:
            x:
                type: int
                description: The current X stage location in nanometers.
                example: 750254
            y:
                type: int
                description: The current Y stage location in nanometers.
                example: 531054
            in_motion:
                type: bool
                description: A flag which is true when at least one actuator is in motion.
                example: true
            error:
                type: string
                description: The current error message from the device, or an empty string if no error.
                example: ""
    buffer.status:
        description: This message contains status information about the tile upload buffer.
        payload:
            queue_length:
                type: int
                description: The number of tiles queued for upload.
                example: 11
            free_space:
                type: int
                description: The amount of free disk space for storing tiles in bytes.
                example: 549755813888
            upload_rate:
                type: int
                description: The current data upload rate in bits-per-second.
                example: 53687091200
    scope.command:
        description: This message contains commands to the microscope.
        payload:
            focus:
                type: int or null
                description: The desired focus value, or `null` to keep current focus.
                example: 19385
            aperture:
                type: int or null
                description: The desired aperture, or `null` to keep current aperture.
                example: 3
            mag:
                type: int or null
                description: The desired magnification level, or `null` to keep current magnification.
                example: 3000
    scope.status:
        description: This message contains status information about the microscope.
        payload:
            focus:
                type: int
                description: The current focus value.
                example: 17493
            aperture:
                type: int
                description: The current aperture.
                example: 2
            mag:
                type: int
                description: The current magnification level.
                example: 5000
            vacuum:
                type: float
                description: The current vacuum level in Torr.
                example: 1.27e-6
            tank_voltage:
                type: int
                description: The current HV tank voltage in kilovolts.
                example: 120
---

The topics are listed below, and implemented in the library linked above.