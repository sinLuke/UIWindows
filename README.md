# UIWindows

A framework that makes multi-windows interface possible on iOS

## Installation

### CocoaPods

```ruby
pod 'UIWindows', :git => 'https://github.com/sinLuke/UIWindows.git', :tag => '1.0.0'
```

### Usage

1. Add following import in file of your project when you want to make a ViewController a Window:

   ```Swift
   import UIWindows
   ```

2. Create a WindowsManager to manage all the windows we are going to create.

   ```Swift
   manager = UIWindowsManager(on: containerViewController)
   ```

3. (Optional) Create a configuration for the window. minHeight is the minium height of the window, minWidth is the minium width of the window, cornerAdjustRadius is the radius of the draggable area on the corner of the window.

   ```Swift
   let config = UIWindowsWindow.Config(minHeight: CGFloat?, minWidth: CGFloat?, tintColor: UIColor?, cornerAdjustRadius: CGFloat?)
   ```

4. Create a WindowView and put it in the manager. The manager will automaticlly add the window into your conatiner view controller:

   ```Swift
   let windowView = UIWindowsWindow(childVC:    webBrowserViewController, with: config)
   manager.add(new: windowView)
   ```

5. The window can be dragged inside the conatiner view controller. When drag on corners, it can be resize. When double tap the topbar, it will go full screen.
