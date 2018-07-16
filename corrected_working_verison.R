library(wholebrain)
#set folder path
folder<-'/Volumes/Elements/brain_image_analysis/sectioned_test_2'
setwd(folder)
subfolders <- list.dirs(path = ".", full.names = TRUE, recursive = TRUE)
data <- data.frame()
sort.list(subfolders)
subfolders <- subfolders[-1]
#map to atlas coordinates
#set cutting thickness in millimeters
distance.between.sections <- .05
#assign coordinates to image 2, 10, 20 and 40. 
#Just check where they are and then assign them coordinate AP to bregma. 
#In this case 3.1, 2.26, 1.22 and -0.87
coords<-map.to.atlas(image.number = c(2, 10, 20, 40), 
                     coordinate = c(3.10,  2.26,  1.22, -0.87), 
                     sampling.period = distance.between.sections, 
                     number.of.sections = length(subfolders) )

for (i in seq_along(subfolders)) {
  setwd(subfolders[i])
  gray.scalefolder <- create.output.directory('grayscale', '.')
  setwd(gray.scalefolder)
  images <- get.images('..')
  for(j in seq_along(images)){
    #convert to gray scale
    rgb2gray(images[j], invert = FALSE)
  }
  img<- stitch('.', order = "right.&.down",  type = "row.by.row", tilesize = 2040, overlap = 0.1, show.image = FALSE)
  myfilter <- list(alim = c(20, 300), 
                   threshold.range = c(147, 256), 
                   eccentricity = 1000, 
                   Max = 255, 
                   Min = 0, 
                   brain.threshold = 10, 
                   resize = 0.08, 
                   blur = 5, 
                   downsample = 1)
  
  seg<-segment(img, filter = myfilter, numthresh = 16, display = FALSE)
  
  regi <- registration(img, filter = myfilter, coordinate = coords[i], display = FALSE)
  
  #dataset <- inspect.registration(regi, seg, forward.warps = TRUE)
  dataset<-get.cell.ids(regi, seg, forward.warp = TRUE) #better for looping to results displayed
  #save output for this section so you can go back and edit it.
  save(file=paste0(tools::file_path_sans_ext(basename(img)), '.RData'), seg, regi, dataset)
  #make web output
  makewebmap(img, 
		seg$filter, 
		registration = regi, 
		dataset = dataset
	)
  
  data <- rbind(data, dataset)
  setwd("../..")
}
write.csv(data, file = 'test_all_data.csv')

data <- read.csv('test_all_data.csv')

perspective<-structure(list(FOV = 30, ignoreExtent = FALSE, listeners = 1L, 
               mouseMode = structure(c("trackball", "zoom", "fov", "pull"
               ), .Names = c("left", "right", "middle", "wheel")), skipRedraw = FALSE, 
               userMatrix = structure(c(0.495914697647095, 0.285875976085663, 
                                        -0.819965422153473, 0, -0.106600426137447, -0.917073547840118, 
                                        -0.384204119443893, 0, -0.861803472042084, 0.277941107749939, 
                                        -0.424315959215164, 0, 0, 0, 0, 1), .Dim = c(4L, 4L)), scale = c(1, 
                                                                                                         1, 1), viewport = structure(c(0L, 0L, 1280L, 720L), .Names = c("x", 
                                                                                                                                                                        "y", "width", "height")), zoom = 1, windowRect = c(0L, 45L, 
                                                                                                                                                                                                                           1280L, 765L), family = "sans", font = 1L, cex = 1, useFreeType = TRUE), .Names = c("FOV", 
                                                                                                                                                                                                                                                                                                              "ignoreExtent", "listeners", "mouseMode", "skipRedraw", "userMatrix", 
                                                                                                                                                                                                                                                                                                              "scale", "viewport", "zoom", "windowRect", "family", "font", 
                                                                                                                                                                                                                                                                                                              "cex", "useFreeType"))


glassbrain(data, cex=2, spheres = TRUE)
par3d(perspective)

glassbrain(data, cex=2, device = FALSE, spheres = TRUE, high.res = TRUE)
rgl.snapshot(filename ='3dbrain_image.png')


dot.plot(data)
