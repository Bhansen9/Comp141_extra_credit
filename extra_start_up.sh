# import python3 packages built-in packages
import requests
import json
import time

baseUrl = "https://aeroapi.flightaware.com/aeroapi"

# get user input for api key and airport code
apiKey = input("Enter FlightAware AeroAPI Key:")
airport = input("Enter Airport Code (ex. KORD = O'Hare International Airport):")

payload = {'max_pages': 5}
auth_header = {'x-apikey':apiKey}

'''
curl -X GET "https://aeroapi.flightaware.com/aeroapi/airports/{airport}/flights?type=Airline&start=2024-11-20T00%3A00%3A59Z&end=2024-11-20T23%3A59%3A59Z" \
     -H "Accept: application/json; charset=UTF-8" \
     -H "x-apikey: [REACTED]" \
'''

flights = []
startTimeStr = "2024-11-20T00%3A00%3A59Z" # encode urllib.parse.urlencode start time 
endTimeStr = "2024-11-20T23%3A59%3A59Z" # encode urllib.parse.urlencode end time 
# documentation https://www.flightaware.com/aeroapi/portal/documentation#get-/airports/-id-/flights
uri = f"/airports/{airport}/flights?type=Airline&start={startTimeStr}&end={endTimeStr}"
while True:
    time.sleep(60) # 1minute between each data set call to prevent 429 code error https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/429
    response = requests.get(baseUrl + uri, params=payload, headers=auth_header)
    if response.status_code == 200:
        data = response.json()
        print("Add {0} Flights".format(len(data["arrivals"])))
        flights = flights + data["arrivals"]
        links = data["links"]
        # check if more data to download
        try:
            next = links["next"]
            if next == "":
                break
            
            uri = next
        except TypeError:
            break
    else:
        print("error executing request")
        print(response)
        break

with open(f"{airport}_FLIGHTS.json", "w") as f:
    json.dump(flights, f)

print("Done Running Script")
