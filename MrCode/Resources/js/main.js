
function connectWebViewJavascriptBridge(callback) {
    if (window.WebViewJavascriptBridge) {
        callback(WebViewJavascriptBridge)
    } else {
        document.addEventListener('WebViewJavascriptBridgeReady', function() {
            callback(WebViewJavascriptBridge)
        }, false)
    }
}

function imagesDownloadComplete(pOldUrl, pNewUrl) {
    var allImage = document.querySelectorAll("img");
    allImage = Array.prototype.slice.call(allImage, 0);
    
    allImage.forEach(function(image) {
        if (image.getAttribute("image_src") == pOldUrl || image.getAttribute("image_src") == decodeURIComponent(pOldUrl)) {
            image.src = pNewUrl;
        }
    });
}

function onLoaded() {
    console.log("onLoaded...");
    alert("onLoaded()");
    
    connectWebViewJavascriptBridge(function(bridge) {
        var imageUrlsArray = new Array();
        var allImage = document.querySelectorAll("img");
                                   
        allImage = Array.prototype.slice.call(allImage, 0);
        allImage.forEach(function(image) {
            var image_src = image.getAttribute("image_src");
            var newLength = imageUrlsArray.push(image_src);
        });
        
        bridge.send(imageUrlsArray);
    });
}
