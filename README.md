# 🌆 PixelCity App

An iOS application that displays real-time photos from any selected map location using the **Unsplash API**.

---

## 📱 Overview

PixelCity allows users to tap anywhere on a map and instantly loads a gallery of high‑quality images related to that location.

---

## ✨ Features

* 🗺 **Interactive Map** — Select any point to search related images
* 🖼 **Unsplash API Integration** — Fetches high-resolution photos
* ⚡️ **Async Image Loading** — Smooth UI and fast response
* 🧩 **Dynamic CollectionView Grid** — Automatically adjusts to screen size
* 🔍 **Full‑Screen Image Viewer**
* 📡 **Download Progress Indicator**

---

## 🧰 Tech Stack

* Swift 5
* UIKit
* MapKit
* Unsplash API
* Alamofire (for networking)
* UICollectionView

---

## 📸 Screenshots

### 🗺 Map View

Tap anywhere to load images.

<img src="assets/screenshots/MapView.png" width="240" />

### 📥 Loading UI

Shows loading state while fetching images.

<img src="assets/screenshots/Loading.png" width="240" />

### 🖼 Photo Grid

Displays images in a clean grid layout.

<img src="assets/screenshots/Gallery.png" width="240" />

---

## 🔧 Setup

1. Clone this repository
2. Add your **Unsplash API Key** to `Constants.swift`
3. Build & run the project in Xcode
4. Tap on the map and explore related photos

---

## 🔑 API Key Configuration

```swift
let UNSPLASH_API_KEY = "YOUR_API_KEY"
```

---

## 📦 Dependencies

* Alamofire
* Unsplash API

---

## 📜 License

This project is open-source and free to use.

