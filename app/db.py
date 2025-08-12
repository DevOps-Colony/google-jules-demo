import boto3
from botocore.exceptions import ClientError
import os
from werkzeug.security import generate_password_hash, check_password_hash
import uuid

# Use a session to ensure thread safety in a web app context
session = boto3.Session()

def get_db_resource():
    return session.resource('dynamodb', region_name=os.environ.get('AWS_REGION', 'ap-south-1'))

def get_user_by_id(user_id):
    dynamodb = get_db_resource()
    table = dynamodb.Table(os.environ.get('DYNAMODB_TABLE', 'users-table-dev'))
    try:
        response = table.get_item(Key={'id': user_id})
    except ClientError as e:
        print(e.response['Error']['Message'])
        return None
    else:
        return response.get('Item')

def get_user_by_username(username):
    dynamodb = get_db_resource()
    table = dynamodb.Table(os.environ.get('DYNAMODB_TABLE', 'users-table-dev'))
    try:
        response = table.query(
            IndexName='username-index',
            KeyConditionExpression='username = :username',
            ExpressionAttributeValues={':username': username}
        )
    except ClientError as e:
        print(e.response['Error']['Message'])
        return None
    else:
        if response.get('Items'):
            return response['Items'][0]
        return None

def create_user(username, email, password):
    dynamodb = get_db_resource()
    table = dynamodb.Table(os.environ.get('DYNAMODB_TABLE', 'users-table-dev'))
    user_id = str(uuid.uuid4())
    try:
        table.put_item(
            Item={
                'id': user_id,
                'username': username,
                'email': email,
                'password_hash': generate_password_hash(password)
            }
        )
        return True
    except ClientError as e:
        print(e.response['Error']['Message'])
        return False

def check_password(password_hash, password):
    return check_password_hash(password_hash, password)
