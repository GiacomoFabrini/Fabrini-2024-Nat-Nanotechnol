function action(input, output, filename) {
	// open file in folder
    open(input + filename);
    // debug printout of the filename to monitor progress
	print("Opening file: ", filename); 
	// Get essential info about the image you just opened - name and directory
	image_dir = getDirectory("image");
	image_name = getTitle();
	// select the image window
	selectWindow(image_name);
	// Denoise
	run("Gaussian Blur...", "sigma=3");
	// Subtract background
	run("Subtract Background...", "rolling=10 sliding");
	// Threshold - Li, auto
	setAutoThreshold("Li dark no-reset");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	saveAs("TIFF", output+"mask_"+image_name+".tif");
	close();
}

// Change with absolute paths to image and desired output directories, respectively
input = "/ABSOLUTE/PATH/TO/IMAGES/";
output = "/ABSOLUTE/OUTPUT/PATH/Masks_Li/"

list = getFileList(input);
for (i = 0; i < list.length; i++){
	if (indexOf(list[i], "BF") == -1) { 
        action(input, output, list[i]);
    }
}
