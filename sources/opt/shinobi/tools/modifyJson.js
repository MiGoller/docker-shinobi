process.on('uncaughtException', function (err) {
    console.error('Uncaught Exception occured!');
    console.error(err.stack);
});

const editJsonFile = require("edit-json-file");
 
// If the file doesn't exist, the content will be an empty object by default.
let file = editJsonFile(process.argv[2]);

var processArgv = process.argv.splice(3,process.argv.length)

processArgv.forEach(function(val) {
    var theSplit = val.split('=');
    var path = theSplit[0];
    var value = theSplit[1];

    if(value==='DELETE') {
        file.unset(path)
    } else {
        file.set(path, value);
        console.log(path + ': ' + value);
    }
});

//console.log(file.get());

file.save();
