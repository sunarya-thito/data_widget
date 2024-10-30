# data_widget
`data_widget` is a Flutter package that provides a simple wrapper for InheritedWidget, InheritedModel, InheritedNotifier, ValueNotifier, and ChangeNotifier.

## Features

### Data
A widget that holds a single data and allows its descendants to access the data and listen to changes.

#### Providing the data
```dart
Data.inherit(
  data: 'Hello, World!',
  child: const MyWidget(),
)
```

#### Getting the data
There are multiple ways to get the data:

##### Find and listen
This method will find the nearest `Data<T>` widget (in this case `Data<String>`).
Calling this method will register a listener that will be invoked when the data changes.
In other words, the widget will rebuild when the data changes. This will throw
an assertion error if the data is not found.
```dart
String data = Data.of<String>(context);
```

##### Optionally find and listen
This method is similar to `Data.of<T>(BuildContext context)`, but will not throw an assertion error if the data is not found.
```dart
String? data = Data.maybeOf<String>(context);
```

##### Find
This method will find the nearest `Data<T>` widget (in this case `Data<String>`).
This will throw an assertion error if the data is not found.
This method does not register any listener so the widget will not rebuild when the data changes.
This is useful when you only need to read the data once (i.e. in `onPressed` callback, `onTap` callback, etc.).
```dart
String data = Data.find<String>(context);
```

##### Optionally find
This method is similar to `Data.find<T>(BuildContext context)`, but will not throw an assertion error if the data is not found.
```dart
String? data = Data.maybeFind<String>(context);
```

#### Blocking the data
You can stop the data from being passed down to its descendants by wrapping the widget with `Data.boundary`
```dart
Data.boundary<MyService>(
  child: const MyWidget(),
)
```

### MultiData
A widget that holds multiple data and allows its descendants to access the data and listen to changes without having to nest multiple `Data` widgets.

Usually, when you need to pass multiple data to its descendants, you will have to nest multiple `Data` widgets.
```dart
Data.inherit(
  data: 'Hello, World!',
  child: Data.inherit(
    data: 42,
    child: Data.boundary<MyService>(
      child: const MyWidget(),
    ),
  ),
)
```

With `MultiData`, you can pass multiple data without having to nest multiple `Data` widgets.
```dart
MultiData(
  data: [
    Data<String>('Hello, World!'),
    Data(42), // not providing type is optional, it will be inferred from the data
    Data.boundary<MyService>(), // but a must for boundary
  ],
```

Getting the data is similar to `Data` widget.

> [!NOTE]
> Providing type in the type param is optional but encouraged to avoid runtime errors due to type mismatch.

> [!WARNING]
> The order of the data must be the same as the order of the data provided.

### Model
A widget that holds a single model and allows its descendants to access or change the value of the model.
Similar to `Data` but uses symbol as the key to identify the model. Mostly useful when getting same type data
within the same widget tree.
```dart
// Using Data
Data.inherit(
  data: 'Hello, World!',
  child: Data.inherit(
    data: 'Another!',
    child: const MyWidget(), // The widget can only access 'Another!' data 
  ),
)
// Using Model
MultiModel(
  data: [
    Model(#myString, 'Hello, World!'),
    Model(#myString2, 'Another!'),
  ],
  child: const MyWidget(), // The widget can access both 'Hello, World!' and 'Another!' data
)
```

#### Providing a read-only model
```dart
Model.inherit(
  #myString,
  'Hello World',
  child: const MyWidget(),
)
```

#### Providing a model
```dart
String myString = 'Hello World';

Model.inherit(
  #myString,
  myString,
  child: const MyWidget(),
  onChanged: (value) {
    myString = value;
  },
)
```

#### Getting the model
There are multiple ways to get the model, most of them are similar to `Data` widget.
```dart
// Find and listen
String myString = Model.of<String>(context, #myString);
// Optionally find and listen
String? myString = Model.maybeOf<String>(context, #myString);
// Find
String myString = Model.find<String>(context, #myString);
// Optionally find
String? myString = Model.maybeFind<String>(context, #myString);
```

#### Blocking the model
You can stop the model from being passed down to its descendants by wrapping the widget with `ModelBoundary`
```dart
/// Single boundary
ModelBoundary<MyService>(
  #myService,
  child: const MyWidget(), // cannot access #myService
)
/// Multiple boundary
MultiModel(
  data: [
    ModelBoundary<MyService>(#myService),
    ModelBoundary<MyService>(#myService2),
  ],
  child: const MyWidget(), // cannot access #myService and #myService2
)
```

### MultiModel
A widget that holds multiple models and allows its descendants to access or change the value of the model.
Similar to `MultiData` but uses symbol as the key to identify the model. Mostly useful when getting same type data
within the same widget tree.
```dart
MultiModel(
  data: [
    Model(#myString, 'Hello, World!'),
    Model(#myString2, 'Another!'),
    ModelBoundary<MyService>(#myService),
  ],
  child: const MyWidget(),
)
```

Getting the model is similar to `Model` widget.

