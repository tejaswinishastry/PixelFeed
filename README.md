________________________
PixelFeed Photo App
________________________

___________
What is it?
___________

PixelFeed is a simple Photo App with user content from [Instagram API](https://www.instagram.com/developer/)

You can: 

* Login with your instagram credentials and authenticate the app to fetch your most recent photos(implicit flow) and 
logout of the app.

* View/scroll a gallery of photos and navigate to each photo. 

* Like/unlike a photo.

______________
Libraries Used
______________

Alamofire - Since this is written in swift Alamofire framework provides an easy way to do network requests if we dont want to write our own custom API framework with NSURLSession. 

SwiftyJSON - Provides built-in support for error caching mechanism for typical exceptions (such as IndexOutOfBounds etc) when parsing JSON responses.
Also, it is easy to access subarrays using a path to the element. 

_________________
Known Limitations
_________________

* Image loading can be made faster & smoother with a cache.
* Access token expiry checks to ensure valid session. If long term access token which is refreshed periodically is available, user may only need to authenticate ocassionally. This can make UX better without frequently logging in and also ensuring secure connections.
* Design: Some functions are long and can be made more modular.
* Unit testing to test the following - Core functionality of the methods & their interactions with VC ; common UI workflows such as login , navigate to various screens ; Boundary conditions such as access token expiry;
