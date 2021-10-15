# Terminate instance:

instance_id=$(aws ec2 describe-instances \
--filters "Name=tag:Name,Values=ubuntu-cli" \
--query "Reservations[].Instances[].InstanceId" \
--output text)

aws ec2 terminate-instances --instance-ids "$instance_id"