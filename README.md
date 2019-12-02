# UIWindows

A framework that makes multi-windows interface possible on iOS

## Installation

### CocoaPods

```ruby
pod 'UIWindows', :git => 'https://github.com/sinLuke/UIWindows.git', :tag => '2.0.0'
```

### Usage

1. Add the following import in the file of your project when you want to make a ViewController a Window:

   ```Swift
   import UIWindows
   ```

2. Create a WindowsManager to manage all the windows we are going to create. Make sure do that after the metrics of your contoller's view been calculated (e.g. do it in viewDidAppear)

   ```Swift
   manager = UIDesktop(makeViewControllerAsDesktop: containerViewController)
   ```

3. (Optional) Create a configuration for the window. minHeight is the minimum height of the window, minWidth is the minimum width of the window, cornerAdjustRadius is the radius of the draggable area on the corner of the window.

```Swift
let config = UIWindowsConfig(minHeight: CGFloat, minWidth: CGFloat, tintColor: UIColor, cornerAdjustRadius: CGFloat)
```

4. Create a WindowView and put it in the manager. The manager will automatically add the window into your container view controller:

   ```Swift
   let windowView = UIWindowsWindow(childVC: webBrowserViewController, with: config)
   manager.add(new: windowView)
   ```

5. The window can be dragged inside the container view controller. When dragging on corners, it can be resized. When double tap the top bar, it will go full screen.

### Example

An example is given in the example folder. It used a simple Webview to test out the functionality of UIWindows.
run pod install before testing.
