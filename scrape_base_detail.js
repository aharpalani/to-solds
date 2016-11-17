var url = 'http://www.mongohouse.com/soldrecords/58005cbf5c7230670612c72c';
var path = 'main_20161013_01.html';
var login_url = 'http://www.mongohouse.com/authentication/signin';

var steps = [];
var ind = 0;
var loadInProgress = false;
var page =  new WebPage();
page.settings.userAgent = 'Chrome/54.0.2840.99 Safari/537.36';
page.settings.javascriptEnabled = true;
page.settings.loadImages = false;
phantom.cookiesEnabled = true;
phantom.javascriptEnabled = true;


steps = [

	//Step 1 - Open Mongohouse Login Page
	function(){
		console.log('Step 1 - Open Mongohouse Login Page');
		page.open(url, function(status){
			
		});
	},
	
	//Step 2 - Sign Into Mongohouse
	function(){
		console.log('Step 2 - Login to Mongohouse');
		var fs = require('fs');
		page.evaluate(function(){
			
			var changeEvent = document.createEvent ("HTMLEvents");
			changeEvent.initEvent ("change", true, true);
			document.getElementById('username').value='[un]';
			angular.element(document.getElementById('username')).val='[pw]';
			document.getElementById('password').value='[un]';
			angular.element(document.getElementById('password')).val='[pw]';
			document.getElementById('username').dispatchEvent (changeEvent);
			document.getElementById('password').dispatchEvent (changeEvent);
			document.getElementsByClassName('btn btn-primary')[0].click();
		});
	},
	
	//Step 3 - Go To Individual House Page
	function(){
		console.log('Step 3 - Go to Individual House Page');
		page.open(url, function(status){});	
	},
	
	
	//Step 4 - Download Page
	function(){
		console.log('Step 4 - Download Data');
		var fs = require('fs');
		fs.write(path, page.content, 'w');
		phantom.exit();
	},
];

//Execute Steps
interval = setInterval(executeSteps, 2500);

function executeSteps(){
	if (loadInProgress === false && typeof steps[ind] == "function") {
		steps[ind]();
		ind++;
	}
	if (typeof steps[ind] != "function") {
		console.log("Test Complete!");
		phantom.exit();
	}
}

page.onLoadStarted = function() {
    loadInProgress = true;
    console.log('Loading started');
};
page.onLoadFinished = function() {
    loadInProgress = false;
    console.log('Loading finished');
};
page.onConsoleMessage = function(msg) {
    console.log(msg);
};