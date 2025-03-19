import SimpleITK as sitk
import tifffile as tiff
import numpy as np

def load_tiff_stack(file_path):
    # Load the stack and return the data and its dtype.
    stack = tiff.imread(file_path)
    return stack, stack.dtype

def save_tiff_stack(stack, file_path, dtype):
    # Cast to the original type before saving.
    if dtype == np.uint16:
        stack = stack.astype(np.uint16)
    elif dtype == np.float32:  # Assuming float32 for 32-bit images.
        stack = stack.astype(np.float32)
    
    # If the image is a multi-channel composite with 2 channels (not RGB),
    # we reshape it to ImageJ hyperstack format: (T, Z, C, Y, X)
    if stack.ndim == 3 and stack.shape[-1] == 2:
        # stack shape is (height, width, 2); move channel axis to front:
        stack = np.moveaxis(stack, -1, 0)  # now (2, height, width)
        # Add T and Z dimensions (both =1) so that the final shape is (1, 1, 2, height, width)
        stack = stack[np.newaxis, np.newaxis, ...]
        tiff.imwrite(file_path, stack, imagej=True)
    # For 3-channel images (e.g. RGB) we want to preserve the (Y, X, C) shape.
    elif stack.ndim == 3 and stack.shape[-1] == 3:
        tiff.imwrite(file_path, stack, metadata={'axes': 'YXC'})
    else:
        tiff.imwrite(file_path, stack)

def register_images(fixed_image, moving_image):
    # Convert images to SimpleITK format.
    fixed_image_sitk = sitk.GetImageFromArray(fixed_image)
    moving_image_sitk = sitk.GetImageFromArray(moving_image)

    # Initialize the registration method.
    registration_method = sitk.ImageRegistrationMethod()
    registration_method.SetMetricAsMattesMutualInformation(numberOfHistogramBins=500)
    registration_method.SetOptimizerAsRegularStepGradientDescent(
        learningRate=1.0,
        minStep=1e-5,
        numberOfIterations=1000,
        gradientMagnitudeTolerance=1e-8
    )
    
    # Set the transformation model.
    registration_method.SetInitialTransform(sitk.TranslationTransform(fixed_image_sitk.GetDimension()))
    registration_method.SetInterpolator(sitk.sitkBSpline)
    
    # Execute the registration.
    final_transform = registration_method.Execute(
        sitk.Cast(fixed_image_sitk, sitk.sitkFloat32),
        sitk.Cast(moving_image_sitk, sitk.sitkFloat32)
    )

    # Apply the transformation to the moving image.
    moving_resampled = sitk.Resample(
        moving_image_sitk,
        fixed_image_sitk,
        final_transform,
        sitk.sitkLinear,
        0.0,
        moving_image_sitk.GetPixelID()
    )
    
    return sitk.GetArrayFromImage(moving_resampled)

def align_tiff_stack(input_path, output_path):
    data, dtype = load_tiff_stack(input_path)
    
    # Detect if the loaded data is a multi-channel image.
    # If data.ndim == 3, check whether the channels are the first axis or the last axis.
    multi_channel = False
    if data.ndim == 3:
        if data.shape[0] in [2, 3]:
            multi_channel = True
            # Convert from (channels, height, width) to (height, width, channels)
            data = np.transpose(data, (1, 2, 0))
        elif data.shape[-1] in [2, 3]:
            multi_channel = True

    if multi_channel:
        # Register channels to each other using the first channel as the reference.
        ref_channel = data[..., 0]
        aligned_channels = [ref_channel]
        for ch in range(1, data.shape[-1]):
            moving_channel = data[..., ch]
            aligned_channel = register_images(ref_channel, moving_channel)
            aligned_channels.append(aligned_channel)
        # Reassemble into a multi-channel image with shape (height, width, channels)
        aligned = np.stack(aligned_channels, axis=-1)
    else:
        # Otherwise, assume the data is a time-series or z-stack.
        ref_frame = data[0]
        aligned_frames = [ref_frame]
        for i in range(1, len(data)):
            aligned_frame = register_images(ref_frame, data[i])
            aligned_frames.append(aligned_frame)
        aligned = np.array(aligned_frames)
    
    save_tiff_stack(aligned, output_path, dtype)

