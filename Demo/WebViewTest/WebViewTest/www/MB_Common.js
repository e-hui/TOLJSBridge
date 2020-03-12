
//定位
locateAction = function(data, callback) {
    tol_sendMessage('MBCommonPlugin', 'locateAction', data, callback);
};

//关闭页面
PopToApp = function(data, callback) {
    tol_sendMessage('MBCommonPlugin', 'popToApp', data, callback);
};

//计步器
qureyStep = function(data, callback) {
    tol_sendMessage('MBCommonPlugin', 'qureyStep', data, callback);
};

postHandel = function() {
    tol_sendMessage('MBCommonPlugin', 'postHandel');
}

testHandel = function(data, callback) {
    console.log(data);
    callback('xxxxxx');
}
