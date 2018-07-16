

library(wholebrain)
#set folder path
folder<-'/Users/ameetrahane/Lab/Widlbrecht_Lab/brain-tissue-analysis/sectioned_test_2'
setwd(folder)
subfolders <- list.dirs(path = ".", full.names = TRUE, recursive = TRUE)
sort.list(subfolders)
data <- data.frame()
for (newfolder in subfolders[2:length(subfolders)]) {
  setwd(newfolder)
  gray.scalefolder <- create.output.directory('grayscale', '.')
  setwd(gray.scalefolder)
  images <- get.images('..')
  for(i in seq_along(images)){
    #convert to gray scale
    rgb2gray(images[i], invert = FALSE)
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
  
  regi <- registration(img, filter = myfilter, coordinate = 1.5, display = FALSE)
  
  dataset <- inspect.registration(regi, seg, forward.warps = TRUE)
  data <- rbind(data, dataset)
  setwd("../..")
}
write.csv(data, file = 'test_all_data.csv')
#newfolder <- subfolders[2]




#folder <- '/Users/ameetrahane/Desktop/temp_images/f1'
#current.path <- getwd()
#folder = current.path
#find out how many images we have and their location

#length(images)
#gray.scalefolder <-create.output.directory('grayscale', folder)


#this line only needed if not updated wholebrian recently
#gray.scalefolder <- paste(folder, 'grayscale', sep= '/')

#current.path <- getwd()
#images<-get.images(current.path)
#setwd(gray.scalefolder)
#images<-get.images('..')
#temp_folder <- '/Users/ameetrahane/Desktop/temp_images/f1/1'
#images <- get.images(temp_folder)
#gray.scalefolder <-create.output.directory('grayscale', temp_folder)
#gray.scalefolder <- paste(temp_folder, 'grayscale', sep= '/')
#setwd(temp_folder)
#for(i in seq_along(images)){
  #convert to gray scale
#  rgb2gray(images[i], invert = FALSE)
#}

#setwd('/Users/ameetrahane/Desktop/temp_images/f1/')
#dirs <- list.dirs('.')


#for (folder in dirs) {
#  setwd('/Users/ameetrahane/Desktop/temp_images/f1/')
#  print(folder)
#  temp_folder <- folder
#  setwd(temp_folder)
#  gray.scalefolder <-create.output.directory('grayscale', '.')
#  gray.scalefolder <- paste('.', 'grayscale', sep= '/')
#  images <- get.images('.')
#  for(i in seq_along(images)){
    #convert to gray scale
#    rgb2gray(images[i], invert = FALSE)
#  }
  
  
#}
#img <- stitch.animal('.')
#img <- stitch.animal('/Users/ameetrahane/Desktop/temp_images/f1', FFC=FALSE, web.map=TRUE)
#img<- stitch('/Users/ameetrahane/Desktop/temp_images/f1/New Folder With Items 23', order = "right.&.down",  type = "row.by.row", tilesize = 2040, overlap = 0.1, show.image = TRUE)


#myfilter <- list(alim = c(20, 300), 
#                 threshold.range = c(147, 256), 
#                 eccentricity = 1000, 
#                 Max = 255, 
#                 Min = 0, 
#                 brain.threshold = 10, 
#                 resize = 0.08, 
#                 blur = 5, 
#                 downsample = 1)

#seg<-segment(img, filter = myfilter, numthresh = 16, display = FALSE)

#regi <- registration(img, filter = myfilter, coordinate = 1.5)

#dataset <- inspect.registration(regi, seg, forward.warps = TRUE)



makewebmap(img, filter = myfilter, registration = regi, dataset = dataset, scale = 1, fluorophore = "Rabies-EGFP")
data <- read.csv('first_nine_data.csv')
dot.plot(data)

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
