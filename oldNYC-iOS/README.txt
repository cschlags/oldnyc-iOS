NOTES

1) markers.json is up-to-date as of 2/24. Check Dan's lat-lon-counts.js for updates. I manually created this JSON file from that data. https://github.com/oldnyc/oldnyc.github.io/blob/master/lat-lon-counts.js

    a) Use an online CSV -> JSON converter to help generate JSON.
    b) Numformatter in code will ensure lat and lon values have 6 decimal places, as needed by oldnyc.org/by-location directory.

2) /by-location is up-to-date as of 3/13.

3) In MapViewController, when downloading JSON data from oldnyc.org, I bypassed Application Transport Security's default behavior of not downloading from HTTP connections. https://forums.developer.apple.com/thread/3544


/*
TARGET FLOW:
- load map centered in NYC (around default coordinates / zoom level)
- check if user is in NYC
- if yes, enable location tracking. display blue dot, enable center-on-current-location button.
- if no, do not enable location tracking. do not display blue dot and center-on-current-location button.
- clicking on center-on-current location button will recent map on user, then put into .Follow tracking mode
*/