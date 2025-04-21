const { DynamoDBClient, PutItemCommand } = require("@aws-sdk/client-dynamodb");

const dynamodb = new DynamoDBClient({});

exports.handler = async (event) => {
  console.log("Received event:", JSON.stringify(event, null, 2));

  for (const record of event.Records) {
    const bucket = record.s3.bucket.name;
    const key = decodeURIComponent(record.s3.object.key.replace(/\+/g, " "));
    const size = record.s3.object.size;

    // Bỏ qua folder
    if (key.endsWith("/") && size === 0) {
      console.log(`Skipping folder creation event: ${key}`);
      continue;
    }

    const contentType = record.s3.object.contentType || "unknown";

    const params = {
      TableName: process.env.DYNAMODB_TABLE,
      Item: {
        file_name: { S: key },        // 👈 THÊM file_name ở đây, vì DynamoDB cần nó làm Partition Key
        file_path: { S: key },
        bucket_name: { S: bucket },
        size: { N: size.toString() },
        content_type: { S: contentType }
      }
    };

    console.log("Inserting item into DynamoDB:", JSON.stringify(params, null, 2));

    try {
      await dynamodb.send(new PutItemCommand(params));
      console.log("✅ Successfully inserted item:", key);
    } catch (error) {
      console.error("❌ Failed to insert item:", error);
    }
  }

  return { status: 'ok' };
};
