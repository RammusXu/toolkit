```json
{
    "version": "0",
    "id": "8fb04f2f-0294-3999-12d1-89087690995f",
    "detail-type": "EC2 Instance State-change Notification",
    "source": "aws.ec2",
    "account": "193218521844",
    "time": "2018-01-09T09:52:06Z",
    "region": "ap-southeast-1",
    "resources": [
        "arn:aws:ec2:ap-southeast-1:193218521844:instance/i-0c32cdea54089dd53"
    ],
    "detail": {
        "instance-id": "i-0c32cdea54089dd53",
        "state": "running"
    }
}
```

```python
def lambda_handler(event, context):

    if 'source' in event and event['source'] == 'aws.ec2':
        # Do something...

    print('event', event)
    return event
```