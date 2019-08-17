
//定位
locateAction = function(data, callback) {
    mb_sendMessage('MBCommonPlugin', 'locateAction', data, callback);
};

//关闭页面
PopToApp = function(data, callback) {
    mb_sendMessage('MBCommonPlugin', 'popToApp', data, callback);
};

//计步器
qureyStep = function(data, callback) {
    mb_sendMessage('MBCommonPlugin', 'qureyStep', data, callback);
};

postHandel = function() {
    mb_sendMessage('MBCommonPlugin', 'postHandel');
}

testHandel = function(data, callback) {
    console.log(data);
    callback('xxxxxx');
}
