
MB_Queue = [];
MB_Task = {
    id: 0,
    callback: function(){},
    init: function(id, callback) {
        this.id = id;
        this.callback = callback;
        return this;
    }
};

mb_callSuccess = function(i, data) {
    console.log('len:'+i);
    if (MB_Queue.length > i && MB_Queue[i].callback) {
        MB_Queue[i].callback('00', data);
    }
};

mb_callError = function(i, msg) {
    if (MB_Queue.length > i && MB_Queue[i].callback) {
        MB_Queue[i].callback('11', msg);
    }
};

mb_sendMessage = function(className, funcName, data, callback) {
    MB_Queue.push(MB_Task.init(MB_Queue.length, callback));
    window.webkit.messageHandlers.MSGJSCALLNATIVE.postMessage({className: className, functionName: funcName, taskId: MB_Queue.length - 1, data: data});
};

mb_getMessageFromNative = function(messageJSON) {
    var message = messageJSON;
    var responseCallback;
    //设置回调
    if (message.callbackId) {
        var callbackResponseId = message.callbackId;
        responseCallback = function(responseData) {
            //发起对回调的调用
            mb_sendCallBack(JSON.stringify({handlerName:message.handlerName, responseId:callbackResponseId, responseData:responseData}));
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

mb_sendCallBack = function(responseData) {
    window.webkit.messageHandlers.MSGNATIVECALLBACK.postMessage({response: responseData});
}

mb_clearAll = function(data, callback) {
    MB_Queue = [];
    if (callback) {
        callback();
    }
}

