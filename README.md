# ShopEase 🛍️

## 📱 App Overview
**ShopEase** is a modern shopping application designed to provide users with a smooth and efficient product browsing experience. The app allows users to view products fetched from an external API, create and update items, and enjoy a responsive interface with offline support and dark mode. ShopEase focuses on performance, usability, and clean state management.

---

## ✨ Features
- 🔄 **Fetch product data** from a remote API
- 📦 **Create and update** shopping items
- 📴 **Offline caching** for uninterrupted access
- 🌙 **Dark mode** support
- ⚠️ **Robust error handling** for network and API failures
- 🧠 **Provider-based** state management
- ⚡ **Fast and responsive UI**

---

## 📸 Screenshots

## Light mode
<p align="center"> 
  <img src="https://github.com/user-attachments/assets/7007c99e-8bbe-4580-8ade-3cd35d5de9f6" height="250"> 
  <img src="https://github.com/user-attachments/assets/6308ebd7-fa50-4c4a-8912-a3d15241b50d" height="250"> 
  <img src="https://github.com/user-attachments/assets/84135186-8c30-44fb-815a-b6612431b43a" height="250"> 
  <img src="https://github.com/user-attachments/assets/928a53c2-ba74-4d72-9002-289d121381e3" height="250"> 
  <img src="https://github.com/user-attachments/assets/037f1afb-5893-408c-a669-f727450b7557" height="250"> 
  <img src="https://github.com/user-attachments/assets/4e1ab198-8d9e-4b5c-bdbe-e6f1d997b025" height=250"> 
</p>

## Dark mode
<p align="center">
  <img src="https://github.com/user-attachments/assets/b483e547-66fe-415d-9cfa-a9e508e621a0" height="250">
  <img src="https://github.com/user-attachments/assets/793a8937-df89-460c-a6c7-a1fd49badb02" height="250">
  <img src="https://github.com/user-attachments/assets/e18f9a19-8cf0-4bac-9752-3684d66e6a3d" height="250" >
  <img src="https://github.com/user-attachments/assets/ce3210bb-bbce-44c1-94a4-4bb6b83d5de3" height="250" >
  <img src="https://github.com/user-attachments/assets/b76c585b-3d55-4727-8b5e-b52db135c04e" height="250">
  <img src="https://github.com/user-attachments/assets/7bf69e7a-5cb7-4609-a89e-b34670ce73eb" height="250" >
</p>

---

## 🧠 State Management Approach
ShopEase uses **Provider** for state management, following the recommended Flutter architecture.

### Why Provider?
* **Separation of Concerns:** Business logic is kept in `ChangeNotifier` classes, separate from the UI widgets.
* **Efficiency:** Using `context.watch()` and `context.select()`, only the specific widgets that need data are rebuilt when the state changes.
* **Scalability:** Easily manages the lifecycle of data, such as product lists and user preferences (like Dark Mode), across the entire app.

### Implementation Flow
1. **Models:** Define the data structure (e.g., `Product`).
2. **ChangeNotifiers:** Classes like `ProductProvider` handle API calls and notify listeners when data updates.
3. **Consumers:** Widgets listen for changes and update the UI automatically when `notifyListeners()` is called.

---

## ⚙️ Setup Instructions

### Prerequisites
Ensure you have the following installed:
- Flutter SDK (latest stable version)
- Dart
- Android Studio / VS Code
- Emulator or physical device

### Installation
1. **Clone the repository:**
   ```bash
   git clone [https://github.com/okwuy09/shopease.git](https://github.com/okwuy09/shopease.git)
   cd shopease