> [!NOTE]
> Providing type in the type param is optional but encouraged to avoid runtime errors due to type mismatch.

> [!WARNING]
> The order of the data must be the same as the order of the data provided.

### MutableNotifier
When using `List` (or any mutable object) as the value for `ValueNotifier`, it will not notify the listeners when the list is mutated,
because the reference to the list is not changed. `MutableNotifier` solves this problem by providing a method
to mutate the list and notify the listeners.
```dart
MutableNotifier<List<int>> list = MutableNotifier([1, 2, 3]);
list.mutate((value) {
  value.add(4);
});
```

You can also decide whether to notify the listeners or not.
```dart
MutableNotifier<List<int>> set = MutableNotifier([1, 2, 3]);
set.mutate((value) {
  if (!value.contains(4)) {
    value.add(4);
    return true; // notify the listeners
  }
  return false; // do not notify the listeners
});
```

### ValueNotifierUnmodifiableView
A wrapper for `ValueNotifier` that provides an unmodifiable view of the value.
```dart
ValueNotifier<String> valueNotifier = ValueNotifier('Hello, World!');
// Sure you can do this so that the value cannot be changed
ValueListenable<String> castedNotifier = valueNotifier;
// But you can still change the value by casting it back to ValueNotifier
(castedNotifier as ValueNotifier<String>).value = 'Another!';
// This can cause unexpected behavior

// Using ValueNotifierUnmodifiableView
ValueListenable<String> valueListenable = ValueNotifierUnmodifiableView(valueNotifier);
// This prevents the value from being changed outside of your control
(valueListenable as ValueNotifier<String>).value = 'Another!';
// as valueListenable is no longer a ValueNotifier, this will throw an error
```

You can also use the `ValueNotifier` extension method to convert the `ValueNotifier` to `ValueNotifierUnmodifiableView`.
```dart
ValueNotifier<String> _valueNotifier = ValueNotifier('Hello, World!');

ValueListenable<String> get valueListenable => _valueNotifier.readOnly(); 
```

### ValueChangeNotifier
Similar to `ValueNotifier`, but listeners can be notified with the old value and the new value.
```dart
ValueChangeNotifier<int> valueChangeNotifier = ValueChangeNotifier(42);
valueChangeNotifier.addChangeListener((newValue, oldValue) {
  print('Old value: $oldValue');
  print('New value: $newValue');
});
valueChangeNotifier.value = 43;
```

### ListNotifier
A list that can notify the listeners when the list is mutated.
```dart
ListNotifier<int> listNotifier = ListNotifier([1, 2, 3]);
listNotifier.addChangeListener((details) {
  print('Added: ${details.added}');
  print('Removed: ${details.removed}');
  print('Index: ${details.index}');  
});
listNotifier.add(4);
```

### SetNotifier
A set that can notify the listeners when the set is mutated.
```dart
SetNotifier<int> setNotifier = SetNotifier({1, 2, 3});
setNotifier.addChangeListener((details) {
  print('Added: ${details.added}');
  print('Removed: ${details.removed}');
});
setNotifier.add(4);
```

### MapNotifier
A map that can notify the listeners when the map is mutated.
```dart
MapNotifier<int, String> mapNotifier = MapNotifier({1: 'One', 2: 'Two', 3: 'Three'});
mapNotifier.addChangeListener((details) {
  print('Added: ${details.added}'); // added entries
  print('Removed: ${details.removed}'); // removed entries
});
mapNotifier[4] = 'Four';
```

### DebounceController
A controller that can be used to debounce the function call.
```dart
DebounceController debounceController = DebounceController();

debounceController.debounce(() {
  print('Debounced!'); // This will be cancelled
}, duration: const Duration(seconds: 1));
debounceController.debounce(() {
  print('Debounced 2!'); // This will be executed
}, duration: const Duration(seconds: 1));
// The first function call will be canceled and only the second function call will be executed
// Unless we wait for the debounce to finish, then the next function call will be executed
await Future.delayed(const Duration(seconds: 1));
debounceController.debounce(() {
  print('Debounced 3!'); // This will be executed
}, duration: const Duration(seconds: 1));
```
#### Use case
Preventing multiple function calls when the user is typing in the search bar.

```dart
TextField(
  onChanged: (value) {
    debounceController.debounce(() {
      // This will be executed after the user stops typing for 500ms,
      // if the user keeps typing, the debounce will be reset
      // so user cannot spam the search request if they type too fast
    }, duration: const Duration(milliseconds: 500));
  },
)
```

## Getting started
### 1. Install the package
In your terminal:
```bash
flutter pub add data_widget
```
or you can add it manually in your `pubspec.yaml`:
```yaml
dependencies:
  data_widget: {latest_version}
```

### 2. Import the package
```dart
import 'package:data_widget/data_widget.dart';
```

### Using Experimental Version
If you want to use the experimental version, you can add the following to your `pubspec.yaml`:
```yaml
dependencies:
  data_widget:
    git:
      url: "https://github.com/sunarya-thito/data_widget.git"
```