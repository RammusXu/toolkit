
## Internal Load Balancer isn't compatible with:
https://cloud.google.com/load-balancing/docs/l7-internal/#limitations
- Cloud CDN
- Cloud Armor

## Test

Condition|echo.rammus.cf (with armor)|cdn.rammus.cf (with cdn)
---|---|---
origin.region_code == 'TW' | banned | passed
36.226.10.10/32 | banned | passed
request.headers['x-forwarded-for'].contains('36.226.10.10')	| passed | banned