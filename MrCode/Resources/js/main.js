
// 必须，初始化 WebViewJavascriptBridge
function connectWebViewJavascriptBridge(callback) {
    if (window.WebViewJavascriptBridge) {
        callback(WebViewJavascriptBridge)
    } else {
        document.addEventListener('WebViewJavascriptBridgeReady', function() {
            callback(WebViewJavascriptBridge)
        }, false)
    }
}

// HTML body 中的主调函数
function onLoaded() {
    console.log("onLoaded...");

    // 初始化 WebViewJavascriptBridge
    connectWebViewJavascriptBridge(function(bridge) {

        // 0. 初始化，所有 objc send(data) 的方法都会经过这里处理
        // FIXME: 测试发现如果不 init，下面的 bridge.registerHandler 不会被 objc 调用到
        bridge.init(function(data, responseCallback) {
            var data = JSON.stringify(data);
            // alert("JS Got data from objc: " + data);
            if (responseCallback) {
                responseCallback("JS reponse for objc data=" + data);
            }
        });

        // 1. 将当前页面所有 image 下的 image_src 地址收集起来
        var imageUrlsArray = new Array();
        var allImage = document.querySelectorAll("img");

        // 2. 从已经被替换好的 image.image_src 属性中取出图片路径
        allImage = Array.prototype.slice.call(allImage, 0);
        allImage.forEach(function(image) {
            var image_src = image.getAttribute("image_src");
            var newLength = imageUrlsArray.push(image_src);
        });
        
        // 3. 将所有图片地址发给 objc 端
        bridge.send(imageUrlsArray);



        // 4. 当 objc 每下载完一张图片时会调用，
        // 给替换后的 HTML 追加 image.src 属性，赋值为本地图片路径
        bridge.registerHandler('imagesDownloadComplete', function(data) {
            
            var paths = data.toString().split(",");
            var origin_src = paths[0];
            var cached_src = paths[1];
            
            // alert(origin_src);
            // alert(cached_src);

            var allImage = document.querySelectorAll("img");
            allImage = Array.prototype.slice.call(allImage, 0);

            allImage.forEach(function(image) {
                if (image.getAttribute("image_src") == origin_src) {
                    image.src = cached_src;
                }
            });
        });
    });
}
