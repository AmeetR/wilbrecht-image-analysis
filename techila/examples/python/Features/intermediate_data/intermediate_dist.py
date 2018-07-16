# Copyright 2017 Techila Technologies Ltd.

# This file contains the Worker Code, which will be distributed
# and evaluated on the Workers. Intermediate data will be 
# transferred using the send_im_data and load_im_data functions.

# Import required functions
from peachclient import send_im_data, load_im_data

# The function that will be executed in each Job
def intermediate_dist(input):
    a = 10 + input # Create a variable that will be sent to End-User
    send_im_data(a) # Send variable a to End-User
    a = load_im_data() # Load the updated variable received from End-User
    return(a) # Return the value received from End-User as the result
