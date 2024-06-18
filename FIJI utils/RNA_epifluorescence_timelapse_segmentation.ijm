function action(input, output, filename) {
	// open file in folder
    open(input + filename);
    // debug printout of the filename to monitor progress, can be disabled
	print("Opening file: ", filename); 
	// Get essential info about the image you just opened - name and directory
	image_dir = getDirectory("image");
	image_name = getTitle();
	// select image window
	selectWindow(image_name);
	// If needed: bin image (here 2x2)
	run("Bin...", "x=2 y=2 z=1 bin=Average");
	// Adjustments - ONLY ENABLE IF NEEDED
	n = nSlices;  // go to last slice
	setSlice(n);  // set last slice as current slice, only really needed if NOT using normalisation
	// Enhance contrast, either with or without normalisation (only choose one)
	run("Enhance Contrast...", "saturated=0.20 normalize process_all");  // with normalisation (to detect small condensates in early timepoints)
	//run("Enhance Contrast...", "saturated=0.20 process_all use");  // without normalisation
	// Set scale to calibrate px to um
	run("Set Scale...", "distance=1.5426 known=1 unit=micron");  // change with pixel-to-micron conversion factor for your objective lens! (for DiMicheleLab 20x lens: 3.0852 unbinned)
	// Denoising -- Gaussian Blur
	run("Gaussian Blur...", "sigma=1 stack");
	run("Minimum...", "radius=1 stack");
	// Background subtraction - sliding paraboloid, smoothing disabled
	run("Subtract Background...", "rolling=50 sliding disable stack");
	// Background subtraction, second step: needed in DROPLETS samples
	//run("Subtract Background...", "rolling=1 sliding disable stack");
	// Thresholding:
	setAutoThreshold("Li dark no-reset stack"); // select Li = min cross-entropy for BULK
	// setAutoThreshold("Otsu dark no-reset stack");  // select Otsu for DROPLETS
	setOption("BlackBackground", false);
	// Convert to binary mask - choose correct option matching the one above
	run("Convert to Mask", "method=Li background=Dark create");  // select Li = min cross-entropy for BULK
	// run("Convert to Mask", "method=Otsu background=Dark create");  // select Otsu for DROPLETS
	// If needed: perform watershed (here disabled)
	//run("Watershed", "stack");
	// Finally, perform particle analysis
	run("Analyze Particles...", "size=10-Infinity show=[Overlay Masks] display clear stack");
	// Save segmentation mask in TIFF
	saveAs("TIFF", output+"Masks/"+image_name+".tif");
	// Save particle analysis results in CSV format
	saveAs("Results", output+"Results_"+image_name+".csv");
	// Close down everything before moving down to next image
	selectWindow(image_name);
	close("*");
}

input = "/CHANGE/TO/ABSOLUTE/INPUT/PATH/";
output = "/CHANGE/TO/ABSOLUTE/OUTPUT/PATH"

// Declaring measurement settings before the loop -- no need to do this multiple times!
run("Set Measurements...", "area mean standard min centroid center perimeter fit shape feret's integrated median skewness kurtosis area_fraction stack redirect=None decimal=5");

list = getFileList(input);
for (i = 0; i < list.length; i++){
        action(input, output, list[i]);
}
