# Components

This folder contains reusable UI components for the RevUp bike rental application.

## Available Components

### Form Components

#### CustomTextField
A customizable text field with enhanced styling, icons, and validation support.

**Usage:**
```dart
CustomTextField(
  controller: _emailController,
  label: 'Email Address',
  icon: Icons.email_outlined,
  keyboardType: TextInputType.emailAddress,
  validator: (value) => value!.isEmpty ? 'Required' : null,
)
```

**Properties:**
- `controller` - TextEditingController for the field
- `label` - Label text for the field
- `icon` - Icon to display in the prefix
- `keyboardType` - Type of keyboard to show
- `isPassword` - Whether this is a password field
- `isPasswordVisible` - Password visibility state
- `onPasswordToggle` - Callback for password visibility toggle
- `validator` - Validation function
- `margin` - External margin

#### CustomButton
A gradient button with customizable styling and support for icons.

**Usage:**
```dart
CustomButton(
  text: 'Login',
  onPressed: () => _handleLogin(),
  icon: Icon(Icons.login),
)
```

**Properties:**
- `text` - Button text
- `onPressed` - Callback function
- `width` - Button width (defaults to full width)
- `height` - Button height (default: 55)
- `margin` - External margin
- `gradientColors` - List of gradient colors
- `backgroundColor` - Solid background color (overrides gradient)
- `textColor` - Text color (default: white)
- `fontSize` - Text font size (default: 18)
- `fontWeight` - Text font weight (default: bold)
- `isOutlined` - Whether to use outlined style
- `borderColor` - Border color for outlined style
- `borderWidth` - Border width (default: 1.5)
- `icon` - Optional icon widget

#### CustomTabBar
Enhanced tab bar with stepper-style design and gradient indicators.

**Usage:**
```dart
CustomTabBar(
  tabController: _tabController,
  tabs: [
    CustomTabItem(text: 'Login', icon: Icons.login),
    CustomTabItem(text: 'Sign Up', icon: Icons.person_add),
  ],
)
```

**Properties:**
- `tabController` - TabController for managing tabs
- `tabs` - List of CustomTabItem objects
- `height` - Tab bar height (default: 65)
- `padding` - Internal padding
- `backgroundColor` - Background color
- `indicatorColor` - Indicator color
- `indicatorGradientColors` - Gradient colors for indicator
- `labelColor` - Active label color
- `unselectedLabelColor` - Inactive label color
- `labelFontSize` - Active label font size
- `unselectedLabelFontSize` - Inactive label font size

### UI Components

#### StepProgressIndicator
A horizontal progress indicator showing current step in a multi-step process.

**Usage:**
```dart
StepProgressIndicator(
  currentStep: 0,
  totalSteps: 3,
  activeColor: Colors.red,
)
```

**Properties:**
- `currentStep` - Current active step (0-based)
- `totalSteps` - Total number of steps
- `activeColor` - Color for active step
- `inactiveColor` - Color for inactive steps
- `previousColor` - Color for completed steps
- `height` - Height of progress bars (default: 4)
- `margin` - External margin
- `spacing` - Spacing between steps (default: 8)

### Layout Components

#### AuthHeader
Header component with logo, title, and subtitle, typically used in authentication screens.

**Usage:**
```dart
AuthHeader(
  title: 'RevUp',
  subtitle: 'Your Journey, Your Ride',
  logoIcon: Icons.directions_bike_rounded,
)
```

**Properties:**
- `title` - Main title text
- `subtitle` - Subtitle text
- `logoIcon` - Icon for the logo
- `gradientColors` - Background gradient colors
- `padding` - Internal padding
- `borderRadius` - Border radius
- `logoSize` - Size of the logo icon
- `titleFontSize` - Title font size
- `subtitleFontSize` - Subtitle font size

#### AuthCard
Container component with shadow and rounded corners for auth forms.

**Usage:**
```dart
AuthCard(
  child: Column(
    children: [
      // Your form content here
    ],
  ),
)
```

**Properties:**
- `child` - Widget to display inside the card
- `margin` - External margin
- `padding` - Internal padding
- `borderRadius` - Border radius
- `boxShadow` - Shadow effects
- `backgroundColor` - Background color

#### AuthFooter
Footer component with divider text and terms text.

**Usage:**
```dart
AuthFooter(
  dividerText: 'Secure & Trusted',
  footerText: 'By continuing, you agree to our Terms...',
)
```

**Properties:**
- `dividerText` - Text in the center divider
- `footerText` - Footer text below divider
- `padding` - External padding
- `dividerTextStyle` - Style for divider text
- `footerTextStyle` - Style for footer text
- `dividerColor` - Color of the divider lines

## Component Structure

```
components/
├── auth_card.dart          # Container for auth forms
├── auth_footer.dart        # Footer with terms and divider
├── auth_header.dart        # Header with logo and title
├── components.dart         # Export file for all components
├── custom_button.dart      # Customizable button component
├── custom_tab_bar.dart     # Enhanced tab bar with stepper design
├── custom_text_field.dart  # Enhanced text input field
└── progress_indicator.dart # Step progress indicator
```

## Usage Guidelines

1. **Import the components:** Use `import '../components/components.dart';` to import all components
2. **Consistency:** Use these components consistently across the app for unified styling
3. **Customization:** All components support extensive customization through properties
4. **Theming:** Components automatically use the app's color scheme from `app_colors.dart`
5. **Responsive:** Components are designed to be responsive and work on different screen sizes

## Adding New Components

When adding new components:

1. Create the component file in the `components/` folder
2. Follow the established naming convention (e.g., `custom_*`, `auth_*`)
3. Add comprehensive documentation with usage examples
4. Export the component in `components.dart`
5. Ensure the component follows the app's design system
6. Add proper default values and make components flexible

## Best Practices

- Use meaningful property names that clearly indicate their purpose
- Provide sensible default values for optional properties
- Include proper null safety checks
- Follow Flutter's widget composition patterns
- Keep components focused on a single responsibility
- Use const constructors where possible for better performance
