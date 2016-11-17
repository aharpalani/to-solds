var url = 'http://www.mongohouse.com/reports/9%252F30%252F2016/Toronto'
var path = 'main_20160930.html'
var page =  new WebPage()
var fs = require('fs');

page.open(url, function (status) {
        just_wait();
});

function just_wait() {
    setTimeout(function() {
               fs.write(path, page.content, 'w');
            phantom.exit();
    }, 7500);
};
