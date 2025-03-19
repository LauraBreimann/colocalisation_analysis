import os
import tifffile as tiff
import numpy as np

def split_multichannel_images(input_dir, output_dir):
    # Create output folders for channels C1, C2, and C3.
    channels = ['C1', 'C2', 'C3']
    for ch in channels:
        os.makedirs(os.path.join(output_dir, ch), exist_ok=True)
    
    # Iterate through all files in the input directory.
    for filename in os.listdir(input_dir):
        if filename.lower().endswith(('.tif', '.tiff')):
            file_path = os.path.join(input_dir, filename)
            print("Processing:", file_path)
            try:
                img = tiff.imread(file_path)
            except Exception as e:
                print(f"Error reading {file_path}: {e}")
                continue

            # Check the dimensions and adjust channel order if necessary.
            # If the image is 3D and the first dimension is small (2 or 3) and less than the last dimension,
            # assume it's channels-first and transpose to channels-last.
            if img.ndim == 3:
                if img.shape[0] in [2, 3] and img.shape[0] < img.shape[-1]:
                    img = np.transpose(img, (1, 2, 0))
            
            # Now check if the image has 2 or 3 channels in the last dimension.
            if img.ndim == 3 and img.shape[-1] in [2, 3]:
                n_channels = img.shape[-1]
                for ch in range(n_channels):
                    # Extract the single-channel image (2D).
                    channel_data = img[..., ch]
                    # Define output folder and filename.
                    out_folder = os.path.join(output_dir, f'C{ch+1}')
                    base_name = os.path.splitext(filename)[0]
                    out_filename = f"{base_name}_C{ch+1}.tif"
                    out_path = os.path.join(out_folder, out_filename)
                    # Save the single-channel image.
                    tiff.imwrite(out_path, channel_data)
                    print(f"Saved channel {ch+1} to {out_path}")
            else:
                print(f"File {filename} is not a multi-channel image (2 or 3 channels). Skipping.")

if __name__ == "__main__":
    # Change these paths to the appropriate directories on your system.
    input_directory = "path/to/input_folder"
    output_directory = "path/to/output_folder"
    
    split_multichannel_images(input_directory, output_directory)
