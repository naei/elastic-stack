const elasticsearch = require('elasticsearch');

// Connect to Elasticsearch API
const client = new elasticsearch.Client({
  host: 'localhost:9200',
  log: 'trace'
});

// Log example 
const indexName = 'nodeapp';
const typeName = 'nodeapp-error'
const message = {
  date: '2017-03-30T05:09:08.282Z',
  tags: ['aaa', 'bbb'],
  title: 'Error number ' + Math.floor(Math.random() * 1000),
  message: 'What have I done?!'
};

// Send the log to Elasticsearch
client.index({
  index:  indexName,
  type:   typeName,
  body:   message
}, function (error, response) {
  if (error){
    console.log("Error:", error);
  } else {
    console.log("Success", response);
  }
});
