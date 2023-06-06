---
description: awscli
---

# AWS

useful awscli, concept

## awscli

```
export AWS_PROFILE=dev
```

### ec2
#### tags
create/update tags
```
aws ec2 create-tags \
    --resources i-xxxxxxxxx \
    --tags 'Key=app,Value=kafka'
```

search by tags
```
aws ec2 describe-instances \
    --filters Name=tag:app,Values=kafka

aws ec2 describe-instances \
    --filters 'Name=tag:Name,Values=*kafka*'

aws ec2 describe-instances \
    --filters Name=tag:app,Values=kafka \
    --query 'Reservations[*].Instances[*].{Instance:InstanceId,Tags:Tags}'
```
more example: https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-instances.html

#### disable termination protection
```
aws ec2 modify-instance-attribute --no-disable-api-termination --instance-id i-xxxxx --profile rammus-dev
```
