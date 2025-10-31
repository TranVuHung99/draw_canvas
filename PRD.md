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

*   **Process: Sticker Placement**
    - [ ] Create `Draggable` widgets for each sticker in the palette.
    - [ ] Implement a `DragTarget` on the canvas area.
    - [ ] On drop, capture the sticker's data and its position relative to the canvas.
    - [ ] Store the sticker and its position in a list.
    - [ ] Use a `CustomPainter` to render the stickers on the canvas.

*   **Process: Clear Canvas**
    - [ ] Add a "Clear" button to the UI.
    - [ ] On button press, empty the lists containing drawing paths and stickers.
    - [ ] Trigger a rebuild of the canvas to reflect the cleared state.

*   **Process: Save to Gallery**
    - [ ] Wrap the canvas widget with a `Screenshot` controller.
    - [ ] Add a "Save" button to the UI.
    - [ ] On button press, use the `Screenshot` controller to capture the canvas as an image.
    - [ ] Use `path_provider` to get a temporary directory.
    - [ ] Use `gallery_saver` to save the image file to the device's gallery.
    - [ ] Display a confirmation message to the user.

#### 3.1.1. Testing

*   **Manual Testing:**
    - [x] Verify that free-hand drawing works smoothly and accurately.
    - [ ] Verify that erase mode works correctly with different stroke widths.
    - [ ] Verify that stickers can be dragged from the palette and dropped onto the canvas at the correct position.
    - [ ] Verify that the "Clear" button instantly removes all content from the canvas.
    - [ ] Verify that the "Save" button saves the current canvas content to the device's gallery and that the image is not corrupted or blank.
*   **Automated Testing:**
    - [x] Write a widget test to verify that the canvas is rendered correctly.
    - [ ] Write a widget test to verify that tapping the erase button toggles the erase mode.
    - [ ] Write a widget test to simulate a drag-and-drop operation and verify that the sticker is added to the canvas state.
    - [ ] Write a unit test for the "Clear" functionality to ensure the canvas state is properly cleared.

### 3.2. Animation Page

This page will showcase a delightful and interactive animation sequence.

*   **Process: Interactive Heart Animation**
    - [ ] Create a stateful widget for the heart icon.
    - [ ] Initialize `AnimationController`s and define `Tween`s for each animation property (scale, color, rotation, position).
    - [ ] Add a tap gesture recognizer to the heart icon.
    - [ ] On tap, trigger the animation controllers in sequence to create the desired effect.

*   **Process: Progress Bar Update**
    - [ ] Maintain a state variable for the progress.
    - [ ] After the heart animation completes, update the progress state.
    - [ ] Use an `AnimatedBuilder` to link the progress state to the width of the progress bar, animating its growth.

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

### 4.1. Testing

*   **Manual Testing:**
    - [ ] Verify that tapping on the "Canvas" and "Animation" tabs correctly switches between the respective pages.
    - [ ] Verify that all UI elements are laid out correctly on different screen sizes.
*   **Automated Testing:**
    - [ ] Write a widget test to verify that the initial tab is displayed correctly.
    - [ ] Write a widget test to simulate tapping on the tabs and verify that the correct page is displayed.

## 5. Technical Requirements

*   **Platform:** The application will be built using the Flutter framework for both iOS and Android.
*   **State Management:** A suitable state management solution should be chosen to manage the application's state. Options include `setState` for simple cases, or more advanced solutions like Provider or BLoC for better scalability.
*   **Dependencies:** The project will utilize the following packages:
    *   `path_provider`: To get the temporary directory for saving images.
    *   `gallery_saver`: To save the captured image to the device gallery.
    *   `screenshot`: To capture the drawing canvas as an image.

## 6. Assets

The following image assets are required for the application:

*   `resources/images/heart.png`
*   `resources/images/moon_sticker.png`
*   `resources/images/cup.png`
*   `resources/images/ticket.png`
*   `resources/images/cat.png`
