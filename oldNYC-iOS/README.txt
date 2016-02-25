NOTES

1) markers.json is up-to-date as of 2/24. Check Dan's lat-lon-counts.js for updates. I manually created this JSON file from that data. https://github.com/oldnyc/oldnyc.github.io/blob/master/lat-lon-counts.js


/*
TARGET FLOW:
- load map centered in NYC (around default coordinates / zoom level)
- check if user is in NYC
- if yes, enable location tracking. display blue dot, enable center-on-current-location button.
- if no, do not enable location tracking. do not display blue dot and center-on-current-location button.
- clicking on center-on-current location button will recent map on user, then put into .Follow tracking mode
*/