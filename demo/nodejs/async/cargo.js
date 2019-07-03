var async = require('async')

// create a cargoQueue object with payload 2 and concurrency 2
var cargoQueue = async.cargoQueue(function(tasks, callback) {
    msg = ""
    for (var i=0; i<tasks.length; i++) {
        console.log('hello ' + tasks[i].name);
        msg += tasks[i].name
    }
    callback(10,msg);
}, 2, 3);

// add some items
cargoQueue.push({name: 'foo'}, function(err,msg) {
    console.log('finished processing ',err,msg);
});
cargoQueue.push({name: 'bar'}, function(err,msg) {
    console.log('finished processing ',err,msg);
});
cargoQueue.push({name: 'baz'}, function(err,msg) {
    console.log('finished processing',err,msg);
});
cargoQueue.push({name: 'boo'}, function(err,msg) {
    console.log('finished processing',err,msg);
});