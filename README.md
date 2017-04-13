# Elasticsearch Cluster on AWS 
 
 
## The OS:  
Amazon Linux 
 
## The Package: 
Using the wget tool to download. 
The package is being downloaded from: 
https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/rpm/elasticsearch/2.4.4/elasticsearch-2.4.4.rpm 
This is in an rpm format: it then uses the red hat package manager (on all centOS/Redhat/amazon linux distibutions) to install and set up a basic user called 'elasticsearch' and an 'elasticsearch' group. 
This is version 2.4.4. 
 
## The Dependencies:  
Java 
Currently using java-1.7.0-openjdk-devel 

## The Plugins: 
aws-cloud: 
Which can be downloaded from: 
https://download.elastic.co/elasticsearch/release/org/elasticsearch/plugin/cloud-aws/2.4.4/cloud-aws-2.4.4.zip 
Shield: 
Which can be downloaded from : 
https://download.elastic.co/elasticsearch/release/org/elasticsearch/plugin/license/2.4.4/license-2.4.4.ziphttps://download.elastic.co/elasticsearch/release/org/elasticsearch/plugin/shield/2.4.4/shield-2.4.4.zip 
 
## Configuration of Elasticsearch 
 
Need to allocate the RAM which we are allowing Elasticsearch to consume (the elastic website recommends ½ of the EC2 instances total RAM). The following command in the install_elastic.sh scipt takes care of this: 
sudo sed -i '/#ES_HEAP_SIZE=2g/c\ES_HEAP_SIZE=512m' /etc/sysconfig/elasticsearch 
 
Note: the default is 2 Gb and this command changes it to 512 Mb – (because I had a t2.micro with 1Gb RAM!) 
 
## General Networking  
Elasticsearch nodes are to be run on AWS EC2 instances. EC2 instances are part of a security groups – which can be configured to allow/refuse access across different IP/ports. 
Ports for Elasticsearch: 
9200: To access the RESTful api from outside the cluster 
9300: For the nodes within the cluster to internally speak to each other. 
(At the moment, you can access the cluster (I.e make api calls) from hitting any node's IP on port 9200. I'm not sure if it can be configured to have one central access point/ load-balancer type approach) 
 
## Clustering EC2 nodes in AWS 
There is an plugin for elastic-search called: cloud-aws. This allows the nodes to automatically go off and find more elastic nodes within the AWS environment.  
I downloaded the cloud-aws plugin from: 
https://download.elastic.co/elasticsearch/release/org/elasticsearch/plugin/cloud-aws/2.4.4/cloud-aws-2.4.4.zip 
 
There is a small amount of configuration to do. This is set within the /etc/elasticsearch/elasticsearch.yml 
 
Note, in the elasticsearch.yml, I've set the following parameters: 
- network.host: 0.0.0.0 
- network.publish_host: _ec2_ 
- cloud.aws.access_key: <Insert Access Key> 
- cloud.aws.secret_key: <Insert Secret Key> 
- cloud.aws.region: eu-west-2 
- cloud.aws.ec2.endpoint: ec2.eu-west-2.amazonaws.com 
- discovery.type: ec2 
You can also set more filters to refine your search for nodes (i.e. Filter by: security groups, ec2_tags, etc) – this is useful if we've got a lot of EC2 instances to search through – It makes the process more efficient. 

## The Parameters: 
“network.publish_host: _ec2_”: This tells the node to publish its private ipv4 address – the other nodes can see this within AWS environment – and saves publishing its public address. 
“cloud.aws.region: eu-west-2”: Needs to be set to the aws region the nodes are running in. 
“cloud.aws.ec2.endpoint: ec2.eu-west-2.amazonaws.com”: Small workaround which needs to be kept if we are working in the eu-west-2 region (London) – the plugin for 2.4.4 wasn't updated to include the endpoint for the London region  
 
## Permissions in AWS 
In order for the nodes to cluster together we are required to give an AWS ACCESS KEY/AWS SECRET KEY to the node: 
cloud.aws.access_key: <Insert Access Key> 
cloud.aws.secret_key: <Insert Secret Key> 
This is set within the /etc/elasticsearch/elasticsearch.yml. 
 
So, will have to configure a special user (e.g. 'Elasticsearch_user') in the AWS IAM to give specific permissions to allow the node to discover other nodes (to form a cluster!) 
I'm unsure (at the moment) of how limited the permissions can be, whilst still maintaining functionality (need to test). 
Potentially just need to create the following policy in AWS's IAM, then apply it to our 'Elasticsearch_User' user: 
 
{ 
    "Statement": [ 
        { 
            "Action": [ 
                "ec2:DescribeInstances" 
            ], 
            "Effect": "Allow", 
            "Resource": [ 
                "*" 
            ]            
        } 
    ], 
    "Version": "2012-10-17" 
} 
 
 
 
 
## Loading in Data 
Currently I am automatically loading in the dummy Olympic data into the elasticsearch to allow test api calls. This is done by copying the data into the node using Packer's File Provisioner tool  
 
Note: you can only load files into the ~/ directory. You don't have permissions to copy anywhere else. 
After it's in, a script is run to make POST requests to localhost:9200 – which loads in the dummy data. 
 
## Making API Calls 
Now that data has been loaded, you can externally (I.e ) call the api on: 
 
<Public_IP_of_EC2_Instance>:9200/olympic/person/p_1 
or, 
<Public_DNS_of_EC2_Instance>:9200/olympic/person/p_1 
 
## Elasticsearch Security 
 
User Authentication:
 
To enable user authentication on your Elasticsearch api calls you have to download/install the Shield plugin. This needs to be installed on every node in the cluster (which will happen, as we are creating an pre-loaded image which all nodes can be based on). 
 
Shield is enabled by carrying out the following steps: 
Download License: 
https://download.elastic.co/elasticsearch/release/org/elasticsearch/plugin/license/2.4.4/license-2.4.4.zip 
Download Shield:   
https://download.elastic.co/elasticsearch/release/org/elasticsearch/plugin/shield/2.4.4/shield-2.4.4.zipInstall 
License:           
bin/plugin install file:///path/to/file/license-2.4.4.zip 
Install Shield:    
bin/plugin install file:///path/to/file/shield-2.4.4.zip 
 
Note: As of Elasticsearch v5, shield is part of X-Pack. 
 
## Securing Traffic Between Nodes
