# Product Requirements Document: Drawing and Animation App

## 1. Overview

This document outlines the requirements for a Flutter mobile application that provides users with a creative space for drawing and interacting with animations. The app will consist of two main features: a drawing canvas and an animation showcase page.

## 2. Project Setup

*   **Process: Update Dependencies**
    - [x] Update `pubspec.yaml` to use the latest library versions.

## 3. Features

### 3.1. Drawing Canvas

The drawing canvas will be a digital easel where users can express their creativity.

*   **Process: Free-hand Drawing**
    - [x] Listen for pan update events on the canvas area.
    - [x] Store the user's drawing path as a series of points.
    - [x] Use a `CustomPainter` to draw the path on the canvas.

*   **Process: Erase Drawing**
    - [x] Add a toggle button with the `cleaning_services` icon to switch between "Draw" and "Erase" modes.
    - [x] When in "Erase" mode, set the painter's `BlendMode` to `BlendMode.clear`.
    - [x] Update the `CustomPainter` to apply the `BlendMode.clear` when drawing lines in erase mode, effectively erasing them.

*   **Process: Adjust Stroke Width**
    - [x] Add a vertical `Slider` inside a `Drawer` with discrete steps and divisions.
    - [x] The selected stroke width value should be displayed on the main UI.
    - [x] On slider value change, update the stroke width state.
    - [x] The `CustomPainter` will use this value to adjust the thickness of both drawing and erasing lines.

*   **Process: Sticker Placement**
    - [x] Create `Draggable` widgets for each sticker in the palette.
    - [x] Implement a `DragTarget` on the canvas area.
    - [x] On drop, capture the sticker's data and its position relative to the canvas.
    - [x] Store the sticker and its position in a list.
    - [x] Use a `CustomPainter` to render the stickers on the canvas.

*   **Process: Clear Canvas**
    - [x] Add a "Clear" button to the UI.
    - [x] On button press, empty the lists containing drawing paths and stickers.
    - [x] Trigger a rebuild of the canvas to reflect the cleared state.

*   **Process: Save to Gallery**
    - [x] Wrap the canvas widget with a `Screenshot` controller.
    - [x] Add a "Save" button to the UI.
    - [x] On button press, use the `Screenshot` controller to capture the canvas as an image.
    - [x] Use `path_provider` to get a temporary directory.
    - [x] Use `gallery_saver` to save the image file to the device's gallery.
    - [x] Display a confirmation message to the user.

#### 3.1.1. Testing

*   **Manual Testing:**
    - [x] Verify that free-hand drawing works smoothly and accurately.
    - [ ] Verify that erase mode works correctly with different stroke widths.
    - [ ] Verify that the stroke width slider in the drawer updates the stroke width of the brush.
    - [ ] Verify that the selected stroke width is displayed in the AppBar.
    - [x] Verify that stickers can be dragged from the palette and dropped onto the canvas at the correct position.
    - [ ] Verify that the "Clear" button instantly removes all content from the canvas.
    - [ ] Verify that the "Save" button saves the current canvas content to the device's gallery and that the image is not corrupted or blank.
*   **Automated Testing:**
    - [x] Write a widget test to verify that the canvas is rendered correctly.
    - [x] Write a widget test to verify that the speed dial manages drawing modes and closes on outside tap.
    - [x] Write a widget test to verify that the slider in the drawer is present and can be changed.
    - [x] Write a widget test to verify that the stroke width text in the app bar is updated when the slider is changed.
    - [x] Write a widget test to verify that the pan update listener draws and erases points correctly.
    - [x] Write a widget test to simulate a drag-and-drop operation and and verify that the sticker is added to the canvas state.
    - [x] Write a unit test for the "Clear" functionality to ensure the canvas state is properly cleared.
    - [ ] ~~Write a widget test for saving to gallery.~~ (Removed as it is hard to test without mocking)

### 3.2. Animation Page

This page will showcase a delightful and interactive animation sequence.

*   **Process: Interactive Heart Animation**
    - [x] Create a stateful widget for the heart icon.
    - [x] Initialize `AnimationController`s and define `Tween`s for each animation property (scale, color, rotation, position).
    - [x] Add a tap gesture recognizer to the heart icon.
    - [x] On tap, trigger the animation controllers in sequence to create the desired effect.

*   **Process: Progress Bar Update**
    - [x] Maintain a state variable for the progress.
    - [x] After the heart animation completes, update the progress state.
    - [x] Use an `AnimatedBuilder` to link the progress state to the width of the progress bar, animating its growth.

#### 3.2.1. Testing

*   **Manual Testing:**
    - [ ] Verify that tapping the heart icon triggers the full animation sequence as designed.
    - [ ] Verify that the progress bar updates its value correctly after each heart animation is completed.
*   **Automated Testing:**
    - [ ] Write a widget test to verify that the animation controllers are initialized and disposed of correctly.
    - [ ] Write a widget test to pump the animation and verify that the animated properties (scale, color, etc.) change as expected over time.
    - [ ] Write a unit test for the progress calculation logic.

## 4. User Interface (UI)

The application will have a simple and intuitive user interface.

*   **Tab Navigation:** The main screen will feature a bottom tab bar with two tabs: "Canvas" and "Animation," allowing users to switch between the two features.
*   **Canvas UI:**
    - [ ] A dedicated area for the drawing canvas.
    - [ ] A palette of draggable stickers.
    - [ ] A "Clear" button.
    - [ ] A "Save" button in the app bar.
*   **Animation UI:**
    - [ ] A section displaying the interactive heart animations.
    - [ ] A progress bar section that visually represents the user's progress.




## 6. Assets

The following image assets are required for the application:

*   `resources/images/heart.png`
*   `resources/images/moon_sticker.png`
*   `resources/images/cup.png`
*   `resources/images/ticket.png`
*   `resources/images/cat.png`