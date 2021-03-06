var exec = require('cordova/exec');

var AliPush = {
  /**
   * bind account 绑定账号
   * @param account account 账号
   * @param success callbackSuccess 成功回调
   * @param error callbackError 失败回调
   */
  bindAccount: function (account, success, error) {
    exec(success, error, 'AliPush', 'bindAccount', [account]);
  },

  /**
   * unbind account 解绑账号
   * @param success callbackSuccess 成功回调
   * @param error callbackError 失败回调
   */
  unbindAccount: function (success, error) {
    exec(success, error, 'AliPush', 'unbindAccount', []);
  },

  /**
   * get Device id 获取设备ID
   * @param success callbackSuccess 成功回调
   * @param error callbackError 失败回调
   */
  getDeviceId: function(success, error) {
    exec(success, error, 'AliPush', 'getDeviceId', []);
  }
}

module.exports = AliPush;
