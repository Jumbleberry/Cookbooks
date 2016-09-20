# AWS config
default['aws_default_region'] = 'us-east-1'

# Regex
default['elb_name_reg'] = 'nginx-elb'
default['target_group_arn_reg'] = 'TargetGroupArn\"\s?:\s?\"\K[^\"]*'