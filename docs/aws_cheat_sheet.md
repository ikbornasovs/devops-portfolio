EC2 Key Pair
```
aws ec2 create-key-pair 
  --key-name my-ec2-key \
  --query "KeyMaterial" \
  --output text > my-ec2-key.pem
chmod 400 my-ec2-key.pem
```
my-ec2-key — это имя Key Pair в AWS, оно попадает в EC2 при запуске.

при необходимости, можно добавить имя профиля и/или регион
  --profile dev \
  --region eu-central-1 \