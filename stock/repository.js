const mode = process.env.MODE || 'local';

const createLocalDb = () => {
  console.log('Using local db');

  const fs = require('fs');
  const fileName = 'db.txt';
  
  return {
    save: (value) => {
      return fs.promises.writeFile(fileName, value, 'utf8');
    },
    read: () => {
      return fs.promises.readFile(fileName, 'utf8');
    }
  }
}

const createDynamoDb = () => {
  console.log('Using dynamoDB');

  const AWS = require('aws-sdk');
  AWS.config.update({region: 'eu-central-1'});
  const documentClient = new AWS.DynamoDB.DocumentClient({apiVersion: '2012-08-10'});

  return {
    save: (value) => {
      const params = {
        TableName: 'training',
        Key: {
          'stock' : 'current'
        },
        UpdateExpression: 'set stock_value = :value',
        ExpressionAttributeValues: {
          ':value': value
        }
      }; 
      return documentClient.update(params).promise();
    },
    read: () => {
      const params = {
        TableName: 'training',
        Key: {
          'stock' : 'current'
        }
      };
      return documentClient.get(params)
        .promise()
        .then((result) => {
          return result.Item.stock_value
        });
    }
  }
}

const createDb = (mode) => {
  switch (mode) {
    case 'aws': return createDynamoDb(); break;
    default: return createLocalDb();
  }
}

const db = createDb(mode);

const save = (stock) => {
  return db.save(stock);
}

const read = () => {
  return db.read();
}

module.exports = {
  save,
  read
}