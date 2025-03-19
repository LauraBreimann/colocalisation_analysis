//=================================================================================
// Creates black and white time series from TIF images with similar base names

// Laura Breimann
//=================================================================================

// Parameters:
// inputDir - The directory containing the single channel images.

#@ File (label = "Select a folder of single channel images", style = "directory") inputDir
#@ File (label = "Output directory", style = "directory") outputDir


// Get list of files in the input directory
listFiles = getFileList(inputDir);

// Initialize arrays to hold groups of related images
imageGroups = newArray();
baseNames = newArray();
groupCount = 0;

// Grouping images by their base name without the numeric suffix
for (i = 0; i < listFiles.length; i++) {
    fileName = listFiles[i];
    if (endsWith(fileName, ".tif")) {
        baseName = basenameWithoutSuffix(fileName);

        // Check and register the baseName
        idx = indexInArray(baseNames, baseName);
        if (idx == -1) {
            // New baseName group
            baseNames[groupCount] = baseName;
            imageGroups[groupCount] = fileName;
            groupCount++;
        } else {
            // Append to the existing group
            imageGroups[idx] = imageGroups[idx] + "," + fileName;
        }
    }
}

// Process each group to create composite images
for (i = 0; i < groupCount; i++) {
    baseName = baseNames[i];
    filesForGroup = imageGroups[i];
    fileList = split(filesForGroup, ",");
    if (lengthOf(fileList) > 1) { // Ensure there is more than one image for a time series
        openAsStack(fileList, inputDir, baseName);
        run("Re-order Hyperstack ...", "channels=[Slices (z)] slices=[Channels (c)] frames=[Frames (t)]");
        //run("Grays");
        saveAsTimeSeries(baseName, inputDir);
    }
}

// Utility functions
function basenameWithoutSuffix(fileName) {
    underscoreIndex = lastIndexOf(fileName, "_");
    if (underscoreIndex != -1) {
        return substring(fileName, 0, underscoreIndex);
    }
    return fileName;
}

function indexInArray(arr, val) {
    for (i = 0; i < lengthOf(arr); i++) {
        if (arr[i] == val) {
            return i;
        }
    }
    return -1;
}

function openAsStack(files, inputDir, baseName) {
    for (j = 0; j < lengthOf(files); j++) {
        open(inputDir + File.separator + files[j]);
    }
    run("Images to Stack", "name=[] title=[] use");
    rename(baseName); // Rename the window to the base name
    selectWindow(baseName);
}


function saveAsTimeSeries(baseName, inputDir) {
    if (!File.exists(outputDir)) {
        File.makeDirectory(outputDir);
    }
    savePath = outputDir + File.separator + baseName + ".tif";
    saveAs("Tiff", savePath);
    print("Saved: " + savePath);
    close();
}