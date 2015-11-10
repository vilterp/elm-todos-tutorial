var express = require('express');
var fs = require('fs');
var exphbs  = require('express-handlebars');
var bodyParser = require('body-parser');
var logger = require('morgan');
var http = require('http');

var app = express();

app.use(bodyParser.json());
app.use(logger('combined'));
app.engine('handlebars', exphbs());
app.set('view engine', 'handlebars');

app.use(express.static(__dirname + '/public'));

app.get('/', function(req, res) {
	fs.readFile('./todos.json', function(err, contents) {
		console.log(contents);
		var decoded;
		if(err) {
			res.status(500).send(err.toString());
			decoded = "[]";
		} else {
			decoded = contents.toString('utf8');
		}
		var parsed = JSON.parse(decoded);
		console.log(JSON.stringify(parsed));
		res.render('app', {
			initialTodos: JSON.stringify(parsed)
		});
	});
});

app.post('/saveTodos', function(req, res) {
	fs.writeFile('./todos.json', JSON.stringify(req.body), function(err) {
		if(err) {
			res.status(500).send(err.toString());
			return;
		}
		res.send('{"result": "success"}');
	})
});

// start it up
var PORT = 8088;
app.listen(PORT, function(err) {
	console.log('listening on http://localhost:' + PORT + '/');
});
