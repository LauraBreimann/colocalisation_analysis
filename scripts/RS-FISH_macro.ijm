//===============================================================================
// Macro to detect spots in the images using RS-FISH
// - Laura Breimann - adapted from Ella Bahry 
//===============================================================================

// This macro script runs the radial symmetry (RS) FIJI plug-in on all the images in all the sub-directories of the defined dir
// After finding the best parameters using the RS plugin GUI interactive mode on one example image,
// You can run this macro script on the entire dataset.
// Just change the directory path, and the values of the parameters in the begining of the script

// You can run this script either in the ImageJ GUI or headless (also from cluster) using this command (linux):
// fiji_dir_path/ImageJ-linux64 --headless --run /path/to/this/script/RS_macro.ijm &> /path/to/where/you/want/yourlogfile.log

// The detection result table will be saved to the same directory as each image it was calculated for.

// Path the tif files to be processed, searches all sub-directories.
dir = getDirectory("Select a directory containing images to detect structures in.");

//////// Define RS parameters: //////////

anisotropy = 0.8040; 			// anisotropy coefficient
sigmaDoG = 1.5; 			// sigma
thresholdDoG = 0.007; // intensity threshold
supportRadius = 3; 			// support radius
inlierRatio = 0.1			// min inlier ratio
maxError = 1.5; 		// max error
intensityThreshold=0;  		// spot intensity threshold
imMin=0;   					// min image intentisy
imMax=5000;  				// max image intensity



setBatchMode(true);

///////////////////////////////////////////////////


walkFiles(dir);

// Find all files in subdirs:
function walkFiles(dir) {
	list = getFileList(dir);
	for (i=0; i<list.length; i++) {
		if (endsWith(list[i], "/"))
		   walkFiles(""+dir+list[i]);

		// If image file
		else  if (endsWith(list[i], ".tif")) 
		   processImage(dir, list[i]);
	}
}


function processImage(dirPath, imName) {
	
	open("" + dirPath + imName);

	// save result as csv file 
	results_csv_path = "" + dirPath + imName + ".csv";
	
	
	
	parameterString = "image=" + imName + 
	" mode=Advanced" +
	" anisotropy=" + anisotropy + 
	" robust_fitting=RANSAC" + 
	" use_anisotropy" +
	" image_min=" + imMin + 
	" image_max=" + imMax + 
	" sigma=" + sigmaDoG + 
	" threshold=" + thresholdDoG + 
	" support=" + supportRadius + 
	" min_inlier_ratio=" + inlierRatio + 
	" max_error=" + maxError + 
	" background=[No background subtraction]" +
	" spot_intensity_threshold=" + intensityThreshold + 
	" results_file=[" + results_csv_path + "]";
	

	// write in log the paramters used
	print(parameterString);

	startTime = getTime();
	run("RS-FISH", parameterString);
	

	// Close all windows:
	run("Close All");	
	while (nImages>0) { 
		selectImage(nImages); 
		close(); 
    } 
} 
