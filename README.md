# Reverse Scrolling Menu Bar App

This is a simple macOS menu bar app that reverses the scrolling direction for mouse wheel events. It provides a seamless way to toggle scrolling behavior for mouse and trackpad input without interfering with the default system behavior when the Shift key is pressed.

## Features

- Reverses the scrolling direction specifically for mouse input.
- Respects macOS default behavior for the Shift key (e.g., swapping scroll axes).
- Minimalist design with a menu bar icon and no visible Dock presence.
- Easy to quit via a menu item.

## Requirements

- macOS 15.1 (Sequoia) or later.
- Swift 5.9 or later.
- Xcode for building and running the project.

## Installation

1. Clone the repository to your local machine.
2. Open the project in Xcode.
3. Ensure the `Info.plist` file includes the `LSUIElement` key with the value `true` to hide the app from the Dock.
4. Build and run the project in Xcode.

## How It Works

The app:

1. Creates a global event tap to intercept scroll wheel events.
2. Identifies the input device (mouse or trackpad) using the `scrollWheelEventIsContinuous` field.
3. Reverses the scroll direction for mouse input while maintaining the natural scrolling behavior for the trackpad.
4. Skips reversal when the Shift key is pressed, preserving macOS's default behavior.

## Menu Bar Icon

The app places an icon in the menu bar:

- **Symbol**: Two circular arrows to represent the toggle behavior.
- Clicking the icon provides a menu with a single option to quit the app.

## Known Limitations

- Input device detection relies on macOS's `scrollWheelEventIsContinuous` field, which may not perfectly differentiate between all input types.
- Debug logs are disabled in the release build but can be re-enabled for development purposes.

## Usage

1. Launch the app. It will appear in the menu bar but not in the Dock or app switcher.
2. Scroll using a mouse or trackpad to observe the reversed behavior for mouse input.
3. Press and hold the Shift key to use macOS's default axis-swapping behavior.
4. Use the menu bar icon to quit the app when needed.

## Contributing

Contributions are welcome! To contribute:

1. Fork the repository.
2. Create a new branch for your feature or bugfix.
3. Submit a pull request detailing your changes.

## License

This project is licensed under the MIT License. See the `LICENSE` file for more information.

## Author

Created by Luke S.
