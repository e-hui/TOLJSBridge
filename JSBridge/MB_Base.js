
TOL_Queue = [];
TOL_Task = {
    id: 0,
    callback: function(){},
    init: function(id, callback) {
        this.id = id;
        this.callback = callback;
        return this;
    }
};

tol_callSuccess = function(i, data) {
    console.log('len:'+i);
    if (TOL_Queue.length > i && TOL_Queue[i].callback) {
        TOL_Queue[i].callback('00', data);
    }
};

tol_callError = function(i, msg) {
    if (TOL_Queue.length > i && TOL_Queue[i].callback) {
        TOL_Queue[i].callback('11', msg);
    }
};

tol_sendMessage = function(className, funcName, data, callback) {
    TOL_Queue.push(TOL_Task.init(TOL_Queue.length, callback));
    window.webkit.messageHandlers.MSGJSCALLNATIVE.postMessage({className: className, functionName: funcName, taskId: TOL_Queue.length - 1, data: data});
};

tol_getMessageFromNative = function(messageJSON) {
    var message = messageJSON;
    var responseCallback;
    //设置回调
    if (message.callbackId) {
        var callbackResponseId = message.callbackId;
        responseCallback = function(responseData) {
            //发起对回调的调用
            tol_sendCallBack(JSON.stringify({handlerName:message.handlerName, responseId:callbackResponseId, responseData:responseData}));
        };
    }
    if (message.handlerName) {
        //通过函数名称进行函数调用
        var handler = eval(message.handlerName);
        if (!handler) {
            console.log("WARNING: no handler for message from native:", message);
        } else {
            new handler(message.data, responseCallback);
        }
    }
}

tol_sendCallBack = function(responseData) {
    window.webkit.messageHandlers.MSGNATIVECALLBACK.postMessage({response: responseData});
}

tol_clearAll = function(data, callback) {
    TOL_Queue = [];
    if (callback) {
        callback();
    }
}

