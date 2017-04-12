#### Script to auto-load some dummy data


curl -XPUT 'localhost:9200/olympic/'
printf "\nCreate person mapping\n"
curl -XPUT 'localhost:9200/olympic/person/_mapping' -H 'Content-Type: application/json' -d'
{
  "person": {
    "properties": {
      "eyeColour": {"type": "string"},
      "name": {"type": "string"},
      "firstName": {
      	"type": "string",
      	"boost" : 1.5
      },
      "lastName" : {
      	"type": "string",
      	"boost" : 2
      },
      "dob" : {"type": "date"},
      "heightCm" : {"type": "float"},
      "gender" : {"type": "string"},
      "dCode" : {"type" : "string"},
      "class" : {"type" : "string"},
      "locations" : {
        "type" : "object",
        "dynamic" : true,
        "properties" : {
          "id" : {"type": "string"},
          "city" : {"type": "string"},
          "country" : {"type" : "string"},
          "dCode" : {"type" : "string"},
          "class" : {"type" : "string"},
          "location" : {"type" : "geo_point"}
        }
      },
      "events" : {
        "type" : "object",
        "dynamic" : true,
        "properties" : {
          "id" : {"type" : "string"},
          "date" : {"type" : "date"},
          "sport" : {"type" : "string"},
          "dCode" : {"type" : "string"},
          "class" : {"type" : "string"}
        }
      },
      "objects" : {
        "type" : "object",
        "dynamic": true,
        "properties" : {
          "id" : {"type" : "string"},
          "dCode" : {"type" : "string"},
          "class" : {"type" : "string"},
          "name" : {"type" : "string"}
        }
      },
      "persons" : {
      	"type" : "object",
      	"dynamic" : true,
      	"properties" : {
      		"id" : {"type" : "string"},
      		"firstName": {"type": "string"},
    		"lastName" : {"type": "string"},
        	"dCode" : {"type" : "string"},
        	"class" : {"type" : "string"}
      	}
      }
    }
  }
}'


printf "\nCreate location mapping\n"
curl -XPUT 'localhost:9200/olympic/location/_mapping' -H 'Content-Type: application/json' -d'
{
	"location": {
		"properties": {
			"city": {"type": "string"},
			"country" : {"type" : "string"},
			"location" : {"type" : "geo_point"},
			"dCode" : {"type" : "string"},
			"class" : {"type" : "string"},
			"info" : {"type" : "string"}
		}
	}
}'
printf "\nLoad data\n"
curl -XPOST 'localhost:9200/olympic/person/_bulk?pretty' --data-binary @person.json
curl -XPOST 'localhost:9200/olympic/organisation/_bulk?pretty' --data-binary @organisation.json
curl -XPOST 'localhost:9200/olympic/object/_bulk?pretty' --data-binary @object.json
curl -XPOST 'localhost:9200/olympic/location/_bulk?pretty' --data-binary @location.json
curl -XPOST 'localhost:9200/olympic/event/_bulk?pretty' --data-binary @event.json
