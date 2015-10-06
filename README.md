Mr. Code
----
`Mr. Code` 是一个简单的 GitHub iPhone 客户端，命名源自 [Mr. Robot](https://movie.douban.com/subject/26290409/)（黑客军团，当时出了一两集就有人说是神剧的美剧）。

### Story
----

最初目的是想在 iPhone 上读这本书 [guidetodatamining](https://github.com/egrcc/guidetodatamining)，每一章都是 Markdown 格式，用 Safari 进行阅读，个人认为 GitHub 渲染后（包含代码）的 HTML 是阅读效果最好的。

虽然 [iOctocat](http://ioctocat.com)、[CodeHub](http://codehub-app.com) 已经有 GitHub 非常全面的功能，但缺少我想要的缓存功能。

因为这书每个章节很长，班车上半小时内看不完，为了减少手机流量消耗才打算做一个 App 在本地缓存 Markdown 文件渲染后的 HTML，以及 HTML 中的图片。

### Features
----

- [x] 不需要在应用内输入 GitHub 密码，只要跳 Safari 进行 OAuth 授权
- [x] 缓存 star 过的资源库，自己的公开资源库
- [x] 可以 star / fork / watch 资源库
- [x] 缓存 .md 或 .markdown 文件的渲染后的 HTML 及其图片
- [x] 可以按语言／时间段查看 [GitHub Trending](http://github.com/trending)（Thanks `CodeHub` 提供的 [GitHub-Trending](https://github.com/thedillonb/GitHub-Trending)）

### Build
----

#### Requirements

- iOS 8.0+
- Xcode 6.4+

#### Build to your device with Xcode 7

`git clone` 然后打开 `MrCode.xcworkspace`。

如果像我这样没有 Apple 开发者账号，直接使用 Xcode 7 连接上你的设备，简单设置一下就行（参考 [Xcode 7 真机调试详细步骤](http://www.jianshu.com/p/fa5f90b61ad6)）。

p.s. App 首次安装到设备之后，要在 `设置-通用-描述文件` 中信任你在 Xcode Accounts 的这个开发者。

#### (optional) Use your own GitHub application Client ID & Secret 

目前源码已经包含可用的 Client ID & Secret，如果要改成你自己的，要在 [GitHub Developer applications](https://github.com/settings/developers) 创建新的 application，得到 Client ID & Secret 填到 `MrCode/MrCode/AppDelegate.m` 即可。

### Issues
----

目前最初的主要功能已经够用（其实在实现的过程中已经花了太多时间调其他功能了），但还是有很多问题，例如：

0. star 一个新的资源库时不会更新本地的缓存（技术问题，要修复比较繁琐），也没用 KVO / Notification 更新已经显示的 UI

1. Model 类里面混用了类方法和成员方法

2. 其他

### Thanks
----

Thanks to these powerful projects.

- AFNetworking
- MJExtension
- OcticonsIOS
- Masonry
- UITableView+FDTemplateLayoutCell
- DateTools
- SDWebImage
- ChameleonFramework
- YTKKeyValueStore
- MJRefresh
- MBProgressHUD
- WebViewJavascriptBridge
- MMPopupView
- KxMenu

### License
----

This code is distributed under the terms and conditions of the MIT license.