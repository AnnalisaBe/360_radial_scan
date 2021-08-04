
//Author: Annalisa Bellandi
//Faulkner lab, John Innes Centre

///This macro allows for:
///Radial scan at 360 degree around a central point

/// Main steps:
/// The users selects the central point 
/// 100 radii are created departing from that starting point, distributed around the 360 degree
/// fluorescence intensity along the rays is saved for each time step

//===============================================================================================================================================================================//

//BEFORE STARTING:

//0) open image
//1) run stackreg 
//2) check number of starting slide
//3) check you are in the correct directory
//4) select window of movie

//====================================================  ++++   start of the script    ++++  =====================================================================================//
 
//select image and duplicate to make measures
dir = getInfo("image.directory");// get the image directory
print(dir)
imageTitle=getTitle; //get the image name
run("Duplicate...", "duplicate"); //duplicate the entire stack for measurements
measuredImageTitle="dup"+imageTitle; //add the starting "dup" to the original image title
rename(measuredImageTitle);//rename it
selectWindow(measuredImageTitle); //select the duplicate image to measure

//get pixel size
getPixelSize(unit, pixelWidth, pixelHeight);
print("Current image pixel width = " + pixelWidth + " " + unit +".");
pxw = pixelWidth;
print(pxw);
linelenght= 700/pxw;
print(linelenght);

//check planeTimings.txt https://docs.openmicroscopy.org/bio-formats/5.7.3/users/imagej/
run("Bio-Formats Macro Extensions"); //to get metadata info 
selectWindow(imageTitle); //have to return to the original because I didn't save duplicate in folder
id = getInfo("image.directory") + getInfo("image.filename");
Ext.setId(id);
Ext.getImageCount(imageCount);
deltaT = newArray(nSlices); //create array with vector of time points
selectWindow(measuredImageTitle); //I can return to the duplicate..

waitForUser("make point in the centre");
getSelectionCoordinates(x, y);
 xc = x[0];
 yc = y[0];

run("Clear Results");

//Loop0: repeats the loop1 and 2 for each time point (slice) - the loops starts like this: for(k=0; k<=nSlices; k++){ , insert slice in place of 0
for(k=1; k<=nSlices; k++){
	setSlice(k);
	no=k-1; // arrays start at zero, so I subtract 1.
	Ext.getPlaneTimingDeltaT(deltaT[no], no); //....
	t=deltaT[no];
	print(t);
    
//loop1: for each angle, creates a line (radius) and get values along the lenght (profile)
  for(i=0; i<=100; i+=1){
	 alfa = i*2*PI/100;
	 makeLine(xc,yc,xc+linelenght*sin(alfa),yc+linelenght*cos(alfa));
	 Overlay.addSelection("green", 2);
     profile = getProfile();

//Loop2: for each  profile, saves the values of the profile and the position of the values along the lenght in a table
     for(j=0; j<profile.length; j++){
    	 setResult(i, j+linelenght*(k-1), profile[j]);
    	 setResult("frame", j+linelenght*(k-1), k);
    	 setResult("t", j+linelenght*(k-1), t); 
    	 //once you got the time, put t as a value in place of k: setResult("t", j+50*(k-1), t);
    	 setResult("d", j+linelenght*(k-1), j*pxw); // this should give the space in um in my d column instead fo the pxl n
       
        }
    }
}

title_without_extension = substring(imageTitle, 0, lengthOf(imageTitle)-4);
saveAs("Results", dir + title_without_extension + ".csv");


waitForUser("Happy with the scan?");
close();
