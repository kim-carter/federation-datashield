## Run this on linux with GUI without having to mess with xhost:
# XAUTHORITY=$(xauth info | grep "Authority file" | awk '{ print $3 }'); docker run -it  --network="host" --env DISPLAY=$DISPLAY -v $XAUTHORITY:/root/.Xauthority:ro  rdocker:latest R 
#
# to run otherwise:
# docker run -network="host" -it rdocker:latest R

library(DSI);
library(DSOpal);
library(dsBaseClient);

options(width=150);

# Connect to server
builder <- DSI::newDSLoginBuilder();
builder$append(server="server1", url="https://localhost:8844",  user="administrator", password="password");
builder$append(server="server2", url="https://localhost:8845",  user="administrator", password="password");
logindata <- builder$build();                                                                                                                                   
connections <- datashield.login(logins=logindata);

# Check datashield
datashield.pkg_status(connections);



# In DataSHIELD the person running an analysis (the client) uses client-side functions to issue commands (instructions). These commands initiate the execution (running) of server-side functions that run the analysis server-side 
# (behind the firewall of the data provider). There are two types of server-side function: assign functions and aggregate functions.

# Assign functions do not return an output to the client, with the exception of error or status messages. Assign functions create new objects and store them server-side either because the objects are potentially disclosive, or because 
# they consist of the individual-level data which, in DataSHIELD, is never seen by the analyst. These new objects can include: 
# - new transformed variables (e.g. mean centred or log transformed variables) a new variable of a modified class (e.g. a variable of class numeric may be converted into a factor which R can then model as having discrete categorical levels); 
# - a subset object (e.g. a dataframe including gender as a variable may be split into males and females).
# Assign functions return no output to the client except to indicate an error or useful messages about the object store on server-side.

# Aggregate functions analyse the data server-side and return an output in the form of aggregate data (summary statistics that are not disclosive) to the client


# Assign resources (server-side) to dataframes for use
datashield.resources(connections);

datashield.assign.resource(connections, symbol = "fedres", resource = c("Project.DemoData"));
datashield.assign.expr(conns=connections, symbol = "FEDFRAME", expr=quote(as.resource.data.frame(fedres, strict = TRUE)));
datashield.errors();


# Now we have a dataframe called FEDFRAME at each remote site ready to utilise


#### 1. First some basic summaries ###

# Get dimensions at each
ds.dim(x='FEDFRAME', datasources = connections);
ds.dim(x='FEDFRAME', type="combined"); # note connections is implicit, don't always have to specify

# Get colnames
ds.colnames(x='FEDFRAME', datasources = connections);
# note colnames, lengths, and ordering dont have to be same at each - they are matched in each though

# something similar in terms of a basic summary of the data
ds.summary(x='FEDFRAME');


#### 2. Basic dataset EDA / manip

# explore the distribution of a quantitive/continuous variable, birthweight
# It does not return minimum and maximum values as these values are potentially disclosive (e.g. the presence of an outlier). 
# By default type='combined' in this function - the results reflect the quantiles and mean pooled for all studies. Specifying the argument type='split' will give the quantiles and mean for each study: 
ds.quantileMean(x='FEDFRAME$bmi');

# for example, lets create a natural log version 
ds.log(x='FEDFRAME$bmi', newobj='LOGBMI');
ds.quantileMean(x='LOGBMI');

# note the variable above exists on the server R sessions, but is not part of our DF.  
# can assign new variables in this same way - either combined to to both sites

# explore a factor/ variable 
ds.table("FEDFRAME$eversmoke");

# try to explore/disclose a continuous variable
ds.table("FEDFRAME$bmi");
datashield.errors();
# Note server 1 and server 2 have max levels of a var set to 40 - configurable for each 

# Cross-tab casestatus by gender - each site and combined
# In DataSHIELD tabulated data are flagged as invalid if one or more cells have a count of between 1 and the minimal cell count allowed by the data providers. For example data providers may only allow cell counts ≥ 3.
ds.table(rvar="FEDFRAME$sex",cvar=c("FEDFRAME$eversmoke"));

# try to cross-tab personID by casestatus -> denied as this is unique unit record 
ds.table(rvar="FEDFRAME$age",cvar=c("FEDFRAME$bmi"));





#### Subsets #####
# ds.dataFrameSubset(df.name = "FEDFRAME", V1.name = "FEDFRAME$sex", V2.name = "0", Boolean.operator = "==", newobj = "FEDFRAME.subset.Males");
# ds.dataFrameSubset(df.name = "FEDFRAME", V1.name = "FEDFRAME$sex", V2.name = "1", Boolean.operator = "==", newobj = "FEDFRAME.subset.Females");
# ds.dim(x='FEDFRAME.subset.Males');
# ds.dim(x='FEDFRAME.subset.Females');




# grab our key vars and make sure they are factored (not numeric)
ds.asFactor(input.var.name="FEDFRAME$eversmoke",newobj.name="EVERSMOKE");
ds.asFactor(input.var.name="FEDFRAME$sex",newobj.name="SEX");

# other examples
# ds.asFactor(input.var.name="FEDFRAME$uber_status",newobj.name="ANYINFSTATUS");
# ds.asFactor(input.var.name="FEDFRAME$uber_count",newobj.name="ANYINFCOUNT",forced.factor.levels=c(0,1,2,3));
# ds.asNumeric(x="ANYINFCOUNT",newobj="ANYINFCOUNT_NUM");
# ds.table("ANYINFCOUNT");
# ds.asFactor(input.var.name="FEDFRAME$gender",newobj.name="GENDER");
# ds.asFactor(input.var.name="FEDFRAME$indig_major",newobj.name="INDIG");

ds.cbind(x = c("FEDFRAME","SEX","EVERSMOKE"),newobj="FEDFRAME");


#### 3. Plotting ####
# Core plots  = histograms, contour plots, heatmap plots and scatter plots.

# In the default method of generating a DataSHIELD histogram outliers are not shown as these are potentially disclosive. The text summary of the function printed to the client screen informs the user of the presence of classes 
# (bins) with a count smaller than the minimal cell count set by data providers.  Note that a small random number is added to the minimum and maximum values of the range of the input variable. Therefore each user should expect
# slightly different printed results from those shown below:


ds.histogram(x='FEDFRAME$bmi');
ds.heatmapPlot(x='FEDFRAME$bmi',y='FEDFRAME$age');
ds.scatterPlot(x='FEDFRAME$bmi',y='FEDFRAME$age');

ds.boxPlot("FEDFRAME","bmi", group = "SEX");




#final models - pooled analysis (IPD) 

# binary/factored outcomes
# ds.glm(formula=FEDFRAME$CASESTATUS~GENDER+INDIG+FEDFRAME$yobirth+ANYINFSTATUS, family='binomial');
# ds.glm(formula=FEDFRAME$CASESTATUS~GENDER+INDIG+FEDFRAME$yobirth+ANYINFCOUNT, family='binomial');

# quant outcomes predict bmi from sex+smoking+age
ds.glm(formula=FEDFRAME$bmi~SEX+EVERSMOKE+FEDFRAME$age, family='gaussian');


# study level meta analysis - separate at each site
ds.glmSLMA(formula=FEDFRAME$bmi~SEX+EVERSMOKE+FEDFRAME$age, family='gaussian');



