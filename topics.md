---
layout: topics
title: Topics
type: task
github: AllenInstitute/TEM_comms
assigned: Cameron
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
                description: The montage ID. If a zero length string, the tile is for UI display purposes only.
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
                type: int
                description: The number of pixels of overlap between tiles.
                example: 512
    tile.statistics.min_max_mean:
        description: This message contains simple statistics about a processed tile.
        payload:
            tile_id:
                type: string
                description: The tile ID.
                example: 69005602-15b0-4407-bf5b-4bddd6629141
            montage_id:
                type: string
                description: The montage ID. If a zero length string, the tile is for UI display purposes only.
                example: 4330c7cf-e45b-4950-89cf-82dc0f815fe9
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
            montage_id:
                type: string
                description: The montage ID. If a zero length string, the tile is for UI display purposes only.
                example: 4330c7cf-e45b-4950-89cf-82dc0f815fe9
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
            montage_id:
                type: string
                description: The montage ID. If a zero length string, the tile is for UI display purposes only.
                example: 4330c7cf-e45b-4950-89cf-82dc0f815fe9
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
            montage_id:
                type: string
                description: The montage ID. If a zero length string, the tile is for UI display purposes only.
                example: 4330c7cf-e45b-4950-89cf-82dc0f815fe9
            path:
                type: string
                description: The path where the processed tile is stored.
                example: /storage/processed/69005602-15b0-4407-bf5b-4bddd6629141.tiff
    tile.jpeg:
        description: This message contains the path to a down-sampled and JPEG compressed tile primarily for UI use.
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
            montage_id:
                type: string
                description: The montage ID. If a zero length string, the tile is for UI display purposes only.
                example: 4330c7cf-e45b-4950-89cf-82dc0f815fe9
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
                example: XIMEA Camera
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
            calibrated:
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
            mag_mode:
                type: string or null
                description: The desired magnification mode. Must be either `"LM"`, `"MAG1"`, `"MAG2"`, or `null` to keep the current mode. Must be provided if `mag` is not `null`.
                example: MAG1
            mag:
                type: int or null
                description: The desired magnification level, or `null` to keep current magnification. Must be provided if `mag_mode` is not `null`.
                example: 3000
            spot_size:
                type: int or null
                description: The desired spot size, or `null` to keep the current spot size.
                example: 123
            beam_offset:
                type: "[int, int] or null"
                description: The desired beam offset location, or `null` to keep the current beam offset.
                example: "[54, 23]"
            screen:
                type: string
                description: Command the screen to raise or lower. Must be either `up` or `down`.
                example: up
    scope.status:
        description: This message contains status information about the microscope.
        payload:
            focus:
                type: int
                description: The current focus value.
                example: 17493
            aperture:
                type: str or null
                description: The current aperture state, or `null` if unknown.
                example: 2
            mag_mode:
                type: string
                description: The current magnification mode.
                example: MAG1
            mag:
                type: int
                description: The current magnification level.
                example: 5000
            tank_voltage:
                type: int
                description: The current HV tank voltage in kilovolts.
                example: 120
            spot_size:
                type: int
                description: The current spot size value.
                example: 284
            beam_offset:
                type: "[int, int]"
                description: The current beam offset location.
                example: "[293, 172]"
    ui.setup:
        description: This message contains values that can be set on the UI setup pane.
        payload:
            conch_owner:
                type: string
                description: The conch owner name, or `null` to keep current value.
                example: Kim
            auto_focus:
                type: bool
                description: Set to `true` to initiate the auto-focus method.
                example: false
            auto_exposure:
                type: bool
                description: Set to `true` to initiate the auto-exposure method.
                example: false
            lens_correction:
                type: bool
                description: Set to `true` to begin a lens correction montage.
                example: false
            acquire_brightfield:
                type: bool
                description: Set to `true` to initiate the brightfield collection method.
                example: false
            acquire_darkfield:
                type: bool
                description: Set to `true` to initiate the darkfield collection method.
                example: false
    ui.edit:
        description: This message contains values that can be set on the UI edit pane.
        payload:
            roi_id:
                type: string
                description: The unique ID for the ROI.
                example: ROI_1
            roi_pos_x:
                type: int
                description: The X location of the ROI centroid in nanometers.
                example: 1928493
            roi_pos_y:
                type: int
                description: The Y location of the ROI centroid in nanometers.
                example: 199384
            roi_width:
                type: int
                description: The width of the ROI in nanometers.
                example: 1728840
            roi_height:
                type: int
                description: The height of the ROI in nanometers.
                example: 873527
            roi_angle:
                type: float
                description: The angle of the ROI relative to the X axis in radians.
                example: 1.37
    ui.run:
        description: This message contains values that can be set on the UI run pane.
        payload:
            session_id:
                type: string or null
                description: The unique identifier of the imaging session. Required if `montage` is `true`.
                example: MN18_RMOp_5f
            grid_first:
                type: int or null
                description: The first grid to image. Required if `montage` is `true`.
                example: 42
            grid_last:
                type: int or null
                description: The last grid to image. Required if `montage` is `true`.
                example: 57
            montage:
                type: bool
                description: Set to `true` to begin montaging.
                example: false
            abort_now:
                type: bool
                description: Set to `true` to immediately abort montaging.
                example: false
            abort_at_end:
                type: bool
                description: Set to `true` to abort montaging at end of current montage.
                example: false
            resume:
                type: bool
                description: Set to `true` to continue resuming montaging after an error has occured.
                example: true
    montage.start:
        description: This message contains basic information about the montage before the first tile is captured.
        payload:
            montage_id:
                type: string
                description: The montage ID.
                example: 4330c7cf-e45b-4950-89cf-82dc0f815fe9
            num_tiles:
                type: int
                description: The number of tiles in the montage.
                example: 8372
    montage.finished:
        description: This message indicated that all tiles of a montage have been captured and includes various metadata about the montage.
        payload:
            montage_id:
                type: string
                description: The montage ID.
                example: 4330c7cf-e45b-4950-89cf-82dc0f815fe9
            num_tiles:
                type: int
                description: The number of tiles in the montage.
                example: 8372
            roi:
                type: string
                description: The ID of the ROI that was montaged.
                example: 273274
            specimen:
                type: string
                description: The ID of the specimen that was montaged.
                example: 192372L
            metadata:
                type: dict or list
                description: The metadata of the montage.
                example: "{\"session_id\": \"MN18_RMOp_5f\", \"roi\": \"392171\"}"
    qc.status:
        description: This message indicates the state of tile/montage QC metrics.
        payload:
            state:
                type: string
                description: The state of the QC. Must be either "GOOD" if imaging should continue, "STOP_AT_END" if imaging should be stopped at then end of the montage, or "STOP_NOW" if imaging should be stopped immediately.
                example: STOP_AT_END
---

Messages in this system are sent and received using our [Pigeon](https://pypi.org/project/pigeon-client/) library.
The message definitions for each topic are listed below, and implemented in the library linked above.
These are also available on the Python package index as [`pigeon-tem-comms`](https://pypi.org/project/pigeon-tem-comms/).
