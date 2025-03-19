//=================================================================================
// Opens TIF images, extracts the first Z slice, adjusts brightness, and saves it
// as a 16-bit TIFF in a specified output directory
// - Modified for TIF files from PicoQuant
// Laura Breimann
//=================================================================================

// Parameters:
// inputDir - The full path to the input directory containing the TIF files.
// outputDir - The full path to the output directory where processed TIFs will be saved.
// suffix - The suffix of input files to filter (e.g., tif).

// User input
#@ File (label = "Select a folder", style = "directory") inputDir
#@ File (label = "Output directory", style = "directory") outputDir
#@ String (label = "Input file suffix", value = "tif") suffix

// Ensure the Bio-Formats plugin is installed and up to date.

listFiles = getFileList(inputDir);
for (i = 0; i < listFiles.length; i++) {
    // Filter files based on suffix
    if (endsWith(listFiles[i], "." + suffix)) {
        inputFilePath = inputDir + File.separator + listFiles[i];
        processTifFile(inputFilePath, outputDir, suffix);
    }
}

function processTifFile(filePath, outputDir, suffix) {
    open(filePath);
    imageTitle = getTitle();

    // Get image dimensions
    getDimensions(width, height, channels, slices, frames);

    // Check and extract the first slice if more than one slice exists
    if (slices >= 2) {
        run("Make Substack...", "slices=1");
    }
    
    // Adjust brightness and contrast if necessary (customize as needed)
    //run("Enhance Contrast", "saturated=0.35");

    // Convert to 16-bit
    //run("16-bit");

    // Save output
    baseName = substring(imageTitle, 0, indexOf(imageTitle, "." + suffix));
    outputFilePath = outputDir + File.separator + baseName + ".tif";
    saveAs("Tiff", outputFilePath);
    print("Saved: " + outputFilePath);
    
    // Close the current image to free memory
    close();
    close();
}