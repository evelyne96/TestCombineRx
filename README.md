Starter project used only for learning purposes

## Beer App Requirements
- API https://punkapi.com/documentation/v2
- Uses the MVVM-C architecture
 https://www.hackingwithswift.com/articles/71/how-to-use-the-coordinator-pattern-in-ios-apps
- Reactive framework used: Combine

### App Details
- Has 2 screens.
    - 1 screen is for beer list screen
         - each item should contain: image, name, first brewed, contributed by, attenuation level
         - tapping on an item opens the details screen
         - nice to have: pagination (API supports it, not implemented here yet)
    - 1 is for beer details screen (using xib)
         - info to display: image, name, first brewed, contributed by, attenuation level, 
ingredients, food parity
         - implemented using xib

- Includes unit test for beer list viewmodal and beer details viewmodel
