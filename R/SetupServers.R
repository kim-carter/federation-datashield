# note: there are versions controlled profile functionalities on the R server versions on the server side for easy handling of multiple processing environment versions

library(opalr)

#login to the two DS server instances
o1 <- opal.login('administrator', 'password', url='https://localhost:8844');
o2 <- opal.login('administrator', 'password', url='https://localhost:8845');

# create an Opal file based resource on each of the remote servers
opal.resource_create(o1,"Project","DemoData",url="file:///srv/site1.csv",format="csv");
opal.resource_create(o2,"Project","DemoData",url="file:///srv/site2.csv",format="csv");

opal.logout(o1);
opal.logout(o2);






