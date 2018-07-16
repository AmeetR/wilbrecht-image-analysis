library(wholebrain)

#set folder path
folder<-'../data/unstiched_images'

#find out how many images we have and their location
images<-get.images(folder)
length(images)

#stitch this image

get.grid.coordinates(1:length(images), tilesize=2040, overlap = 0.1,  plotgrid=TRUE)

stitch(folder, show.image=TRUE)

#image show command
filename<-'../data/test_image_1.tif'

imshow(filename)

#flat-field correction
flat.field.correction(folder)
FFC_folder<-'../data/FFC_unstiched_images'
stitch(FFC_folder)

FFC_filename<-'../data/ANIMAL_NAME/FFC_section001/stitched_FFC_section001.tif'
imshow(FFC_filename)

#Segmentation
seg<-segment(FFC_filename)

names(seg)
names(seg$soma)
plot(seg$soma$x, seg$soma$y, ylim=rev(range(seg$soma$y)), asp=1)

#Registration
quartz()
regi<-registration(FFC_filename, coordinate=0.38, filter=seg$filter)

#add corr.points
regi<-add.corrpoints(regi, 10)

#rerun registration
regi<-registration(FFC_filename, coordinate=0.38, filter=seg$filter, correspondance = regi)

#change corrpoints
regi<-change.corrpoints(regi, 15:20)
#rerun registration
regi<-registration(FFC_filename, coordinate=0.38, filter=seg$filter, correspondance = regi)

#save segmentation and registration
save(seg, regi, file='example_section.Rdata')

#inspect registration results
dataset<-inspect.registration(regi, seg)
dataset$animal<-'Fievel Mousekewitz'
head(dataset)
dataset<-dataset[!dataset$id==0,]
which(dataset$id==0)

dataset<-inspect.registration(regi, seg)
quartz.save(file='inspect_registration.pdf', type="pdf")

#make plot of results
bargraph(dataset)
quartz.save(file='contra_versus_ipsi_example_section.pdf', type="pdf")

#get some cell counts
dosomestats.on.this<-table(dataset$acronym, dataset$right.hemisphere)