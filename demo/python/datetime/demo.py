from datetime import *
import dateutil.parser

now = datetime.now(timezone.utc)
date = dateutil.parser.parse('2019-06-06T09:28:32.000Z')
print(date > now)

date = dateutil.parser.parse('2019-06-10T09:28:32.000Z')
print(date > now)