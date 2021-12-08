var exec = require('cordova/exec');

var AliPush = {
    coolMethod: function (arg0, success, error) {
        exec(success, error, 'AliPush', 'coolMethod', [arg0]);
    },
}

module.exports = AliPush;