import json, os, uuid, boto3

TABLE_NAME = os.environ["TABLE_NAME"]

# Prefer explicit endpoint; otherwise derive from LOCALSTACK_HOSTNAME.
endpoint = os.environ.get(
    "AWS_ENDPOINT_URL",
    f"http://{os.environ.get('LOCALSTACK_HOSTNAME', 'localhost')}:4566",
)

ddb = boto3.resource("dynamodb", endpoint_url=endpoint, region_name=os.environ.get("AWS_REGION","us-east-1"))
table = ddb.Table(TABLE_NAME)

def handler(event, context):
    for record in event.get("Records", []):
        body = json.loads(record["body"])
        item = {"id": str(uuid.uuid4()), "payload": json.dumps(body)}
        table.put_item(Item=item)
    return {"status": "ok", "count": len(event.get("Records", []))}
