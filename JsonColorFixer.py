import json

with open("Airlines.json", "r") as input:
    data = json.load(input)
    
for key in data:
    print(f"\"{data[key]["icao"]}\": \"{data[key]["color"]}\",")